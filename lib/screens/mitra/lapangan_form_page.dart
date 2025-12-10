import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lapangin_mobile/constants/api_constants.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class LapanganFormPage extends StatefulWidget {
  final Map<String, dynamic>? lapangan; // For editing

  const LapanganFormPage({super.key, this.lapangan});

  @override
  State<LapanganFormPage> createState() => _LapanganFormPageState();
}

class _LapanganFormPageState extends State<LapanganFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();

  List<Map<String, dynamic>> _venues = [];
  List<String> _imageUrls = [];
  bool _isLoading = false;
  bool _isLoadingVenues = true;
  String _selectedCategory = 'Futsal';
  dynamic _selectedVenueId;

  final List<String> _categories = [
    'Futsal',
    'Badminton',
    'Basket',
    'Tenis',
    'Padel',
    'Voli',
  ];

  @override
  void initState() {
    super.initState();
    _loadVenues();
    if (widget.lapangan != null) {
      _loadLapanganData();
    } else {
      _addImageUrlInput();
    }
  }

  Future<void> _loadVenues() async {
    try {
      final request = context.read<CookieRequest>();
      final response = await request.get('${ApiConstants.baseUrl}/api/venues/');

      if (response['success'] == true) {
        setState(() {
          _venues = (response['data'] as List).map((venue) {
            return {'id': venue['id'], 'name': venue['name']};
          }).toList();
          _isLoadingVenues = false;

          if (_venues.isNotEmpty && _selectedVenueId == null) {
            _selectedVenueId = _venues[0]['id'];
          }
        });
      }
    } catch (e) {
      print('❌ Error loading venues: $e');
      setState(() => _isLoadingVenues = false);
    }
  }

  void _loadLapanganData() {
    final lapangan = widget.lapangan!;
    _nameController.text = lapangan['name'] ?? '';
    _priceController.text = lapangan['price'].toString();
    _descriptionController.text = lapangan['description'] ?? '';
    _selectedCategory = lapangan['category'] ?? 'Futsal';
    _selectedVenueId = lapangan['venue_id'];

    // Load image URL
    if (lapangan['image'] != null && lapangan['image'].toString().isNotEmpty) {
      _imageUrls = [lapangan['image'].toString()];
    }

    if (_imageUrls.isEmpty) _addImageUrlInput();
  }

  void _addImageUrlInput([String url = '']) {
    setState(() {
      _imageUrls.add(url);
    });
  }

  void _removeImageUrlInput(int index) {
    if (_imageUrls.length > 1) {
      setState(() {
        _imageUrls.removeAt(index);
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedVenueId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih venue terlebih dahulu'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final request = context.read<CookieRequest>();

      // Collect image URLs - send as JSON string
      final imageUrls = _imageUrls.where((url) => url.isNotEmpty).toList();

      // Map category names to match Django SportsCategory choices (uppercase)
      final categoryMap = {
        'Futsal': 'FUTSAL',
        'Badminton': 'BADMINTON',
        'Basket': 'BASKET',
        'Tenis': 'TENIS',
        'Padel': 'PADEL',
        'Voli': 'VOLI',
      };

      final data = {
        'name': _nameController.text.trim(),
        'venue': _selectedVenueId.toString(),
        'category':
            categoryMap[_selectedCategory] ?? _selectedCategory.toUpperCase(),
        'price_per_hour': _priceController.text.trim(),
        'description': _descriptionController.text.trim(),
        'is_active': 'on', // Django checkbox format
        'maintenance_notes': '',
        'image_urls': jsonEncode(imageUrls), // Django expects JSON string
      };

      print('🔍 Sending data: $data'); // Debug log

      dynamic response;
      if (widget.lapangan != null) {
        // Edit mode - add method override
        data['_method'] = 'PUT';
        response = await request.post(
          '${ApiConstants.baseUrl}/api/courts/${widget.lapangan!['id']}/',
          data,
        );
      } else {
        // Create mode
        response = await request.post(
          '${ApiConstants.baseUrl}/api/courts/',
          data,
        );
      }

      print('🔍 Response: $response'); // Debug log

      if (mounted) {
        setState(() => _isLoading = false);

        if (response['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      response['message'] ?? 'Lapangan berhasil disimpan',
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
            ),
          );
          Navigator.pop(context, true); // Return true to indicate success
        } else {
          // Show detailed error if available
          String errorMsg = response['message'] ?? 'Gagal menyimpan lapangan';
          if (response['errors'] != null) {
            errorMsg += '\n${response['errors']}';
          }
          throw Exception(errorMsg);
        }
      }
    } catch (e) {
      print('❌ Error: $e'); // Debug log
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Error: $e')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: Text(
          widget.lapangan != null ? 'Edit Lapangan' : 'Tambah Lapangan',
        ),
        backgroundColor: const Color(0xFF5409DA),
        foregroundColor: Colors.white,
      ),
      body: _isLoadingVenues
          ? const Center(child: CircularProgressIndicator())
          : _venues.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.store_mall_directory_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Belum ada venue',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Silakan tambahkan venue terlebih dahulu',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Basic Information
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Informasi Dasar',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: 'Nama Lapangan *',
                              hintText: 'Contoh: Lapangan A',
                              prefixIcon: const Icon(
                                Icons.sports_soccer,
                                color: Color(0xFF5409DA),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE5E5E5),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE5E5E5),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFF5409DA),
                                  width: 2,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Nama lapangan harus diisi';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<dynamic>(
                            value: _selectedVenueId,
                            decoration: InputDecoration(
                              labelText: 'Venue *',
                              prefixIcon: const Icon(
                                Icons.store,
                                color: Color(0xFF5409DA),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE5E5E5),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE5E5E5),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFF5409DA),
                                  width: 2,
                                ),
                              ),
                            ),
                            items: _venues.map((venue) {
                              return DropdownMenuItem<dynamic>(
                                value: venue['id'],
                                child: Text(venue['name']),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() => _selectedVenueId = value);
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Venue harus dipilih';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: _selectedCategory,
                            decoration: InputDecoration(
                              labelText: 'Kategori *',
                              prefixIcon: const Icon(Icons.category),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            items: _categories.map((category) {
                              return DropdownMenuItem<String>(
                                value: category,
                                child: Text(category),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() => _selectedCategory = value!);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Pricing
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(
                        color: Color(0xFFE5E5E5),
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Harga',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _priceController,
                            decoration: InputDecoration(
                              labelText: 'Harga per Jam *',
                              hintText: '100000',
                              helperText: 'Maksimal Rp 99.999.999',
                              prefixText: 'Rp ',
                              prefixIcon: const Icon(
                                Icons.attach_money,
                                color: Color(0xFF5409DA),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE5E5E5),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE5E5E5),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFF5409DA),
                                  width: 2,
                                ),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Harga harus diisi';
                              }
                              final price = int.tryParse(value);
                              if (price == null) {
                                return 'Harga harus berupa angka';
                              }
                              if (price < 0) {
                                return 'Harga tidak boleh negatif';
                              }
                              if (price > 99999999) {
                                return 'Harga maksimal Rp 99.999.999';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Deskripsi',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _descriptionController,
                            decoration: InputDecoration(
                              labelText: 'Deskripsi Lapangan (Opsional)',
                              hintText:
                                  'Deskripsi lapangan dan fasilitas yang tersedia',
                              prefixIcon: const Icon(Icons.description),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            maxLines: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Image URLs
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Gambar Lapangan (URL)',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              IconButton(
                                onPressed: () => _addImageUrlInput(),
                                icon: const Icon(Icons.add_circle),
                                color: const Color(0xFF5409DA),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _imageUrls.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        initialValue: _imageUrls[index],
                                        decoration: InputDecoration(
                                          labelText: 'URL Gambar ${index + 1}',
                                          hintText: 'https://...',
                                          prefixIcon: const Icon(Icons.image),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                        keyboardType: TextInputType.url,
                                        onChanged: (value) {
                                          _imageUrls[index] = value;
                                        },
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () =>
                                          _removeImageUrlInput(index),
                                      icon: const Icon(Icons.remove_circle),
                                      color: Colors.red,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          OutlinedButton.icon(
                            onPressed: () => _addImageUrlInput(),
                            icon: const Icon(Icons.add),
                            label: const Text('Tambah URL Gambar'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF5409DA),
                              side: const BorderSide(
                                color: Color(0xFF5409DA),
                                style: BorderStyle.solid,
                                width: 2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Submit Button
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5409DA),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              widget.lapangan != null
                                  ? 'Simpan Perubahan'
                                  : 'Tambah Lapangan',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }
}
