import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../../config/config.dart';

class BookingHistoryPage extends StatefulWidget {
  const BookingHistoryPage({super.key});

  @override
  State<BookingHistoryPage> createState() => _BookingHistoryPageState();
}

class _BookingHistoryPageState extends State<BookingHistoryPage> {
  List<dynamic> _bookings = [];
  bool _isLoading = true;
  String? _error;

  late final NumberFormat _rupiahFormatter;
  DateFormat? _dateFormatter;

  @override
  void initState() {
    super.initState();
    _rupiahFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    // DateFormat with locale requires locale data initialization on web.
    // We keep this safe so the page never crashes.
    try {
      _dateFormatter = DateFormat('EEE, d MMM yyyy', 'id_ID');
    } catch (_) {
      _dateFormatter = null;
    }

    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final request = Provider.of<CookieRequest>(context, listen: false);
      final response = await request.get(
        AppConfig.buildUrl(AppConfig.bookingsEndpoint),
      );

      // Supported shapes:
      // 1) List
      // 2) { bookings: [...] }
      // 3) { success: true, data: { bookings: [...] } }
      if (response is List) {
        setState(() {
          _bookings = response;
          _isLoading = false;
        });
        return;
      }

      if (response is Map) {
        // Handle standardized API wrapper
        if (response['success'] == false) {
          setState(() {
            _error = (response['message'] ?? 'Authentication required')
                .toString();
            _isLoading = false;
          });
          return;
        }

        if (response['bookings'] is List) {
          setState(() {
            _bookings = List<dynamic>.from(response['bookings'] as List);
            _isLoading = false;
          });
          return;
        }

        final data = response['data'];
        if (data is Map && data['bookings'] is List) {
          setState(() {
            _bookings = List<dynamic>.from(data['bookings'] as List);
            _isLoading = false;
          });
          return;
        }
      }

      setState(() {
        _error = 'Unexpected response format';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load bookings: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Booking History'),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
          : _error != null
          ? _buildErrorState(context, message: _error!, onRetry: _fetchBookings)
          : _bookings.isEmpty
          ? _buildEmptyState(context)
          : RefreshIndicator(
              onRefresh: _fetchBookings,
              color: colorScheme.primary,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                itemCount: _bookings.length,
                itemBuilder: (context, index) {
                  final booking = _bookings[index];
                  return _buildBookingCard(booking);
                },
                separatorBuilder: (_, __) => const SizedBox(height: 12),
              ),
            ),
    );
  }

  Widget _buildErrorState(
    BuildContext context, {
    required String message,
    required VoidCallback onRetry,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.08),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.error_outline,
                size: 34,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Failed to load bookings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
              ),
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Icon(
                Icons.receipt_long_outlined,
                size: 44,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'No booking history',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Your bookings will appear here',
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    final status = booking['booking_status'] ?? booking['status'] ?? 'unknown';
    final venueName = booking['venue_name'] ?? 'Unknown Venue';
    final courtName = booking['court_name'] ?? 'Unknown Court';
    final date = _formatBookingDate(booking['booking_date']);
    final timeSlot = _formatTimeSlot(
      booking['time_slot'],
      startTime: booking['start_time'],
      endTime: booking['end_time'],
    );
    final totalPrice = booking['total_price'] ?? 0;

    final colorScheme = Theme.of(context).colorScheme;

    Color statusColor;
    IconData statusIcon;

    switch (status.toLowerCase()) {
      case 'confirmed':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = Icons.access_time;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help_outline;
    }

    final formattedPrice = _formatRupiah(totalPrice);

    return Material(
      color: colorScheme.surface,
      elevation: 0,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.18)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          venueName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          courtName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: statusColor.withOpacity(0.22)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 16, color: statusColor),
                        const SizedBox(width: 6),
                        Text(
                          status.toString().toUpperCase(),
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    _buildInfoRow(Icons.calendar_today, date),
                    const SizedBox(height: 8),
                    _buildInfoRow(Icons.access_time, timeSlot),
                  ],
                ),
              ),

              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Price',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    formattedPrice,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatRupiah(dynamic value) {
    final parsed = value is num
        ? value
        : num.tryParse(value?.toString() ?? '') ?? 0;
    return _rupiahFormatter.format(parsed);
  }

  String _formatBookingDate(dynamic value) {
    final raw = value?.toString().trim();
    if (raw == null || raw.isEmpty) return 'N/A';

    // Backend returns: "YYYY-MM-DD"
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return raw;

    final formatter = _dateFormatter;
    if (formatter == null) {
      // Fallback: keep backend date stable (prevents runtime crash)
      return raw;
    }
    return formatter.format(parsed);
  }

  String _formatTimeSlot(dynamic raw, {dynamic startTime, dynamic endTime}) {
    final rawSlot = raw?.toString().trim();
    if (rawSlot != null && rawSlot.isNotEmpty) return rawSlot;

    final start = startTime?.toString().trim();
    final end = endTime?.toString().trim();
    if (start != null && start.isNotEmpty && end != null && end.isNotEmpty) {
      return '$start - $end';
    }
    return 'N/A';
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 13, color: Colors.grey[800]),
          ),
        ),
      ],
    );
  }
}
