import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../../config/config.dart';
import '../../models/venue.dart';
import '../../providers/user_provider.dart';
import 'venue_detail_page.dart';

class VenueListPage extends StatefulWidget {
  const VenueListPage({super.key});

  @override
  State<VenueListPage> createState() => _VenueListPageState();
}

class _VenueListPageState extends State<VenueListPage> {
  List<Venue> venues = [];
  bool isLoading = true;
  String errorMessage = '';

  // Search and filter
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();
  String? selectedCategory;
  String? selectedMinRating;

  // Pagination
  int currentPage = 1;
  int totalPages = 1;
  int totalCount = 0;

  // Sorting
  String sortBy = 'price_low';

  // Base URL - ganti dengan URL backend Anda
  final String baseUrl = 'http://127.0.0.1:8000';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkUserRole();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _locationController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  void _checkUserRole() {
    final userProvider = context.read<UserProvider>();
    if (userProvider.user?.role != 'user') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hanya user yang dapat mengakses halaman ini'),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.pop(context);
    } else {
      fetchVenues();
    }
  }

  Future<void> fetchVenues({int page = 1}) async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final request = context.read<CookieRequest>();

      // Build query parameters
      Map<String, String> queryParams = {
        'page': page.toString(),
        'page_size': '9',
      };

      if (_searchController.text.isNotEmpty) {
        queryParams['search'] = _searchController.text;
      }
      if (_locationController.text.isNotEmpty) {
        queryParams['location'] = _locationController.text;
      }
      if (selectedCategory != null && selectedCategory!.isNotEmpty) {
        queryParams['category'] = selectedCategory!;
      }
      if (_minPriceController.text.isNotEmpty) {
        queryParams['min_price'] = _minPriceController.text;
      }
      if (_maxPriceController.text.isNotEmpty) {
        queryParams['max_price'] = _maxPriceController.text;
      }

      // Build URL with query parameters
      String url = 'http://localhost:8000/api/public/venues/';
      if (queryParams.isNotEmpty) {
        url +=
            '?' +
            queryParams.entries
                .map(
                  (e) =>
                      '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
                )
                .join('&');
      }

      final response = await request.get(url);

      if (response != null && response['status'] == 'ok') {
        final venueResponse = VenueListResponse.fromJson(response);

        setState(() {
          venues = venueResponse.data;
          currentPage = venueResponse.pagination.page;
          totalPages = venueResponse.pagination.totalPages;
          totalCount = venueResponse.pagination.totalCount;
          isLoading = false;

          // Apply sorting
          _sortVenues();
        });
      } else {
        setState(() {
          errorMessage = 'Gagal memuat data venue';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  void _sortVenues() {
    setState(() {
      if (sortBy == 'price_low') {
        venues.sort((a, b) => a.pricePerHour.compareTo(b.pricePerHour));
      } else if (sortBy == 'price_high') {
        venues.sort((a, b) => b.pricePerHour.compareTo(a.pricePerHour));
      } else if (sortBy == 'rating') {
        venues.sort((a, b) => b.avgRating.compareTo(a.avgRating));
      }
    });
  }

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _locationController.clear();
      _minPriceController.clear();
      _maxPriceController.clear();
      selectedCategory = null;
      selectedMinRating = null;
      currentPage = 1;
    });
    fetchVenues();
  }

  void _handleSearch() {
    setState(() {
      currentPage = 1;
    });
    fetchVenues(page: 1);
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      key: const ValueKey('category_dropdown'),
      value: selectedCategory,
      decoration: InputDecoration(
        hintText: 'Pilih Cabang Olahraga',
        hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF5409DA), width: 2),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.8),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      items: const [
        DropdownMenuItem(value: null, child: Text('Semua')),
        DropdownMenuItem(value: 'FUTSAL', child: Text('Futsal')),
        DropdownMenuItem(value: 'BADMINTON', child: Text('Badminton')),
        DropdownMenuItem(value: 'BASKET', child: Text('Basket')),
        DropdownMenuItem(value: 'TENNIS', child: Text('Tennis')),
        DropdownMenuItem(value: 'PADEL', child: Text('Padel')),
      ],
      onChanged: (value) {
        setState(() {
          selectedCategory = value;
        });
      },
    );
  }

  Widget _buildRatingDropdown() {
    return DropdownButtonFormField<String>(
      key: const ValueKey('rating_dropdown'),
      value: selectedMinRating,
      decoration: InputDecoration(
        hintText: 'Min. Rating',
        hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF5409DA), width: 2),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.8),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      items: const [
        DropdownMenuItem(value: null, child: Text('Semua')),
        DropdownMenuItem(value: '4.5', child: Text('⭐ 4.5+')),
        DropdownMenuItem(value: '4', child: Text('⭐ 4.0+')),
        DropdownMenuItem(value: '3', child: Text('⭐ 3.0+')),
      ],
      onChanged: (value) {
        setState(() {
          selectedMinRating = value;
        });
      },
    );
  }

  Widget _buildMinPriceField() {
    return TextField(
      key: const ValueKey('min_price_field'),
      controller: _minPriceController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        hintText: 'Harga minimum (Rp)',
        hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF5409DA), width: 2),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.8),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }

  Widget _buildMaxPriceField() {
    return TextField(
      key: const ValueKey('max_price_field'),
      controller: _maxPriceController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        hintText: 'Harga maximum (Rp)',
        hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF5409DA), width: 2),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.8),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Hero Section with Enhanced Gradient
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: const Color(0xFF5409DA),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final isVerySmall = width < 280;
                  final isSmall = width < 360;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (width > 250) ...[
                          Text(
                            'Discover Perfect',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: isVerySmall ? 8 : (isSmall ? 10 : 12),
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withOpacity(0.95),
                              letterSpacing: 0.1,
                              height: 1,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.clip,
                          ),
                          const SizedBox(height: 2),
                        ],
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isVerySmall ? 4 : (isSmall ? 6 : 10),
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.25),
                                Colors.white.withOpacity(0.15),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            'Sports Venue',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: isVerySmall ? 10 : (isSmall ? 13 : 16),
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.4,
                              height: 1,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.clip,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              background: Stack(
                children: [
                  // Gradient background
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF5409DA), // Primary purple
                          Color(0xFF14B8A6), // Teal
                        ],
                      ),
                    ),
                  ),
                  // Decorative circles
                  Positioned(
                    top: -100,
                    right: -100,
                    child: Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -50,
                    left: -50,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Enhanced Search Form with Elevated Design
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return Text(
                        'Temukan Venue Impian Anda',
                        style: TextStyle(
                          fontSize: constraints.maxWidth < 300
                              ? 16
                              : (constraints.maxWidth < 400 ? 19 : 22),
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      );
                    },
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Gunakan filter di bawah untuk menemukan lapangan yang sesuai',
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 20),

                  // Search field
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Cari nama venue',
                      hintStyle: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 14,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFF64748B),
                        size: 20,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFFE2E8F0),
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFFE2E8F0),
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF5409DA),
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.8),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Location field
                  TextField(
                    controller: _locationController,
                    decoration: InputDecoration(
                      hintText: 'Pilih Kota',
                      hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                      prefixIcon: const Icon(
                        Icons.location_on,
                        color: Color(0xFF64748B),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: Color(0xFFE2E8F0),
                          width: 2,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: Color(0xFFE2E8F0),
                          width: 2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: Color(0xFF5409DA),
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.8),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Category and Rating dropdowns
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth < 400) {
                        return Column(
                          children: [
                            _buildCategoryDropdown(),
                            const SizedBox(height: 16),
                            _buildRatingDropdown(),
                          ],
                        );
                      }
                      return Row(
                        children: [
                          Expanded(child: _buildCategoryDropdown()),
                          const SizedBox(width: 12),
                          Expanded(child: _buildRatingDropdown()),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 10),

                  // Price range
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth < 400) {
                        return Column(
                          children: [
                            _buildMinPriceField(),
                            const SizedBox(height: 16),
                            _buildMaxPriceField(),
                          ],
                        );
                      }
                      return Row(
                        children: [
                          Expanded(child: _buildMinPriceField()),
                          const SizedBox(width: 12),
                          Expanded(child: _buildMaxPriceField()),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 14),

                  // Search button with gradient
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF5409DA), Color(0xFF14B8A6)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF5409DA).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _handleSearch,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.search, color: Colors.white),
                                if (constraints.maxWidth > 200) ...[
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      'Cari Venue Sekarang',
                                      style: TextStyle(
                                        fontSize: constraints.maxWidth < 250
                                            ? 14
                                            : 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Results Header with Enhanced Design
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFF5409DA).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.view_list,
                            color: Color(0xFF5409DA),
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Hasil Pencarian',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Color(0xFF0F172A),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Menampilkan $totalCount venue tersedia',
                                style: const TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 12,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  DropdownButton<String>(
                    value: sortBy,
                    underline: Container(),
                    items: const [
                      DropdownMenuItem(
                        value: 'price_low',
                        child: Text('Harga Terendah'),
                      ),
                      DropdownMenuItem(
                        value: 'price_high',
                        child: Text('Harga Tertinggi'),
                      ),
                      DropdownMenuItem(
                        value: 'rating',
                        child: Text('Rating Tertinggi'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          sortBy = value;
                          _sortVenues();
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          ),

          // Venue Grid
          if (isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (errorMessage.isNotEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(errorMessage),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => fetchVenues(page: currentPage),
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            )
          else if (venues.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    const Text(
                      'Tidak ada venue ditemukan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('Coba ubah filter pencarian Anda'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _resetFilters,
                      child: const Text('Reset Filter'),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverLayoutBuilder(
              builder: (context, constraints) {
                double crossAxisExtent;
                double spacing;
                double aspectRatio;

                // Responsive grid configuration - max 3 columns
                if (constraints.crossAxisExtent < 600) {
                  // Mobile: 1 column - more vertical space
                  crossAxisExtent = constraints.crossAxisExtent - 32;
                  spacing = 12;
                  aspectRatio = 0.75; // Taller card for more content
                } else if (constraints.crossAxisExtent < 1000) {
                  // Tablet: 2 columns - more vertical space
                  crossAxisExtent = (constraints.crossAxisExtent - 48) / 2;
                  spacing = 16;
                  aspectRatio = 0.78; // Taller card for more content
                } else {
                  // Desktop/Full screen: 3 columns max - more vertical space
                  crossAxisExtent = (constraints.crossAxisExtent - 64) / 3;
                  spacing = 20;
                  aspectRatio = 0.82; // Taller card for more content
                }

                return SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: crossAxisExtent,
                      childAspectRatio: aspectRatio,
                      mainAxisSpacing: spacing,
                      crossAxisSpacing: spacing,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildVenueCard(venues[index]),
                      childCount: venues.length,
                    ),
                  ),
                );
              },
            ),

          // Enhanced Pagination - Responsive
          if (!isLoading && venues.isNotEmpty)
            SliverToBoxAdapter(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final screenWidth = constraints.maxWidth;
                  final isSmallScreen = screenWidth < 600;

                  return Container(
                    margin: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    child: Center(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // First/Previous buttons
                            _buildPaginationIconButton(
                              icon: Icons.keyboard_double_arrow_left,
                              isEnabled: currentPage > 1,
                              onPressed: () => fetchVenues(page: 1),
                              isSmall: isSmallScreen,
                            ),
                            SizedBox(width: isSmallScreen ? 4 : 8),
                            _buildPaginationIconButton(
                              icon: Icons.chevron_left,
                              isEnabled: currentPage > 1,
                              onPressed: () =>
                                  fetchVenues(page: currentPage - 1),
                              isSmall: isSmallScreen,
                            ),
                            SizedBox(width: isSmallScreen ? 6 : 12),
                            // Page numbers
                            ..._buildPageNumbers(isSmallScreen),
                            SizedBox(width: isSmallScreen ? 6 : 12),
                            // Next/Last buttons
                            _buildPaginationIconButton(
                              icon: Icons.chevron_right,
                              isEnabled: currentPage < totalPages,
                              onPressed: () =>
                                  fetchVenues(page: currentPage + 1),
                              isSmall: isSmallScreen,
                            ),
                            SizedBox(width: isSmallScreen ? 4 : 8),
                            _buildPaginationIconButton(
                              icon: Icons.keyboard_double_arrow_right,
                              isEnabled: currentPage < totalPages,
                              onPressed: () => fetchVenues(page: totalPages),
                              isSmall: isSmallScreen,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPaginationIconButton({
    required IconData icon,
    required bool isEnabled,
    required VoidCallback onPressed,
    bool isSmall = false,
  }) {
    final buttonSize = isSmall ? 36.0 : 44.0;
    final iconSize = isSmall ? 18.0 : 20.0;

    return Container(
      width: buttonSize,
      height: buttonSize,
      decoration: BoxDecoration(
        color: isEnabled ? Colors.white : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(isSmall ? 10 : 12),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: isSmall ? 1.5 : 2,
        ),
        boxShadow: isEnabled
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? onPressed : null,
          borderRadius: BorderRadius.circular(isSmall ? 10 : 12),
          child: Icon(
            icon,
            color: isEnabled
                ? const Color(0xFF64748B)
                : const Color(0xFFCBD5E1),
            size: iconSize,
          ),
        ),
      ),
    );
  }

  Widget _buildPageNumberButton(
    int pageNumber,
    bool isActive, {
    bool isSmall = false,
  }) {
    final buttonSize = isSmall ? 36.0 : 44.0;
    final fontSize = isSmall ? 13.0 : 15.0;
    final horizontalMargin = isSmall ? 2.0 : 4.0;

    return Container(
      width: buttonSize,
      height: buttonSize,
      margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
      decoration: BoxDecoration(
        gradient: isActive
            ? const LinearGradient(
                colors: [Color(0xFF5409DA), Color(0xFF14B8A6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isActive ? null : Colors.white,
        borderRadius: BorderRadius.circular(isSmall ? 10 : 12),
        border: Border.all(
          color: isActive ? Colors.transparent : const Color(0xFFE2E8F0),
          width: isSmall ? 1.5 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: isActive
                ? const Color(0xFF5409DA).withOpacity(0.3)
                : Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isActive ? null : () => fetchVenues(page: pageNumber),
          borderRadius: BorderRadius.circular(isSmall ? 10 : 12),
          child: Center(
            child: Text(
              pageNumber.toString(),
              style: TextStyle(
                color: isActive ? Colors.white : const Color(0xFF64748B),
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                fontSize: fontSize,
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildPageNumbers([bool isSmall = false]) {
    List<Widget> pages = [];

    // Show fewer pages on small screens to prevent overflow
    final maxVisiblePages = isSmall ? 3 : 5;
    final pagesOnEachSide = isSmall ? 1 : 2;

    int start = (currentPage - pagesOnEachSide).clamp(1, totalPages);
    int end = (currentPage + pagesOnEachSide).clamp(1, totalPages);

    // Adjust start/end to show maxVisiblePages if possible
    if (end - start < maxVisiblePages - 1) {
      if (start == 1) {
        end = (start + maxVisiblePages - 1).clamp(1, totalPages);
      } else if (end == totalPages) {
        start = (end - maxVisiblePages + 1).clamp(1, totalPages);
      }
    }

    for (int i = start; i <= end; i++) {
      pages.add(_buildPageNumberButton(i, i == currentPage, isSmall: isSmall));
    }

    // Add ellipsis and last page if needed
    if (end < totalPages) {
      if (end < totalPages - 1) {
        pages.add(
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isSmall ? 2 : 4),
            child: Text(
              '...',
              style: TextStyle(
                color: const Color(0xFF64748B),
                fontSize: isSmall ? 14 : 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }
      pages.add(_buildPageNumberButton(totalPages, false, isSmall: isSmall));
    }

    return pages;
  }

  Widget _buildVenueCard(Venue venue) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        // Responsive font sizes - compact and readable
        final titleSize = width < 160
            ? 11.0
            : (width < 200 ? 12.0 : (width < 250 ? 13.0 : 14.0));
        final ratingSize = width < 160
            ? 9.0
            : (width < 200 ? 9.5 : (width < 250 ? 10.5 : 11.5));
        final locationSize = width < 160
            ? 8.5
            : (width < 200 ? 9.0 : (width < 250 ? 9.5 : 10.5));
        final priceSize = width < 160
            ? 10.5
            : (width < 200 ? 11.5 : (width < 250 ? 12.5 : 13.5));
        final badgeSize = width < 160
            ? 7.5
            : (width < 200 ? 8.5 : (width < 250 ? 9.5 : 10.5));

        final iconSize = width < 160 ? 10.5 : (width < 200 ? 11.5 : 12.5);

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 2),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        VenueDetailPage(venueId: venue.id.toString()),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Venue Image - proportional image space
                  SizedBox(
                    height: width < 200 ? 110 : (width < 300 ? 135 : 160),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                          child: venue.images.isNotEmpty
                              ? Image.network(
                                  AppConfig.buildProxyImageUrl(
                                    venue.images.first,
                                  ),
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: const Color(0xFFF1F5F9),
                                      child: Center(
                                        child: Icon(
                                          Icons.stadium,
                                          size: width < 200 ? 28 : 36,
                                          color: const Color(0xFF94A3B8),
                                        ),
                                      ),
                                    );
                                  },
                                )
                              : Container(
                                  color: const Color(0xFFF1F5F9),
                                  child: Center(
                                    child: Icon(
                                      Icons.stadium,
                                      size: width < 200 ? 28 : 36,
                                      color: const Color(0xFF94A3B8),
                                    ),
                                  ),
                                ),
                        ),
                        // Category badge - smaller
                        if (venue.category.isNotEmpty)
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: width < 200 ? 6 : 8,
                                vertical: width < 200 ? 3 : 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 3,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Text(
                                venue.category,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: badgeSize,
                                  color: const Color(0xFF0F172A),
                                  height: 1,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Venue Info - compact padding
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(width < 200 ? 8.0 : 10.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Name
                          Text(
                            venue.name,
                            style: TextStyle(
                              fontSize: titleSize,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F172A),
                              height: 1.25,
                              letterSpacing: -0.15,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: width < 200 ? 3 : 4),

                          // Rating - simplified
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star,
                                size: iconSize,
                                color: const Color(0xFFFBBF24),
                              ),
                              const SizedBox(width: 3),
                              Flexible(
                                child: Text(
                                  '${venue.avgRating.toStringAsFixed(1)} (${venue.ratingCount})',
                                  style: TextStyle(
                                    fontSize: ratingSize,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF0F172A),
                                    height: 1,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: width < 200 ? 3 : 4),

                          // Location
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: iconSize,
                                color: const Color(0xFF64748B),
                              ),
                              const SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  venue.address,
                                  style: TextStyle(
                                    color: const Color(0xFF64748B),
                                    fontSize: locationSize,
                                    height: 1.25,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),

                          // Price section - compact
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Mulai dari',
                                style: TextStyle(
                                  fontSize: locationSize - 1,
                                  color: const Color(0xFF64748B),
                                  height: 1,
                                ),
                              ),
                              SizedBox(height: width < 200 ? 1 : 2),
                              Text(
                                'Rp ${venue.pricePerHour.toStringAsFixed(0)}/jam',
                                style: TextStyle(
                                  fontSize: priceSize,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF5409DA),
                                  height: 1,
                                  letterSpacing: -0.4,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
