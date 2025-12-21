import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../../config/config.dart';
import '../../models/venue_detail.dart';
import 'booking_checkout_page.dart';

class _AvailableCourtSession {
  final int id;
  final String sessionName;
  final String startTime;
  final String endTime;
  final int durationMinutes;
  final bool isAvailable;

  const _AvailableCourtSession({
    required this.id,
    required this.sessionName,
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
    required this.isAvailable,
  });

  factory _AvailableCourtSession.fromJson(Map<String, dynamic> json) {
    return _AvailableCourtSession(
      id: (json['id'] as num).toInt(),
      sessionName: (json['session_name'] ?? '').toString(),
      startTime: (json['start_time'] ?? '').toString(),
      endTime: (json['end_time'] ?? '').toString(),
      durationMinutes: (json['duration'] as num?)?.toInt() ?? 0,
      isAvailable: json['is_available'] == true,
    );
  }
}

class VenueDetailPage extends StatefulWidget {
  final String venueId;

  const VenueDetailPage({super.key, required this.venueId});

  @override
  State<VenueDetailPage> createState() => _VenueDetailPageState();
}

class _VenueDetailPageState extends State<VenueDetailPage> {
  VenueDetail? venueDetail;
  bool isLoading = true;
  String errorMessage = '';
  int selectedImageIndex = 0;
  Court? selectedCourt;

  bool _hasFetchedVenueDetail = false;

  DateTime? _selectedBookingDate;
  bool _isSessionsLoading = false;
  String _sessionsError = '';
  List<_AvailableCourtSession> _availableSessions = const [];
  final Set<int> _selectedSessionIds = <int>{};
  double _pricePerHour = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchVenueDetailOnce();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  String _formatRupiah(num value) {
    final f = NumberFormat.decimalPattern('id_ID');
    return f.format(value.round());
  }

  String _formatDateYmd(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  Future<void> _pickBookingDate() async {
    final initial = _selectedBookingDate ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(DateTime.now()) ? DateTime.now() : initial,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );

    if (!mounted) return;
    if (picked == null) return;

    setState(() {
      _selectedBookingDate = picked;
      _selectedSessionIds.clear();
    });
    await _loadCourtSessions();
  }

  Future<void> _loadCourtSessions() async {
    if (selectedCourt == null) return;
    if (_selectedBookingDate == null) return;

    setState(() {
      _isSessionsLoading = true;
      _sessionsError = '';
      _availableSessions = const [];
      _pricePerHour = 0;
    });

    try {
      final request = context.read<CookieRequest>();
      final dateStr = _formatDateYmd(_selectedBookingDate!);
      final url =
          '${AppConfig.baseUrl}${AppConfig.courtsEndpoint}${selectedCourt!.id}/sessions/?date=$dateStr';
      final response = await request.get(url);

      if (!mounted) return;

      if (response is Map && response['success'] == true) {
        final data = response['data'];
        final sessionsRaw = (data is Map) ? (data['sessions'] as List?) : null;
        final sessions = (sessionsRaw ?? const [])
            .whereType<Map>()
            .map(
              (s) =>
                  _AvailableCourtSession.fromJson(Map<String, dynamic>.from(s)),
            )
            .toList();

        final priceRaw = (data is Map) ? data['price_per_hour'] : null;
        final price = (priceRaw is num) ? priceRaw.toDouble() : 0.0;

        setState(() {
          _availableSessions = sessions;
          _pricePerHour = price;
          _isSessionsLoading = false;
        });
        return;
      }

      setState(() {
        _isSessionsLoading = false;
        _sessionsError = (response is Map && response['message'] != null)
            ? response['message'].toString()
            : 'Failed to load sessions';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSessionsLoading = false;
        _sessionsError = 'Failed to load sessions: ${e.toString()}';
      });
    }
  }

  double _calculateSelectedTotalPrice() {
    if (_pricePerHour <= 0) return 0;
    double total = 0;
    for (final session in _availableSessions) {
      if (_selectedSessionIds.contains(session.id)) {
        total += _pricePerHour * (session.durationMinutes / 60.0);
      }
    }
    return total;
  }

  bool _canProceedToCheckout() {
    return selectedCourt != null &&
        _selectedBookingDate != null &&
        _selectedSessionIds.isNotEmpty &&
        !_isSessionsLoading;
  }

