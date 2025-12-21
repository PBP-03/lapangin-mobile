import 'package:flutter/material.dart';
import 'package:lapangin_mobile/constants/api_constants.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:lapangin_mobile/widgets/branded_app_bar.dart';

class PendapatanPage extends StatefulWidget {
  const PendapatanPage({super.key});

  @override
  State<PendapatanPage> createState() => _PendapatanPageState();
}

class _PendapatanPageState extends State<PendapatanPage> {
  bool _isLoading = true;
  String _selectedPeriod = 'month';

  Map<String, dynamic> _stats = {
    'total_pendapatan': 0,
    'total_commission': 0,
    'paid_amount': 0,
    'pending_amount': 0,
  };

  List<Map<String, dynamic>> _transactions = [];

  @override
  void initState() {
    super.initState();
    _loadPendapatan();
  }

  Future<void> _loadPendapatan() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final request = context.read<CookieRequest>();
      final url =
          '${ApiConstants.baseUrl}/api/pendapatan/?period=$_selectedPeriod';
      final response = await request.get(url);

      if (response['success'] == true) {
        if (!mounted) return;
        setState(() {
          final stats = response['data']['statistics'];
          _stats = {
            'total_pendapatan':
                int.tryParse(
                  stats['total_pendapatan'].toString().split('.')[0],
                ) ??
                0,
            'total_commission':
                int.tryParse(
                  stats['total_commission'].toString().split('.')[0],
                ) ??
                0,
            'paid_amount':
                int.tryParse(stats['paid_amount'].toString().split('.')[0]) ??
                0,
            'pending_amount':
                int.tryParse(
                  stats['pending_amount'].toString().split('.')[0],
                ) ??
                0,
          };

          _transactions = (response['data']['pendapatan_list'] as List).map((
            p,
          ) {
            return {
              'id': p['id'],
              'date': p['booking_date'],
              'user_name': p['venue_name'],
              'lapangan': p['court_name'],
              'amount': int.tryParse(p['amount'].toString().split('.')[0]) ?? 0,
              'commission':
                  int.tryParse(
                    p['commission_amount'].toString().split('.')[0],
                  ) ??
                  0,
              'net_amount':
                  int.tryParse(p['net_amount'].toString().split('.')[0]) ?? 0,
              'status': p['payment_status'],
            };
          }).toList();

          _isLoading = false;
        });
      } else {
        throw Exception(response['message'] ?? 'Failed to load revenue data');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _stats = {
          'total_pendapatan': 0,
          'total_commission': 0,
          'paid_amount': 0,
          'pending_amount': 0,
        };
        _transactions = [];
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading revenue: $e')));
    }
  }

  String _formatCurrency(int amount) {
    return 'Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: BrandedAppBar(
        title: const Text('Pendapatan & Keuangan'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: DropdownButton<String>(
              value: _selectedPeriod,
              dropdownColor: Colors.white,
              style: const TextStyle(color: Color(0xFF5409DA)),
              underline: Container(),
              icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF5409DA)),
              items: const [
                DropdownMenuItem(value: 'all', child: Text('Semua Waktu')),
                DropdownMenuItem(
                  value: 'month',
                  child: Text('30 Hari Terakhir'),
                ),
                DropdownMenuItem(
                  value: 'year',
                  child: Text('1 Tahun Terakhir'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedPeriod = value!;
                });
                _loadPendapatan();
              },
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [_buildStatsCards(), _buildTransactionsList()],
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
                  'Total Pendapatan',
                  _formatCurrency(_stats['total_pendapatan']),
                  'Setelah komisi platform',
                  Icons.account_balance_wallet,
                  const Color(0xFF5409DA),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Total Komisi',
                  _formatCurrency(_stats['total_commission']),
                  'Biaya platform',
                  Icons.calculate,
                  Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Sudah Dibayar',
                  _formatCurrency(_stats['paid_amount']),
                  'Pembayaran selesai',
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Pending',
                  _formatCurrency(_stats['pending_amount']),
                  'Menunggu pembayaran',
                  Icons.pending,
                  Colors.amber,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 10, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E5E5), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Transaksi Terbaru',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _transactions.length,
            separatorBuilder: (context, index) => const Divider(height: 24),
            itemBuilder: (context, index) {
              final transaction = _transactions[index];
              final isPaid = transaction['status'] == 'paid';

              return Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: (isPaid ? Colors.green : Colors.amber).withOpacity(
                        0.1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isPaid ? Icons.check_circle : Icons.pending,
                      color: isPaid ? Colors.green : Colors.amber,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transaction['user_name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          transaction['lapangan'],
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          transaction['date'],
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
                        _formatCurrency(transaction['net_amount']),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Color(0xFF5409DA),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Komisi: ${_formatCurrency(transaction['commission'])}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: (isPaid ? Colors.green : Colors.amber)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isPaid ? Colors.green : Colors.amber,
                          ),
                        ),
                        child: Text(
                          isPaid ? 'Dibayar' : 'Pending',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isPaid ? Colors.green : Colors.amber,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
