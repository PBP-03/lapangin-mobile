import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../../constants/api_constants.dart';

class VenuesPage extends StatefulWidget {
  const VenuesPage({super.key});

  @override
  State<VenuesPage> createState() => _VenuesPageState();
}

class _VenuesPageState extends State<VenuesPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _venues = [];

  // Helper function to proxy external images through backend
  String _getProxiedImageUrl(String imageUrl) {
    if (imageUrl.isEmpty || imageUrl == 'https://via.placeholder.com/400x300') {
      return imageUrl;
    }
    // Proxy all external images through Django backend
    return '${ApiConstants.baseUrl}/api/proxy-image/?url=${Uri.encodeComponent(imageUrl)}';
  }

  @override
  void initState() {
    super.initState();
    _loadVenues();
  }

  Future<void> _loadVenues() async {
    setState(() => _isLoading = true);

    try {
      final request = context.read<CookieRequest>();
      final response = await request.get('${ApiConstants.baseUrl}/api/venues/');

      if (response['success'] == true) {
        setState(() {
          _venues = (response['data'] as List).map((venue) {
            return {
              'id': venue['id'],
              'name': venue['name'],
              'address': venue['address'],
              'city': venue['address'], // Extract city from address if needed
              'description': venue['description'],
              'image': venue['images'].isNotEmpty
                  ? venue['images'][0]['url']
                  : 'https://via.placeholder.com/400x300',
              'facilities': [], // Will need to parse from venue data
              'contacts': venue['contact'],
              'verification_status': venue['verification_status'],
            };
          }).toList();
          _isLoading = false;
        });
        print('✅ Loaded ${_venues.length} venues from API');
      } else {
        throw Exception(response['message'] ?? 'Failed to load venues');
      }
    } catch (e) {
      print('❌ Error loading venues: $e');
      setState(() {
        _venues = [];
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading venues: $e')));
      }
    }
  }

  Future<void> _deleteVenue(int venueId, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text(
          'Yakin ingin menghapus venue "$name"? Semua lapangan di venue ini juga akan terhapus.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final request = context.read<CookieRequest>();
        final response = await request.post(
          '${ApiConstants.baseUrl}/api/venues/$venueId/',
          {'_method': 'DELETE'},
        );

        if (response['success'] == true) {
          await _loadVenues();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Venue berhasil dihapus'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  void _showEditVenueDialog(Map<String, dynamic> venue) {
    final nameController = TextEditingController(text: venue['name']);
    final addressController = TextEditingController(text: venue['address']);
    final cityController = TextEditingController(text: venue['city']);
    final descriptionController = TextEditingController(
      text: venue['description'],
    );
    final imageUrlController = TextEditingController(text: venue['image']);
    final facilitiesController = TextEditingController();
    final contactsController = TextEditingController(text: venue['contacts']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Venue'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Venue',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(
                  labelText: 'Alamat',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: cityController,
                decoration: const InputDecoration(
                  labelText: 'Kota',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'URL Gambar',
                  border: OutlineInputBorder(),
                  hintText: 'https://i.imgur.com/example.jpg',
                  helperText:
                      'Upload ke Imgur (imgur.com/upload) atau imgbb.com, copy direct link',
                  helperMaxLines: 3,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: contactsController,
                decoration: const InputDecoration(
                  labelText: 'Kontak',
                  border: OutlineInputBorder(),
                  hintText: 'Nomor telepon atau email',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final request = context.read<CookieRequest>();
                final formData = {
                  '_method': 'PUT',
                  'name': nameController.text,
                  'address': addressController.text,
                  'city': cityController.text,
                  'description': descriptionController.text,
                  'contact': contactsController.text,
                  'image_urls': jsonEncode([imageUrlController.text]),
                };

                final response = await request.post(
                  '${ApiConstants.baseUrl}/api/venues/${venue['id']}/',
                  formData,
                );

                if (response['success'] == true) {
                  await _loadVenues();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Venue berhasil diupdate'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5409DA),
              foregroundColor: Colors.white,
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showAddVenueDialog() {
    final nameController = TextEditingController();
    final addressController = TextEditingController();
    final cityController = TextEditingController();
    final descriptionController = TextEditingController();
    final imageUrlController = TextEditingController();
    final facilitiesController = TextEditingController();
    final contactsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Venue'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Venue',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(
                  labelText: 'Alamat',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: cityController,
                decoration: const InputDecoration(
                  labelText: 'Kota',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'URL Gambar',
                  border: OutlineInputBorder(),
                  hintText: 'https://i.imgur.com/example.jpg',
                  helperText:
                      'Upload ke Imgur (imgur.com/upload) atau imgbb.com, copy direct link',
                  helperMaxLines: 3,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: facilitiesController,
                decoration: const InputDecoration(
                  labelText: 'Fasilitas',
                  border: OutlineInputBorder(),
                  hintText: 'Parkir, Kantin, Musholla (pisahkan dengan koma)',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: contactsController,
                decoration: const InputDecoration(
                  labelText: 'Kontak',
                  border: OutlineInputBorder(),
                  hintText: 'Nomor telepon atau email',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Validate that all fields are filled
              if (nameController.text.isEmpty ||
                  addressController.text.isEmpty ||
                  cityController.text.isEmpty ||
                  descriptionController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Nama, alamat, kota, dan deskripsi harus diisi',
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              // Add venue to the list
              final newVenue = {
                'id': _venues.length + 1,
                'name': nameController.text,
                'address': addressController.text,
                'city': cityController.text,
                'description': descriptionController.text,
                'image': imageUrlController.text.isEmpty
                    ? 'https://via.placeholder.com/400x300'
                    : imageUrlController.text,
                'facilities': facilitiesController.text.isEmpty
                    ? []
                    : facilitiesController.text
                          .split(',')
                          .map((e) => e.trim())
                          .toList(),
                'contacts': contactsController.text,
              };

              // Save venue to Django API
              try {
                final request = context.read<CookieRequest>();

                print('🔐 Checking authentication...');
                print('Is logged in: ${request.loggedIn}');

                final formData = {
                  'name': newVenue['name'],
                  'address': newVenue['address'],
                  'location_url': '',
                  'contact': newVenue['contacts'],
                  'description': newVenue['description'],
                  'image_urls': jsonEncode([newVenue['image']]),
                  'facilities': jsonEncode(
                    (newVenue['facilities'] as List)
                        .map((f) => {'name': f})
                        .toList(),
                  ),
                };

                print(
                  '📤 Sending request to: ${ApiConstants.baseUrl}/api/venues/',
                );
                print('📦 Form data: $formData');

                final response = await request.post(
                  '${ApiConstants.baseUrl}/api/venues/',
                  formData,
                );

                print('📥 Response received: $response');

                if (response['success'] == true) {
                  // Reload venues from API
                  await _loadVenues();

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Venue berhasil ditambahkan!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  throw Exception(
                    response['message'] ?? 'Failed to create venue',
                  );
                }
              } catch (e) {
                print('❌ Error saving venue: $e');
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5409DA),
              foregroundColor: Colors.white,
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Venue'),
        backgroundColor: const Color(0xFF5409DA),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _venues.isEmpty
          ? _buildEmptyState()
          : _buildVenuesList(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddVenueDialog,
        backgroundColor: const Color(0xFF5409DA),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Venue'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.business, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'Belum ada venue',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Mulai tambahkan venue untuk memulai bisnis Anda',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildVenuesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _venues.length,
      itemBuilder: (context, index) {
        final venue = _venues[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () {
              // Navigate to venue detail
            },
            borderRadius: BorderRadius.circular(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: Image.network(
                    _getProxiedImageUrl(venue['image']),
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 200,
                        color: Colors.grey[200],
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      print('Image load error: $error');
                      return Container(
                        height: 200,
                        color: Colors.grey[300],
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.business,
                              size: 60,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Image not available',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        venue['name'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${venue['address']}, ${venue['city']}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        venue['description'],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: () => _showVenueDetailsDialog(venue),
                            icon: const Icon(Icons.info_outline, size: 18),
                            label: const Text('Info'),
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF4E71FF),
                            ),
                          ),
                          const SizedBox(width: 4),
                          TextButton.icon(
                            onPressed: () => _showEditVenueDialog(venue),
                            icon: const Icon(Icons.edit, size: 18),
                            label: const Text('Edit'),
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF5409DA),
                            ),
                          ),
                          const SizedBox(width: 4),
                          TextButton.icon(
                            onPressed: () =>
                                _deleteVenue(venue['id'], venue['name']),
                            icon: const Icon(Icons.delete, size: 18),
                            label: const Text('Hapus'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showVenueDetailsDialog(Map<String, dynamic> venue) async {
    // Fetch detailed venue data from API
    try {
      final request = context.read<CookieRequest>();
      final response = await request.get(
        '${ApiConstants.baseUrl}/api/venues/${venue['id']}/',
      );

      if (response['success'] == true && mounted) {
        final venueDetail = response['data'];
        _displayVenueDetailsDialog(venueDetail);
      }
    } catch (e) {
      print('❌ Error loading venue details: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading details: $e')));
      }
    }
  }

  void _displayVenueDetailsDialog(Map<String, dynamic> venue) {
    final images = venue['images'] as List? ?? [];
    final imageUrl = images.isNotEmpty ? images[0]['url'] : '';
    final proxiedImageUrl = imageUrl.isNotEmpty
        ? _getProxiedImageUrl(imageUrl)
        : '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Image
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      child: proxiedImageUrl.isNotEmpty
                          ? Image.network(
                              proxiedImageUrl,
                              height: 220,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    height: 220,
                                    color: Colors.grey[300],
                                    child: const Icon(
                                      Icons.business,
                                      size: 64,
                                      color: Colors.grey,
                                    ),
                                  ),
                            )
                          : Container(
                              height: 220,
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.business,
                                size: 64,
                                color: Colors.grey,
                              ),
                            ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black54,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    // Verification Badge
                    if (venue['verification_status'] == 'verified')
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.verified,
                                color: Colors.white,
                                size: 16,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Verified',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Venue Name
                      Text(
                        venue['name'] ?? 'Unnamed Venue',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Basic Info Section
                      _buildDetailSection(
                        icon: Icons.location_on,
                        title: 'Alamat',
                        content: venue['address'] ?? '-',
                      ),
                      const SizedBox(height: 12),

                      _buildDetailSection(
                        icon: Icons.phone,
                        title: 'Kontak',
                        content: venue['contact'] ?? '-',
                      ),
                      const SizedBox(height: 12),

                      _buildDetailSection(
                        icon: Icons.location_city,
                        title: 'Kota',
                        content: venue['city'] ?? '-',
                      ),
                      const SizedBox(height: 20),

                      // Description
                      if (venue['description'] != null &&
                          (venue['description'] as String).isNotEmpty) ...[
                        const Text(
                          'Deskripsi',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          venue['description'],
                          style: const TextStyle(
                            color: Colors.grey,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Courts Section
                      if (venue['courts'] != null &&
                          (venue['courts'] as List).isNotEmpty) ...[
                        Row(
                          children: [
                            const Icon(
                              Icons.sports_soccer,
                              size: 20,
                              color: Color(0xFF5409DA),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Lapangan (${(venue['courts'] as List).length})',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...((venue['courts'] as List).map(
                          (court) => Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            elevation: 1,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF4E71FF,
                                      ).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.sports_soccer,
                                      color: Color(0xFF4E71FF),
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          court['name'] ?? 'Unnamed Court',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          court['court_type'] ?? '-',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        'Rp ${_formatCurrency(court['price_per_hour'] ?? 0)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF5409DA),
                                          fontSize: 14,
                                        ),
                                      ),
                                      const Text(
                                        'per jam',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )),
                        const SizedBox(height: 12),
                      ],

                      // Images Gallery
                      if (images.length > 1) ...[
                        const Text(
                          'Galeri Foto',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: images.length,
                            itemBuilder: (context, index) {
                              final img = images[index];
                              return Container(
                                width: 120,
                                margin: const EdgeInsets.only(right: 8),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    _getProxiedImageUrl(img['url']),
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(
                                              color: Colors.grey[300],
                                              child: const Icon(
                                                Icons.image,
                                                color: Colors.grey,
                                              ),
                                            ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                _showEditVenueDialog(venue);
                              },
                              icon: const Icon(Icons.edit),
                              label: const Text('Edit'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF5409DA),
                                side: const BorderSide(
                                  color: Color(0xFF5409DA),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                _deleteVenue(venue['id'], venue['name']);
                              },
                              icon: const Icon(Icons.delete),
                              label: const Text('Hapus'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailSection({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: const Color(0xFF5409DA)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                content,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatCurrency(dynamic value) {
    final number = value is int ? value : (value is double ? value.toInt() : 0);
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }
}
