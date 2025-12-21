import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import '../../config/config.dart';
import '../../widgets/branded_app_bar.dart';

class _CheckoutSession {
  final int id;
  final String sessionName;
  final String startTime;
  final String endTime;
  final int durationMinutes;
  final bool isAvailable;

  const _CheckoutSession({
    required this.id,
    required this.sessionName,
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
    required this.isAvailable,
  });

  factory _CheckoutSession.fromJson(Map<String, dynamic> json) {
    return _CheckoutSession(
      id: (json['id'] as num).toInt(),
      sessionName: (json['session_name'] ?? '').toString(),
      startTime: (json['start_time'] ?? '').toString(),
      endTime: (json['end_time'] ?? '').toString(),
      durationMinutes: (json['duration'] as num?)?.toInt() ?? 0,
      isAvailable: json['is_available'] == true,
    );
  }
}

class _PaymentMethod {
  final String id;
  final String name;
  final String description;
  final IconData icon;

  const _PaymentMethod({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
  });
}

class BookingCheckoutPage extends StatefulWidget {
  final int courtId;
  final String courtName;
  final String venueName;
  final DateTime bookingDate;
  final List<int> sessionIds;

  const BookingCheckoutPage({
    super.key,
    required this.courtId,
    required this.courtName,
    required this.venueName,
    required this.bookingDate,
    required this.sessionIds,
  });

  @override
  State<BookingCheckoutPage> createState() => _BookingCheckoutPageState();
}

class _BookingCheckoutPageState extends State<BookingCheckoutPage> {
  bool _isLoading = true;
  String _error = '';

  List<_CheckoutSession> _selectedSessions = const [];
  double _pricePerHour = 0;

  String? _selectedPaymentMethod;
  final TextEditingController _notesController = TextEditingController();

