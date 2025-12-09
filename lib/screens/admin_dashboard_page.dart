import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/venue_model.dart';
import '../services/venue_service.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage>
    with SingleTickerProviderStateMixin {
  final VenueService _venueService = VenueService();

  late TabController _tabController;
  List<User> _pendingMitras = [];
  List<Venue> _pendingVenues = [];
  Map<String, dynamic>? _stats;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // TODO: Implement actual API calls
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call

      // Mock data
      setState(() {
        _pendingMitras = [];
        _pendingVenues = [];
        _stats = {
          'total_users': 150,
          'total_mitras': 25,
          'total_venues': 45,
          'total_bookings': 320,
          'pending_mitras': 5,
          'pending_venues': 8,
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _approveMitra(String userId) async {
    try {
      // TODO: Implement API call
      await Future.delayed(const Duration(milliseconds: 500));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mitra approved successfully')),
      );
      _loadData();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to approve mitra: $e')));
    }
  }

  Future<void> _rejectMitra(String userId) async {
    try {
      // TODO: Implement API call
      await Future.delayed(const Duration(milliseconds: 500));

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Mitra rejected')));
      _loadData();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to reject mitra: $e')));
    }
  }

  Future<void> _verifyVenue(String venueId) async {
    try {
      await _venueService.verifyVenue(venueId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Venue verified successfully')),
      );
      _loadData();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to verify venue: $e')));
    }
  }

  Future<void> _rejectVenue(String venueId, String reason) async {
    try {
      // TODO: Implement API call with reason
      await Future.delayed(const Duration(milliseconds: 500));

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Venue rejected')));
      _loadData();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to reject venue: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Statistics', icon: Icon(Icons.analytics)),
            Tab(text: 'Mitra Requests', icon: Icon(Icons.person_add)),
            Tab(text: 'Venue Approvals', icon: Icon(Icons.approval)),
          ],
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(_error!),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadData, child: const Text('Retry')),
          ],
        ),
      );
    }

    return TabBarView(
      controller: _tabController,
      children: [_buildStatsTab(), _buildMitrasTab(), _buildVenuesTab()],
    );
  }

  Widget _buildStatsTab() {
    if (_stats == null) {
      return const Center(child: Text('No statistics available'));
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Users',
                  _stats!['total_users'].toString(),
                  Icons.people,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Total Mitras',
                  _stats!['total_mitras'].toString(),
                  Icons.business,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Venues',
                  _stats!['total_venues'].toString(),
                  Icons.location_city,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Total Bookings',
                  _stats!['total_bookings'].toString(),
                  Icons.event,
                  Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Pending Mitras',
                  _stats!['pending_mitras'].toString(),
                  Icons.pending_actions,
                  Colors.red,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Pending Venues',
                  _stats!['pending_venues'].toString(),
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
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMitrasTab() {
    if (_pendingMitras.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.done_all, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No pending mitra requests',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _pendingMitras.length,
        itemBuilder: (context, index) {
          final mitra = _pendingMitras[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        child: Text(mitra.username[0].toUpperCase()),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              mitra.username,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              mitra.email,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _approveMitra(mitra.id),
                          icon: const Icon(Icons.check),
                          label: const Text('Approve'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _rejectMitra(mitra.id),
                          icon: const Icon(Icons.close),
                          label: const Text('Reject'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVenuesTab() {
    if (_pendingVenues.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.done_all, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No pending venue approvals',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _pendingVenues.length,
        itemBuilder: (context, index) {
          final venue = _pendingVenues[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    venue.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    venue.address,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  if (venue.description != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      venue.description!,
                      style: TextStyle(color: Colors.grey[600]),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _verifyVenue(venue.id),
                          icon: const Icon(Icons.check),
                          label: const Text('Verify'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final reason = await showDialog<String>(
                              context: context,
                              builder: (context) => _buildRejectDialog(),
                            );
                            if (reason != null && reason.isNotEmpty) {
                              _rejectVenue(venue.id, reason);
                            }
                          },
                          icon: const Icon(Icons.close),
                          label: const Text('Reject'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRejectDialog() {
    final TextEditingController reasonController = TextEditingController();

    return AlertDialog(
      title: const Text('Reject Venue'),
      content: TextField(
        controller: reasonController,
        decoration: const InputDecoration(
          labelText: 'Rejection Reason',
          hintText: 'Enter reason for rejection',
          border: OutlineInputBorder(),
        ),
        maxLines: 3,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, reasonController.text);
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Reject'),
        ),
      ],
    );
  }
}
