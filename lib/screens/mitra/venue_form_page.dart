import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lapangin_mobile/constants/api_constants.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class VenueFormPage extends StatefulWidget {
  final Map<String, dynamic>? venue; // For editing

  const VenueFormPage({super.key, this.venue});

  @override
  State<VenueFormPage> createState() => _VenueFormPageState();
}

class _VenueFormPageState extends State<VenueFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _locationUrlController = TextEditingController();
  final _contactController = TextEditingController();
  final _descriptionController = TextEditingController();

  List<Map<String, String>> _facilities = [];
  List<String> _imageUrls = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.venue != null) {
      _loadVenueData();
    } else {
      _addFacilityInput();
      _addImageUrlInput();
    }
  }

  void _loadVenueData() {
    final venue = widget.venue!;
    _nameController.text = venue['name'] ?? '';
    _addressController.text = venue['address'] ?? '';
    _locationUrlController.text = venue['location_url'] ?? '';
    _contactController.text = venue['contact'] ?? '';
    _descriptionController.text = venue['description'] ?? '';

    // Load facilities
    if (venue['facilities'] != null) {
      _facilities = (venue['facilities'] as List)
          .map(
            (f) => {
              'name': f['name'].toString(),
              'icon': f['icon']?.toString() ?? '',
            },
          )
          .toList();
    }

    // Load images
    if (venue['images'] != null) {
      _imageUrls = (venue['images'] as List)
          .map((img) => img['url'].toString())
          .toList();
    }

    if (_facilities.isEmpty) _addFacilityInput();
    if (_imageUrls.isEmpty) _addImageUrlInput();
  }

  void _addFacilityInput([String name = '', String icon = '']) {
    setState(() {
      _facilities.add({'name': name, 'icon': icon});
    });
  }

  void _removeFacilityInput(int index) {
    if (_facilities.length > 1) {
      setState(() {
        _facilities.removeAt(index);
      });
    }
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

    setState(() => _isLoading = true);

    try {
      final request = context.read<CookieRequest>();

      // Collect facilities - send as list directly
      final facilities = _facilities
          .where((f) => f['name']!.isNotEmpty)
          .map((f) => {'name': f['name'], 'icon': f['icon'] ?? ''})
          .toList();

      // Collect image URLs - send as list directly
      final imageUrls = _imageUrls.where((url) => url.isNotEmpty).toList();

      final data = {
        'name': _nameController.text.trim(),
        'address': _addressController.text.trim(),
        'location_url': _locationUrlController.text.trim(),
        'contact': _contactController.text.trim(),
        'description': _descriptionController.text.trim(),
        'facilities': facilities, // Send as list, not JSON string
        'image_urls': imageUrls, // Send as list, not JSON string
      };

      dynamic response;
      if (widget.venue != null) {
        // Edit mode - add method override
        data['_method'] = 'PUT';
        response = await request.postJson(
          '${ApiConstants.baseUrl}/api/venues/${widget.venue!['id']}/',
          jsonEncode(data),
        );
      } else {
        // Create mode
        response = await request.postJson(
          '${ApiConstants.baseUrl}/api/venues/',
          jsonEncode(data),
        );
      }

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
                      response['message'] ?? 'Venue berhasil disimpan',
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
          throw Exception(response['message'] ?? 'Gagal menyimpan venue');
        }
      }
    } catch (e) {
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
    _addressController.dispose();
    _locationUrlController.dispose();
    _contactController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: Text(widget.venue != null ? 'Edit Venue' : 'Tambah Venue'),
        backgroundColor: const Color(0xFF5409DA),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Name
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFFE5E5E5), width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informasi Dasar',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Nama Venue *',
                        hintText: 'Contoh: Futsal Arena BSD',
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
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nama venue harus diisi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        labelText: 'Alamat *',
                        hintText: 'Alamat lengkap venue',
                        prefixIcon: const Icon(
                          Icons.location_on,
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
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Alamat harus diisi';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Contact Info
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFFE5E5E5), width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informasi Kontak',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _locationUrlController,
                      decoration: InputDecoration(
                        labelText: 'URL Lokasi (Google Maps)',
                        hintText: 'https://maps.google.com/...',
                        prefixIcon: const Icon(Icons.map),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: TextInputType.url,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _contactController,
                      decoration: InputDecoration(
                        labelText: 'Nomor Kontak',
                        hintText: '08123456789',
                        prefixIcon: const Icon(Icons.phone),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Description
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFFE5E5E5), width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Deskripsi',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Deskripsi Venue (Opsional)',
                        hintText: 'Deskripsi venue dan fasilitas yang tersedia',
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

            // Facilities
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFFE5E5E5), width: 1),
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
                          'Fasilitas',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          onPressed: () => _addFacilityInput(),
                          icon: const Icon(Icons.add_circle),
                          color: const Color(0xFF5409DA),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _facilities.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  initialValue: _facilities[index]['name'],
                                  decoration: InputDecoration(
                                    labelText: 'Nama Fasilitas',
                                    hintText: 'Parking, WiFi, Canteen',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                  ),
                                  onChanged: (value) {
                                    _facilities[index]['name'] = value;
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextFormField(
                                  initialValue: _facilities[index]['icon'],
                                  decoration: InputDecoration(
                                    labelText: 'Icon URL',
                                    hintText: 'Opsional',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                  ),
                                  onChanged: (value) {
                                    _facilities[index]['icon'] = value;
                                  },
                                ),
                              ),
                              IconButton(
                                onPressed: () => _removeFacilityInput(index),
                                icon: const Icon(Icons.remove_circle),
                                color: Colors.red,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _addFacilityInput(),
                      icon: const Icon(Icons.add),
                      label: const Text('Tambah Fasilitas'),
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
            const SizedBox(height: 16),

            // Image URLs
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFFE5E5E5), width: 1),
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
                          'Gambar Venue (URL)',
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
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  keyboardType: TextInputType.url,
                                  onChanged: (value) {
                                    _imageUrls[index] = value;
                                  },
                                ),
                              ),
                              IconButton(
                                onPressed: () => _removeImageUrlInput(index),
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
                        widget.venue != null
                            ? 'Simpan Perubahan'
                            : 'Tambah Venue',
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
