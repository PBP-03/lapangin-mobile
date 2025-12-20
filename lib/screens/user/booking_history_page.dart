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
  Map<String, int> _stats = const {};
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
          _stats = _calculateStatsFromBookings(_bookings);
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
            _stats = _calculateStatsFromBookings(_bookings);
            _isLoading = false;
          });
          return;
        }

        final data = response['data'];
        if (data is Map && data['bookings'] is List) {
          setState(() {
            _bookings = List<dynamic>.from(data['bookings'] as List);
            final rawStats = data['statistics'];
            _stats = rawStats is Map
                ? _sanitizeStats(rawStats)
                : _calculateStatsFromBookings(_bookings);
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
        title: const Text('Riwayat Booking'),
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
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                      child: _buildSummarySection(context),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    sliver: SliverList.separated(
                      itemCount: _bookings.length,
                      itemBuilder: (context, index) {
                        final booking = _bookings[index];
                        if (booking is Map<String, dynamic>) {
                          return _buildBookingCard(booking);
                        }
                        return _buildUnexpectedItemCard(context);
                      },
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSummarySection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final total = _stats['total'] ?? _bookings.length;
    final pending = _stats['pending'] ?? 0;
    final confirmed = _stats['confirmed'] ?? 0;
    final completed = _stats['completed'] ?? 0;
    final cancelled = _stats['cancelled'] ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.analytics_outlined, color: colorScheme.primary),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Ringkasan Booking',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _StatChip(
              label: 'Total',
              value: total,
              color: colorScheme.primary,
              icon: Icons.receipt_long_outlined,
            ),
            _StatChip(
              label: 'Pending',
              value: pending,
              color: Colors.orange,
              icon: Icons.access_time,
            ),
            _StatChip(
              label: 'Confirmed',
              value: confirmed,
              color: Colors.blue,
              icon: Icons.check_circle_outline,
            ),
            _StatChip(
              label: 'Completed',
              value: completed,
              color: Colors.green,
              icon: Icons.verified,
            ),
            _StatChip(
              label: 'Cancelled',
              value: cancelled,
              color: Colors.red,
              icon: Icons.cancel_outlined,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUnexpectedItemCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.18)),
        ),
        child: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: colorScheme.primary),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Unexpected booking item format',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
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
    final venueName = (booking['venue_name'] ?? 'Unknown Venue').toString();
    final courtName = (booking['court_name'] ?? 'Unknown Court').toString();
    final sessionName = booking['session_name']?.toString();

    final statusRaw =
        (booking['booking_status'] ?? booking['status'] ?? 'unknown')
            .toString()
            .toLowerCase();
    final paymentRaw =
        (booking['payment_status'] ??
                booking['payment']?['status'] ??
                'unknown')
            .toString()
            .toLowerCase();

    final date = _formatBookingDate(booking['booking_date']);
    final timeSlot = _formatTimeSlot(
      booking['time_slot'],
      startTime: booking['start_time'],
      endTime: booking['end_time'],
    );
    final duration = _formatDurationHours(booking['duration_hours']);
    final totalPrice = booking['total_price'] ?? 0;
    final notes = booking['notes']?.toString().trim();

    final isCancellable = booking['is_cancellable'] == true;
    final bookingId = booking['id']?.toString();

    final colorScheme = Theme.of(context).colorScheme;

    final statusUi = _statusUi(statusRaw);
    final paymentUi = _paymentUi(paymentRaw);
    final formattedPrice = _formatRupiah(totalPrice);

    final imageUrl = _extractBookingImageUrl(booking);
    final resolvedImageUrl = _resolveImageUrl(imageUrl);

    return Material(
      color: colorScheme.surface,
      elevation: 0,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.withOpacity(0.18)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.045),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _BookingImageHeader(
              imageUrl: resolvedImageUrl,
              sessionName: sessionName,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final isNarrow = constraints.maxWidth < 320;

                            final titleBlock = Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  venueName,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
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
                            );

                            final chipBlock = Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              alignment: WrapAlignment.end,
                              children: [
                                _PillChip(
                                  icon: statusUi.icon,
                                  label: statusUi.label,
                                  color: statusUi.color,
                                ),
                                _PillChip(
                                  icon: paymentUi.icon,
                                  label: paymentUi.label,
                                  color: paymentUi.color,
                                ),
                              ],
                            );

                            if (!isNarrow) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: titleBlock),
                                  const SizedBox(width: 12),
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: chipBlock,
                                  ),
                                ],
                              );
                            }

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                titleBlock,
                                const SizedBox(height: 10),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: chipBlock,
                                ),
                              ],
                            );
                          },
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
                        const SizedBox(height: 8),
                        _buildInfoRow(Icons.timer_outlined, duration),
                      ],
                    ),
                  ),

                  if (notes != null && notes.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.14),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Catatan',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            notes,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[850],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Harga',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        formattedPrice,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: isCancellable && bookingId != null
                        ? FilledButton.icon(
                            onPressed: () => _showCancelDialog(bookingId),
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.red.withOpacity(0.10),
                              foregroundColor: Colors.red,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                                side: BorderSide(
                                  color: Colors.red.withOpacity(0.18),
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            icon: const Icon(Icons.cancel_outlined, size: 18),
                            label: const Text(
                              'Batalkan Pemesanan',
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                          )
                        : FilledButton.icon(
                            onPressed: null,
                            style: FilledButton.styleFrom(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            icon: const Icon(Icons.block, size: 18),
                            label: const Text(
                              'Tidak Bisa Dibatalkan',
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showCancelDialog(String bookingId) async {
    final reasonController = TextEditingController();
    final colorScheme = Theme.of(context).colorScheme;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Batalkan pemesanan?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Masukkan alasan pembatalan (opsional).'),
              const SizedBox(height: 12),
              TextField(
                controller: reasonController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Contoh: Berhalangan hadir',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Ya, Batalkan'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;
    await _cancelBooking(bookingId, reason: reasonController.text.trim());
  }

  Future<void> _cancelBooking(String bookingId, {String? reason}) async {
    try {
      final request = Provider.of<CookieRequest>(context, listen: false);
      final response = await request.post(
        AppConfig.buildUrl('/bookings/$bookingId/cancel/'),
        {'reason': (reason ?? '').trim()},
      );

      final ok = response is Map && response['success'] == true;
      final message = response is Map
          ? (response['message'] ?? 'Pemesanan berhasil dibatalkan').toString()
          : 'Pemesanan berhasil dibatalkan';

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: ok ? Colors.green : Colors.red,
        ),
      );

      if (ok) {
        await _fetchBookings();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal membatalkan pemesanan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  ({String label, Color color, IconData icon}) _statusUi(String raw) {
    switch (raw) {
      case 'pending':
        return (
          label: 'Menunggu',
          color: Colors.orange,
          icon: Icons.access_time,
        );
      case 'confirmed':
        return (
          label: 'Dikonfirmasi',
          color: Colors.blue,
          icon: Icons.check_circle,
        );
      case 'completed':
        return (label: 'Selesai', color: Colors.green, icon: Icons.verified);
      case 'cancelled':
        return (label: 'Dibatalkan', color: Colors.red, icon: Icons.cancel);
      default:
        return (
          label: raw.isEmpty ? 'Unknown' : raw,
          color: Colors.grey,
          icon: Icons.help_outline,
        );
    }
  }

  ({String label, Color color, IconData icon}) _paymentUi(String raw) {
    switch (raw) {
      case 'unpaid':
        return (
          label: 'Belum Dibayar',
          color: Colors.red,
          icon: Icons.payments_outlined,
        );
      case 'paid':
        return (
          label: 'Sudah Dibayar',
          color: Colors.green,
          icon: Icons.verified_outlined,
        );
      case 'refunded':
        return (
          label: 'Dikembalikan',
          color: Colors.blue,
          icon: Icons.reply_outlined,
        );
      default:
        return (
          label: raw.isEmpty ? 'Unknown' : raw,
          color: Colors.grey,
          icon: Icons.credit_card,
        );
    }
  }

  Map<String, int> _sanitizeStats(Map rawStats) {
    int toInt(dynamic v) =>
        v is int ? v : int.tryParse(v?.toString() ?? '') ?? 0;
    return {
      'total': toInt(rawStats['total']),
      'pending': toInt(rawStats['pending']),
      'confirmed': toInt(rawStats['confirmed']),
      'completed': toInt(rawStats['completed']),
      'cancelled': toInt(rawStats['cancelled']),
    };
  }

  Map<String, int> _calculateStatsFromBookings(List<dynamic> bookings) {
    int countWhere(String status) {
      return bookings.where((b) {
        if (b is! Map) return false;
        final s = (b['booking_status'] ?? b['status'] ?? '')
            .toString()
            .toLowerCase();
        return s == status;
      }).length;
    }

    return {
      'total': bookings.length,
      'pending': countWhere('pending'),
      'confirmed': countWhere('confirmed'),
      'completed': countWhere('completed'),
      'cancelled': countWhere('cancelled'),
    };
  }

  String _formatDurationHours(dynamic value) {
    final hours = value is num
        ? value.toDouble()
        : double.tryParse(value?.toString() ?? '') ?? 0;
    if (hours <= 0) return 'N/A';
    final totalMinutes = (hours * 60).round();
    if (totalMinutes < 60) return '$totalMinutes menit';
    final h = totalMinutes ~/ 60;
    final m = totalMinutes % 60;
    return m == 0 ? '$h jam' : '$h jam $m menit';
  }

  String _resolveImageUrl(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return '';

    // If it's already a proxy URL, keep it stable.
    if (trimmed.contains('/api/proxy-image/')) {
      if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
        return trimmed;
      }
      if (trimmed.startsWith('/')) {
        return AppConfig.buildUrl(trimmed);
      }
      return trimmed;
    }

    // Always use backend proxy to support:
    // - external images (avoid CORS issues on Flutter Web)
    // - local static paths like "/static/..."
    return AppConfig.buildProxyImageUrl(trimmed);
  }

  String _extractBookingImageUrl(Map<String, dynamic> booking) {
    String? normalize(dynamic v) {
      final s = v?.toString().trim();
      return (s == null || s.isEmpty) ? null : s;
    }

    final direct = normalize(booking['court_image']) ??
        normalize(booking['venue_image']) ??
        normalize(booking['image']);
    if (direct != null) return direct;

    final images = booking['images'];
    if (images is List && images.isNotEmpty) {
      final first = normalize(images.first);
      if (first != null) return first;
    }

    final venue = booking['venue'];
    if (venue is Map) {
      final vImages = venue['images'];
      if (vImages is List && vImages.isNotEmpty) {
        final first = normalize(vImages.first);
        if (first != null) return first;
      }
      final vDirect = normalize(venue['image']) ?? normalize(venue['primary_image']);
      if (vDirect != null) return vDirect;
    }

    return '';
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
      return '${_trimTime(start)} - ${_trimTime(end)}';
    }
    return 'N/A';
  }

  String _trimTime(String raw) {
    // Common backend formats: "HH:mm" or "HH:mm:ss".
    if (raw.length >= 5 && raw[2] == ':') {
      return raw.substring(0, 5);
    }
    return raw;
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

class _PillChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _PillChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w900,
                fontSize: 11,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingImageHeader extends StatelessWidget {
  final String imageUrl;
  final String? sessionName;

  const _BookingImageHeader({required this.imageUrl, this.sessionName});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final label = (sessionName ?? '').trim();

    return SizedBox(
      height: 156,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (imageUrl.isNotEmpty)
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, _, __) =>
                  _FallbackImage(color: colorScheme.primary),
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return _FallbackImage(color: colorScheme.primary);
              },
            )
          else
            _FallbackImage(color: colorScheme.primary),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.10),
                  Colors.black.withOpacity(0.30),
                ],
              ),
            ),
          ),
          if (label.isNotEmpty)
            Positioned(
              left: 12,
              top: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.92),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.black.withOpacity(0.06)),
                ),
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FallbackImage extends StatelessWidget {
  final Color color;

  const _FallbackImage({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color.withOpacity(0.10),
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: 46,
          color: color.withOpacity(0.75),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final IconData icon;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 12,
              color: color,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              value.toString(),
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: color,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