  final List<_PaymentMethod> _paymentMethods = const [
    _PaymentMethod(
      id: 'bank_transfer',
      name: 'Bank Transfer',
      description: 'Transfer to bank account',
      icon: Icons.account_balance_outlined,
    ),
    _PaymentMethod(
      id: 'e_wallet',
      name: 'E-Wallet',
      description: 'GoPay, OVO, Dana, etc',
      icon: Icons.account_balance_wallet_outlined,
    ),
    _PaymentMethod(
      id: 'credit_card',
      name: 'Credit Card',
      description: 'Visa, Mastercard',
      icon: Icons.credit_card_outlined,
    ),
    _PaymentMethod(
      id: 'cash',
      name: 'Cash',
      description: 'Pay at venue',
      icon: Icons.payments_outlined,
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCheckoutData();
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  String _formatDateYmd(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  String _formatCurrency(num value) {
    final f = NumberFormat.decimalPattern('id_ID');
    return 'Rp ${f.format(value)}';
  }

  double _priceForSession(_CheckoutSession session) {
    if (_pricePerHour <= 0) return 0;
    return _pricePerHour * (session.durationMinutes / 60.0);
  }

  double _totalPrice() {
    double total = 0;
    for (final s in _selectedSessions) {
      total += _priceForSession(s);
    }
    return total;
  }

  Future<void> _loadCheckoutData() async {
    setState(() {
      _isLoading = true;
      _error = '';
      _selectedSessions = const [];
      _pricePerHour = 0;
    });

    try {
      final request = context.read<CookieRequest>();
      final dateStr = _formatDateYmd(widget.bookingDate);
      final url =
          '${AppConfig.baseUrl}${AppConfig.courtsEndpoint}${widget.courtId}/sessions/?date=$dateStr';
      final response = await request.get(url);

      if (!mounted) return;

      if (response is! Map || response['success'] != true) {
        setState(() {
          _isLoading = false;
          _error = (response is Map && response['message'] != null)
              ? response['message'].toString()
              : 'Failed to load booking details';
        });
        return;
      }

      final data = response['data'];
      final sessionsRaw = (data is Map) ? (data['sessions'] as List?) : null;
      final allSessions = (sessionsRaw ?? const [])
          .whereType<Map>()
          .map((s) => _CheckoutSession.fromJson(Map<String, dynamic>.from(s)))
          .toList();

      final priceRaw = (data is Map) ? data['price_per_hour'] : null;
      final price = (priceRaw is num) ? priceRaw.toDouble() : 0.0;

      final wanted = widget.sessionIds.toSet();
      final chosen = allSessions.where((s) => wanted.contains(s.id)).toList();

      // Validate: all selected sessions still exist and are available.
      final missing = wanted.difference(chosen.map((e) => e.id).toSet());
      final unavailable = chosen.where((s) => !s.isAvailable).toList();

      if (missing.isNotEmpty || unavailable.isNotEmpty) {
        setState(() {
          _isLoading = false;
          _error =
              'Some selected sessions are no longer available. Please go back and pick again.';
        });
        return;
      }

      setState(() {
        _selectedSessions = chosen;
        _pricePerHour = price;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'Failed to load booking details: ${e.toString()}';
      });
    }
  }

  bool _canConfirm() {
    return !_isLoading &&
        _error.isEmpty &&
        _selectedSessions.isNotEmpty &&
        _selectedPaymentMethod != null;
  }

  Future<void> _confirmBooking() async {
    if (!_canConfirm()) return;

    final dateStr = _formatDateYmd(widget.bookingDate);
    final total = _totalPrice();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Booking'),
          content: Text(
            'Venue: ${widget.venueName}\n'
            'Court: ${widget.courtName}\n'
            'Date: $dateStr\n'
            'Sessions: ${_selectedSessions.length}\n'
            'Total: ${_formatCurrency(total)}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Pay & Book'),
            ),
          ],
        );
      },
    );

    if (!mounted) return;
    if (confirmed != true) return;

    try {
      final request = context.read<CookieRequest>();
      final url = '${AppConfig.baseUrl}${AppConfig.bookingCreateEndpoint}';

      final payload = {
        'court_id': widget.courtId,
        'session_ids': _selectedSessions.map((s) => s.id).toList(),
        'booking_date': dateStr,
        'payment_method': _selectedPaymentMethod,
        'notes': _notesController.text.trim(),
        // Match the web checkout flow: confirm payment immediately.
        'auto_confirm': true,
      };

      final response = await request.postJson(url, jsonEncode(payload));
      if (!mounted) return;

      if (response is Map && response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking created successfully.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
        return;
      }

      final msg = (response is Map && response['message'] != null)
          ? response['message'].toString()
          : 'Failed to create booking';

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Booking failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildLoading() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 56, color: Colors.red.shade400),
            const SizedBox(height: 12),
            const Text(
              'Checkout Error',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Go Back'),
                ),
                const SizedBox(width: 12),
                FilledButton.tonal(
                  onPressed: _loadCheckoutData,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard() {
    final dateStr = DateFormat(
      'EEEE, d MMMM y',
      'id_ID',
    ).format(widget.bookingDate);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
            'Booking Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 12),
          _infoRow(Icons.location_on_outlined, 'Venue', widget.venueName),
          const SizedBox(height: 8),
          _infoRow(Icons.sports_tennis_outlined, 'Court', widget.courtName),
          const SizedBox(height: 8),
          _infoRow(Icons.calendar_today_outlined, 'Date', dateStr),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: const Color(0xFF6B7280)),
        const SizedBox(width: 10),
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
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sessionsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Row(
            children: [
              const Text(
                'Sessions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${_selectedSessions.length} selected',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._selectedSessions.map((s) {
            final price = _priceForSession(s);
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                border: Border.all(color: const Color(0xFFE5E7EB)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.schedule,
                      size: 18,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (s.sessionName.isNotEmpty)
                              ? s.sessionName
                              : 'Session',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111827),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${s.startTime} - ${s.endTime} • ${s.durationMinutes} min',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _formatCurrency(price),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _paymentCard() {
    final selected = _selectedPaymentMethod;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
            'Payment Method',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 12),
          ..._paymentMethods.map((m) {
            final isSelected = selected == m.id;
            return InkWell(
              onTap: () {
                setState(() => _selectedPaymentMethod = m.id);
              },
              borderRadius: BorderRadius.circular(14),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.08)
                      : const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : const Color(0xFFE5E7EB),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.15)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Icon(
                        m.icon,
                        size: 20,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            m.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            m.description,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : const Color(0xFFD1D5DB),
                          width: 2,
                        ),
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.transparent,
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              size: 14,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 8),
          TextField(
            controller: _notesController,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: 'Notes (optional)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomBar() {
    final total = _totalPrice();

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -6),
              spreadRadius: -8,
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatCurrency(total),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF111827),
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),
            FilledButton.icon(
              onPressed: _canConfirm() ? _confirmBooking : null,
              icon: const Icon(Icons.lock_outline),
              label: const Text('Confirm & Pay'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: const BrandedAppBar(title: Text('Checkout')),
      body: _isLoading
          ? _buildLoading()
          : _error.isNotEmpty
          ? _buildError()
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
              child: Column(
                children: [
                  _summaryCard(),
                  const SizedBox(height: 14),
                  _sessionsCard(),
                  const SizedBox(height: 14),
                  _paymentCard(),
                ],
              ),
            ),
      bottomNavigationBar: _isLoading || _error.isNotEmpty
          ? null
          : _bottomBar(),
    );
  }
}
