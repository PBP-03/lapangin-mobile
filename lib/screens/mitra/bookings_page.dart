import 'package:flutter/material.dart';
import 'package:lapangin_mobile/constants/api_constants.dart';
import 'package:lapangin_mobile/screens/mitra/booking_detail_page.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:lapangin_mobile/widgets/branded_app_bar.dart';

class BookingsPage extends StatefulWidget {
  const BookingsPage({super.key});

  @override
  State<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _bookings = [];
  String _selectedStatus = 'all';

  Map<String, int> _stats = {
    'total': 0,
    'pending': 0,
    'confirmed': 0,
    'completed': 0,
    'cancelled': 0,
  };

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final request = context.read<CookieRequest>();
      final response = await request.get(
        '${ApiConstants.baseUrl}/api/bookings/',
      );

      if (response['success'] == true) {
        if (!mounted) return;
        setState(() {
          _bookings = (response['data']['bookings'] as List).map((booking) {
            return {
              'id': booking['id'],
              'user_name': booking['customer_name'],
              'user_email': booking['customer_email'],
              'user_phone': booking['customer_phone'],
              'lapangan': booking['court_name'],
              'venue': booking['venue_name'],
              'venue_id': booking['venue_id'],
              'court_id': booking['court_id'],
              'date': booking['booking_date'],
              'time': '${booking['start_time']} - ${booking['end_time']}',
              'start_time': booking['start_time'],
              'end_time': booking['end_time'],
              'total_price':
                  int.tryParse(
                    booking['total_price'].toString().split('.')[0],
                  ) ??
                  0,
              'status': booking['booking_status'],
              'payment_status': booking['payment_status'],
              'notes': booking['notes'],
            };
          }).toList();

          if (response['data']['statistics'] != null) {
            final stats = response['data']['statistics'];
            _stats = {
              'total': stats['total'] ?? 0,
              'pending': stats['pending'] ?? 0,
              'confirmed': stats['confirmed'] ?? 0,
              'completed': stats['completed'] ?? 0,
              'cancelled': stats['cancelled'] ?? 0,
            };
          } else {
            _calculateStats();
          }

          _isLoading = false;
        });
      } else {
        throw Exception(response['message'] ?? 'Failed to load bookings');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _bookings = [];
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading bookings: $e')));
    }
  }

  void _calculateStats() {
    _stats = {
      'total': _bookings.length,
      'pending': _bookings.where((b) => b['status'] == 'pending').length,
      'confirmed': _bookings.where((b) => b['status'] == 'confirmed').length,
      'completed': _bookings.where((b) => b['status'] == 'completed').length,
      'cancelled': _bookings.where((b) => b['status'] == 'cancelled').length,
    };
  }

  Future<void> _updateBookingStatus(String bookingId, String status) async {
    try {
      final request = context.read<CookieRequest>();
      final response = await request.post(
        '${ApiConstants.baseUrl}/api/bookings/$bookingId/',
        {'_method': 'POST', 'booking_status': status},
      );

      if (response['success'] == true) {
        await _loadBookings();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                status == 'confirmed'
                    ? 'Booking berhasil dikonfirmasi'
                    : 'Booking berhasil ditolak',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception(response['message'] ?? 'Failed to update booking');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  List<Map<String, dynamic>> get _filteredBookings {
    if (_selectedStatus == 'all') return _bookings;
    return _bookings.where((b) => b['status'] == _selectedStatus).toList();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return const Color(0xFF5409DA);
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'confirmed':
        return 'Dikonfirmasi';
      case 'completed':
        return 'Selesai';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BrandedAppBar(title: Text('Kelola Booking')),
      body: RefreshIndicator(
        onRefresh: _loadBookings,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildStatsCards()),
            if (_isLoading)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_filteredBookings.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Container(
                  color: const Color(0xFFFAFAFA),
                  child: _buildEmptyState(),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final booking = _filteredBookings[index];
                    return _buildBookingCard(booking);
                  }, childCount: _filteredBookings.length),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF5409DA), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total',
                  _stats['total'].toString(),
                  Icons.receipt_long,
                  Colors.blue,
                  'all',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'Pending',
                  _stats['pending'].toString(),
                  Icons.pending,
                  Colors.orange,
                  'pending',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Dikonfirmasi',
                  _stats['confirmed'].toString(),
                  Icons.check_circle,
                  const Color(0xFF5409DA),
                  'confirmed',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'Selesai',
                  _stats['completed'].toString(),
                  Icons.check,
                  Colors.green,
                  'completed',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildStatCard(
            'Dibatalkan',
            _stats['cancelled'].toString(),
            Icons.cancel,
            Colors.red,
            'cancelled',
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
    String status,
  ) {
    final isSelected = _selectedStatus == status;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedStatus = status;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.15)
              : Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'Belum ada booking',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedStatus == 'all'
                ? 'Belum ada booking masuk'
                : 'Tidak ada booking dengan status ${_getStatusLabel(_selectedStatus).toLowerCase()}',
            style: const TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE5E5E5), width: 1),
      ),
      child: InkWell(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  BookingDetailPage(bookingId: booking['id'].toString()),
            ),
          );
          _loadBookings();
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking['user_name'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${booking['venue']} - ${booking['lapangan']}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(
                        booking['status'],
                      ).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _getStatusColor(booking['status']),
                      ),
                    ),
                    child: Text(
                      _getStatusLabel(booking['status']),
                      style: TextStyle(
                        color: _getStatusColor(booking['status']),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(booking['date']),
                  const SizedBox(width: 16),
                  const Icon(Icons.access_time, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(booking['time']),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.payments, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    'Rp ${booking['total_price']}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5409DA),
                    ),
                  ),
                ],
              ),
              if (booking['status'] == 'pending') ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _updateBookingStatus(
                          booking['id'].toString(),
                          'cancelled',
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                        ),
                        child: const Text('Tolak'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _updateBookingStatus(
                          booking['id'].toString(),
                          'confirmed',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5409DA),
                        ),
                        child: const Text('Terima'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
