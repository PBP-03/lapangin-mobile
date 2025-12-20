import 'package:flutter/material.dart';
import 'package:lapangin_mobile/constants/api_constants.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class BookingDetailPage extends StatefulWidget {
  final String bookingId;

  const BookingDetailPage({super.key, required this.bookingId});

  @override
  State<BookingDetailPage> createState() => _BookingDetailPageState();
}

class _BookingDetailPageState extends State<BookingDetailPage> {
  bool _isLoading = true;
  Map<String, dynamic>? _booking;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadBookingDetail();
  }

  Future<void> _loadBookingDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final request = context.read<CookieRequest>();
      final response = await request.get(
        '${ApiConstants.baseUrl}/api/bookings/${widget.bookingId}/',
      );

      if (response['success'] == true) {
        setState(() {
          _booking = response['data'];
          _isLoading = false;
        });
      } else {
        throw Exception(response['message'] ?? 'Failed to load booking');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _updateBookingStatus(String status) async {
    try {
      final request = context.read<CookieRequest>();
      final response = await request.post(
        '${ApiConstants.baseUrl}/api/bookings/${widget.bookingId}/',
        {'booking_status': status},
      );

      if (response['success'] == true) {
        await _loadBookingDetail();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Status berhasil diubah menjadi $status'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception(response['message'] ?? 'Failed to update status');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
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

  String _formatCurrency(String amount) {
    final number = double.tryParse(amount) ?? 0;
    return 'Rp ${number.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Text('Detail Booking'),
        backgroundColor: const Color(0xFF5409DA),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: $_errorMessage'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadBookingDetail,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _getStatusColor(
                        _booking!['booking_status'],
                      ).withOpacity(0.1),
                      border: Border(
                        bottom: BorderSide(
                          color: _getStatusColor(_booking!['booking_status']),
                          width: 3,
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          _booking!['booking_status'] == 'confirmed'
                              ? Icons.check_circle
                              : _booking!['booking_status'] == 'completed'
                              ? Icons.check_circle_outline
                              : _booking!['booking_status'] == 'cancelled'
                              ? Icons.cancel
                              : Icons.pending,
                          size: 64,
                          color: _getStatusColor(_booking!['booking_status']),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _getStatusLabel(_booking!['booking_status']),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: _getStatusColor(_booking!['booking_status']),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Booking Information
                  _buildSection('Informasi Booking', [
                    _buildInfoRow(
                      Icons.receipt,
                      'ID Booking',
                      _booking!['id'].toString().substring(0, 8),
                    ),
                    _buildInfoRow(
                      Icons.business,
                      'Venue',
                      _booking!['venue_name'],
                    ),
                    _buildInfoRow(
                      Icons.sports_soccer,
                      'Lapangan',
                      _booking!['court_name'],
                    ),
                    _buildInfoRow(
                      Icons.calendar_today,
                      'Tanggal',
                      _booking!['booking_date'],
                    ),
                    _buildInfoRow(
                      Icons.access_time,
                      'Waktu',
                      '${_booking!['start_time']} - ${_booking!['end_time']}',
                    ),
                    _buildInfoRow(
                      Icons.timer,
                      'Durasi',
                      '${_booking!['duration_hours']} jam',
                    ),
                    _buildInfoRow(
                      Icons.attach_money,
                      'Total Harga',
                      _formatCurrency(_booking!['total_price']),
                      isHighlight: true,
                    ),
                  ]),

                  // Customer Information
                  _buildSection('Informasi Pelanggan', [
                    _buildInfoRow(
                      Icons.person,
                      'Nama',
                      _booking!['customer_name'],
                    ),
                    _buildInfoRow(
                      Icons.email,
                      'Email',
                      _booking!['customer_email'],
                    ),
                    _buildInfoRow(
                      Icons.phone,
                      'Telepon',
                      _booking!['customer_phone'] ?? '-',
                    ),
                  ]),

                  // Payment Information
                  if (_booking!['payment'] != null)
                    _buildSection('Informasi Pembayaran', [
                      _buildInfoRow(
                        Icons.payment,
                        'Metode',
                        _booking!['payment']['method'] ?? '-',
                      ),
                      _buildInfoRow(
                        Icons.receipt_long,
                        'Transaction ID',
                        _booking!['payment']['transaction_id'] ?? '-',
                      ),
                      _buildInfoRow(
                        Icons.event,
                        'Dibayar pada',
                        _booking!['payment']['paid_at'] ?? '-',
                      ),
                      if (_booking!['payment']['has_proof'] == true)
                        _buildInfoRow(
                          Icons.image,
                          'Bukti Pembayaran',
                          'Tersedia',
                          trailing: TextButton(
                            onPressed: () {
                              // TODO: Show payment proof image
                            },
                            child: const Text('Lihat'),
                          ),
                        ),
                    ]),

                  // Notes
                  if (_booking!['notes'] != null &&
                      _booking!['notes'].toString().isNotEmpty)
                    _buildSection('Catatan', [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          _booking!['notes'],
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ]),

                  // Action Buttons
                  if (_booking!['booking_status'] == 'pending')
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () =>
                                  _updateBookingStatus('cancelled'),
                              icon: const Icon(Icons.cancel),
                              label: const Text('Tolak'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(color: Colors.red),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () =>
                                  _updateBookingStatus('confirmed'),
                              icon: const Icon(Icons.check_circle),
                              label: const Text('Terima'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF5409DA),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  if (_booking!['booking_status'] == 'confirmed')
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _updateBookingStatus('completed'),
                          icon: const Icon(Icons.check),
                          label: const Text('Tandai Selesai'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E5E5), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    bool isHighlight = false,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isHighlight
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isHighlight
                        ? const Color(0xFF5409DA)
                        : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }
}
