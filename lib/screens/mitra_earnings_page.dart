import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MitraEarningsPage extends StatefulWidget {
  const MitraEarningsPage({super.key});

  @override
  State<MitraEarningsPage> createState() => _MitraEarningsPageState();
}

class _MitraEarningsPageState extends State<MitraEarningsPage> {
  bool _isLoading = true;
  double _totalEarnings = 0.0;
  List<Map<String, dynamic>> _transactions = [];

  @override
  void initState() {
    super.initState();
    _loadEarnings();
  }

  Future<void> _loadEarnings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Implement actual API call
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call

      // Mock data
      setState(() {
        _totalEarnings = 5000000.0;
        _transactions = [
          {
            'venue': 'GOR Sudirman',
            'court': 'Court A',
            'customer': 'John Doe',
            'date': DateTime.now().subtract(const Duration(days: 1)),
            'amount': 150000.0,
          },
          {
            'venue': 'GOR Sudirman',
            'court': 'Court B',
            'customer': 'Jane Smith',
            'date': DateTime.now().subtract(const Duration(days: 2)),
            'amount': 200000.0,
          },
        ];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading earnings: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Earnings')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Total Earnings Card
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Total Earnings',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Rp ${NumberFormat('#,###').format(_totalEarnings)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // Transactions List
                Expanded(
                  child: _transactions.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.receipt_long,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No transactions yet',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _transactions.length,
                          itemBuilder: (context, index) {
                            final transaction = _transactions[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.green[100],
                                  child: Icon(
                                    Icons.attach_money,
                                    color: Colors.green[700],
                                  ),
                                ),
                                title: Text(
                                  '${transaction['venue']} - ${transaction['court']}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  'Customer: ${transaction['customer']}\n${DateFormat('dd MMM yyyy').format(transaction['date'])}',
                                ),
                                isThreeLine: true,
                                trailing: Text(
                                  'Rp ${NumberFormat('#,###').format(transaction['amount'])}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
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
}