  Widget _buildSessionCard(_AvailableCourtSession session) {
    final selected = _selectedSessionIds.contains(session.id);
    final disabled = !session.isAvailable;
    final price = _pricePerHour > 0
        ? _pricePerHour * (session.durationMinutes / 60.0)
        : 0.0;

    final borderColor = selected
        ? Theme.of(context).colorScheme.primary
        : const Color(0xFFE5E7EB);

    final bgColor = disabled ? const Color(0xFFF9FAFB) : Colors.white;
    final textColor = disabled
        ? const Color(0xFF9CA3AF)
        : const Color(0xFF111827);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: disabled
            ? null
            : () {
                setState(() {
                  if (selected) {
                    _selectedSessionIds.remove(session.id);
                  } else {
                    _selectedSessionIds.add(session.id);
                  }
                });
              },
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: selected ? 2 : 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(disabled ? 0.02 : 0.04),
                blurRadius: 10,
                offset: const Offset(0, 6),
                spreadRadius: -6,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  disabled ? 'Unavailable' : 'Available',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: disabled
                        ? const Color(0xFF9CA3AF)
                        : Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${session.durationMinutes} Minutes',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: disabled
                        ? const Color(0xFF9CA3AF)
                        : const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '${session.startTime} - ${session.endTime}',
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                    letterSpacing: -0.2,
                  ),
                ),
                Text(
                  _pricePerHour > 0 ? 'Rp ${_formatRupiah(price)}' : 'Rp -',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: disabled
                        ? const Color(0xFF9CA3AF)
                        : const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _goToCheckout() async {
    if (!_canProceedToCheckout()) return;
    if (venueDetail == null) return;

    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => BookingCheckoutPage(
          courtId: selectedCourt!.id,
          courtName: selectedCourt!.name,
          venueName: venueDetail!.name,
          bookingDate: _selectedBookingDate!,
          sessionIds: _selectedSessionIds.toList(),
        ),
      ),
    );

    if (!mounted) return;

    if (result == true) {
      setState(() {
        _selectedSessionIds.clear();
      });
      await _loadCourtSessions();
    }
  }

  void _fetchVenueDetailOnce() {
    if (_hasFetchedVenueDetail) return;
    _hasFetchedVenueDetail = true;
    fetchVenueDetail();
  }

  Future<void> fetchVenueDetail() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final request = context.read<CookieRequest>();
      final response = await request.get(
        '${AppConfig.baseUrl}/api/public/venues/${widget.venueId}/',
      );

      if (mounted) {
        if (response != null && response['status'] == 'ok') {
          final venueResponse = VenueDetailResponse.fromJson(response);
          setState(() {
            venueDetail = venueResponse.data;
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = response?['message'] ?? 'Gagal memuat detail venue';
            isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'Error: $e';
          isLoading = false;
        });
      }
    }
  }

  void _showLocationDialog() {
    if (venueDetail?.locationUrl == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Buka Lokasi'),
        content: Text('Buka ${venueDetail!.locationUrl} di browser?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('URL: ${venueDetail!.locationUrl}')),
              );
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? _buildErrorWidget()
          : venueDetail == null
          ? _buildErrorWidget()
          : CustomScrollView(
              slivers: [
                _buildAppBar(),
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeroSection(),
                      _buildVenueCard(),
                      if (venueDetail!.facilities.isNotEmpty)
                        _buildFacilities(),
                      _buildCourts(),
                      _buildReviews(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(errorMessage.isNotEmpty ? errorMessage : 'Data tidak tersedia'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kembali'),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 0,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black87),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      height: 140,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF9FAFB), Color(0xFFEDE9FE), Color(0xFFDCFCE7)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF14B8A6).withOpacity(0.2),
                    const Color(0xFF14B8A6).withOpacity(0.05),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -100,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF5409DA).withOpacity(0.2),
                    const Color(0xFF5409DA).withOpacity(0.05),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVenueCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      transform: Matrix4.translationValues(0, -10, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [_buildImageGallery(), _buildVenueInfo()],
        ),
      ),
    );
  }

  Widget _buildImageGallery() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Dynamic height based on screen width
        final imageHeight = constraints.maxWidth < 400
            ? 220.0
            : constraints.maxWidth < 600
            ? 280.0
            : 350.0;

        if (venueDetail!.images.isEmpty) {
          return Container(
            height: imageHeight,
            decoration: BoxDecoration(color: Colors.grey[300]),
            child: Center(
              child: Icon(
                Icons.stadium,
                size: constraints.maxWidth < 400 ? 60 : 80,
                color: Colors.grey,
              ),
            ),
          );
        }

        return Column(
          children: [
            // Main Image with Stack for navigation
            Stack(
              children: [
                GestureDetector(
                  onTap: () {
                    if (venueDetail!.images.length > 1) {
                      setState(() {
                        selectedImageIndex =
                            (selectedImageIndex + 1) %
                            venueDetail!.images.length;
                      });
                    }
                  },
                  child: Image.network(
                    AppConfig.buildProxyImageUrl(
                      venueDetail!.images[selectedImageIndex],
                    ),
                    height: imageHeight,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: imageHeight,
                        color: Colors.grey[300],
                        child: Icon(
                          Icons.stadium,
                          size: constraints.maxWidth < 400 ? 60 : 80,
                        ),
                      );
                    },
                  ),
                ),
                // Navigation arrows for multiple images
                if (venueDetail!.images.length > 1) ...[
                  // Left arrow
                  Positioned(
                    left: 12,
                    top: imageHeight / 2 - 20,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.chevron_left,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            selectedImageIndex =
                                (selectedImageIndex -
                                    1 +
                                    venueDetail!.images.length) %
                                venueDetail!.images.length;
                          });
                        },
                      ),
                    ),
                  ),
                  // Right arrow
                  Positioned(
                    right: 12,
                    top: imageHeight / 2 - 20,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.chevron_right,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            selectedImageIndex =
                                (selectedImageIndex + 1) %
                                venueDetail!.images.length;
                          });
                        },
                      ),
                    ),
                  ),
                  // Image counter
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${selectedImageIndex + 1}/${venueDetail!.images.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            // Thumbnail Gallery
            if (venueDetail!.images.length > 1)
              Container(
                padding: const EdgeInsets.all(12),
                color: const Color(0xFFF9FAFB),
                child: SizedBox(
                  height: 80,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: venueDetail!.images.length,
                    itemBuilder: (context, index) {
                      final isSelected = selectedImageIndex == index;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedImageIndex = index;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : const Color(0xFFE5E7EB),
                              width: isSelected ? 3 : 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.network(
                              AppConfig.buildProxyImageUrl(
                                venueDetail!.images[index],
                              ),
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 80,
                                  height: 80,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.image, size: 30),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildVenueInfo() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            venueDetail!.name,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
              height: 1.3,
              letterSpacing: -0.5,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),

          // Rating
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF59E0B).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      venueDetail!.avgRating.toStringAsFixed(1),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  '${venueDetail!.ratingCount} reviews',
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Description
          if (venueDetail!.description != null &&
              venueDetail!.description!.isNotEmpty) ...[
            Text(
              venueDetail!.description!,
              style: const TextStyle(
                fontSize: 14,
                height: 1.6,
                color: Color(0xFF374151),
              ),
              maxLines: 10,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 24),
          ],

          // Location
          _buildInfoRow(
            Icons.location_on,
            'Location',
            venueDetail!.address,
            onTap: venueDetail!.locationUrl != null
                ? _showLocationDialog
                : null,
          ),
          const SizedBox(height: 16),

          // Contact
          if (venueDetail!.contact != null)
            _buildInfoRow(Icons.phone, 'Contact', venueDetail!.contact!),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6B7280),
                      letterSpacing: 0.5,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF111827),
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: Theme.of(context).colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFacilities() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Facilities',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: venueDetail!.facilities.map((facility) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 18,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      facility.name,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF374151),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCourts() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select a Court',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              // More responsive breakpoints matching HTML
              final crossAxisCount = constraints.maxWidth < 400
                  ? 2
                  : constraints.maxWidth < 650
                  ? 3
                  : 4;
              final aspectRatio = constraints.maxWidth < 400 ? 0.85 : 0.78;

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: aspectRatio,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: venueDetail!.courts.length,
                itemBuilder: (context, index) {
                  final court = venueDetail!.courts[index];
                  final isSelected = selectedCourt?.id == court.id;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          selectedCourt = null;
                          _selectedBookingDate = null;
                          _availableSessions = const [];
                          _selectedSessionIds.clear();
                          _sessionsError = '';
                          _pricePerHour = 0;
                        } else {
                          selectedCourt = court;
                          _selectedBookingDate = DateTime.now();
                          _selectedSessionIds.clear();
                        }
                      });

                      if (!isSelected) {
                        _loadCourtSessions();
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.all(
                        constraints.maxWidth < 400 ? 10 : 12,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF5409DA),
                            const Color(0xFF5409DA).withOpacity(0.85),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF14B8A6)
                              : const Color(0xFF5409DA).withOpacity(0.3),
                          width: 2,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: const Color(
                                    0xFF14B8A6,
                                  ).withOpacity(0.5),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  court.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.white,
                                  size: 20,
                                ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Rp ${court.pricePerHour.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(
                                '/jam',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${court.sessions.length} sesi tersedia',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
          if (selectedCourt != null) ...[
            const SizedBox(height: 24),
            const Divider(height: 1),
            const SizedBox(height: 24),
            Text(
              'Book ${selectedCourt!.name}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 18),
                        const SizedBox(width: 10),
                        Text(
                          _selectedBookingDate == null
                              ? 'Pick a date'
                              : _formatDateYmd(_selectedBookingDate!),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF111827),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton.tonal(
                  onPressed: _pickBookingDate,
                  child: const Text('Change'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isSessionsLoading)
              const Center(child: CircularProgressIndicator())
            else if (_sessionsError.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFCA5A5)),
                ),
                child: Text(
                  _sessionsError,
                  style: const TextStyle(
                    color: Color(0xFFB91C1C),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  final w = constraints.maxWidth;
                  final crossAxisCount = w >= 900
                      ? 6
                      : w >= 650
                      ? 4
                      : w >= 400
                      ? 3
                      : 2;
                  // Smaller ratio => taller cards (prevents vertical overflow)
                  final aspectRatio = crossAxisCount >= 6
                      ? 1.15
                      : crossAxisCount == 4
                      ? 1.10
                      : crossAxisCount == 3
                      ? 1.05
                      : 1.00;

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: aspectRatio,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: _availableSessions.length,
                    itemBuilder: (context, index) {
                      final session = _availableSessions[index];
                      return _buildSessionCard(session);
                    },
                  );
                },
              ),
            const SizedBox(height: 16),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Total: Rp ${_formatRupiah(_calculateSelectedTotalPrice())}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                ),
                FilledButton.icon(
                  onPressed: _canProceedToCheckout() ? _goToCheckout : null,
                  icon: const Icon(Icons.shopping_cart_checkout_outlined),
                  label: const Text('Checkout'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReviews() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Reviews',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${venueDetail!.reviews.length} reviews • ${venueDetail!.avgRating.toStringAsFixed(1)} average rating',
            style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 20),
          if (venueDetail!.reviews.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Belum ada review',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: venueDetail!.reviews.length > 5
                  ? 5
                  : venueDetail!.reviews.length,
              separatorBuilder: (context, index) => const Divider(height: 24),
              itemBuilder: (context, index) {
                final review = venueDetail!.reviews[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          child: Text(
                            review.user[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                review.user,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Row(
                                children: [
                                  ...List.generate(
                                    5,
                                    (starIndex) => Icon(
                                      Icons.star,
                                      size: 14,
                                      color: starIndex < review.rating
                                          ? Colors.amber
                                          : Colors.grey[300],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  if (review.createdAt != null)
                                    Text(
                                      _formatDate(review.createdAt!),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (review.comment != null &&
                        review.comment!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        review.comment!,
                        style: const TextStyle(fontSize: 13, height: 1.4),
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                );
              },
            ),
          if (venueDetail!.reviews.length > 5) ...[
            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: () {
                  // TODO: Show all reviews
                },
                child: const Text('Lihat semua review'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'Mei',
        'Jun',
        'Jul',
        'Agt',
        'Sep',
        'Okt',
        'Nov',
        'Des',
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}
