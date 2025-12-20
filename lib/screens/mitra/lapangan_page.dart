import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lapangin_mobile/config/config.dart';
import 'package:lapangin_mobile/constants/api_constants.dart';
import 'package:lapangin_mobile/screens/mitra/lapangan_form_page.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class LapanganPage extends StatefulWidget {
  const LapanganPage({super.key});

  @override
  State<LapanganPage> createState() => _LapanganPageState();
}

class _LapanganPageState extends State<LapanganPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _lapangan = [];
  List<Map<String, dynamic>> _venues = [];
  String _selectedVenue = 'all';
  final _searchController = TextEditingController();

  // Days of week for court sessions
  final List<String> _daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  final List<String> _dayLabels = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];

  List<Map<String, dynamic>> get _filteredLapangan {
    var filtered = _lapangan;

    // Filter by venue
    if (_selectedVenue != 'all') {
      filtered = filtered
          .where((lap) => lap['venue_id'].toString() == _selectedVenue)
          .toList();
    }

    // Filter by search query
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered.where((lap) {
        return lap['name'].toLowerCase().contains(query) ||
            lap['venue'].toLowerCase().contains(query) ||
            lap['category'].toLowerCase().contains(query);
      }).toList();
    }

    return filtered;
  }

  @override
  void initState() {
    super.initState();
    _loadVenues();
    _loadLapangan();
  }

  Future<void> _loadVenues() async {
    try {
      final request = context.read<CookieRequest>();
      final response = await request.get('${ApiConstants.baseUrl}/api/venues/');

      if (response['success'] == true) {
        if (mounted) {
          setState(() {
            _venues = (response['data'] as List).map((venue) {
              return {'id': venue['id'], 'name': venue['name']};
            }).toList();
          });
        }
      }
    } catch (e) {
      print('❌ Error loading venues: $e');
    }
  }

  Future<void> _loadLapangan() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final request = context.read<CookieRequest>();
      final response = await request.get('${ApiConstants.baseUrl}/api/courts/');

      if (response['success'] == true) {
        if (mounted) {
          setState(() {
            _lapangan = (response['data'] as List).map((court) {
              // Parse price as double first to handle decimal strings like "150000.00"
              final priceValue =
                  double.tryParse(
                    court['price_per_hour'].toString(),
                  )?.toInt() ??
                  0;
              return {
                'id': court['id'],
                'name': court['name'],
                'venue': court['venue_name'],
                'category': court['category'] ?? 'Other',
                'price': priceValue,
                'price_per_hour': court['price_per_hour'],
                'status': court['is_active'] ? 'active' : 'inactive',
                'image': court['images'].isNotEmpty
                    ? court['images'][0]['url']
                    : 'https://via.placeholder.com/400x300',
                'venue_id': court['venue_id'],
              };
            }).toList();
            _isLoading = false;
          });
        }
        print('✅ Loaded ${_lapangan.length} courts from API');
      } else {
        throw Exception(response['message'] ?? 'Failed to load courts');
      }
    } catch (e) {
      print('❌ Error loading lapangan: $e');
      if (mounted) {
        setState(() {
          _lapangan = [];
          _isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading courts: $e')));
      }
    }
  }

  Future<void> _deleteLapangan(int lapanganId, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Yakin ingin menghapus lapangan "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final request = context.read<CookieRequest>();
        final response = await request.post(
          '${ApiConstants.baseUrl}/api/courts/$lapanganId/',
          {'_method': 'DELETE'},
        );

        if (response['success'] == true) {
          if (mounted) {
            await _loadLapangan();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Lapangan berhasil dihapus'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Lapangan'),
        backgroundColor: const Color(0xFF5409DA),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredLapangan.isEmpty
                ? _buildEmptyState()
                : _buildLapanganList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LapanganFormPage()),
          );
          if (result == true && mounted) {
            _loadLapangan();
          }
        },
        backgroundColor: const Color(0xFF5409DA),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Lapangan'),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedVenue,
                  decoration: InputDecoration(
                    labelText: 'Filter Venue',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF5409DA),
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: 'all',
                      child: Text('Semua Venue'),
                    ),
                    ..._venues.map((venue) {
                      return DropdownMenuItem(
                        value: venue['id'].toString(),
                        child: Text(venue['name']),
                      );
                    }).toList(),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedVenue = value!);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Cari lapangan (nama/kategori)...',
              prefixIcon: const Icon(Icons.search, color: Color(0xFF5409DA)),
              filled: true,
              fillColor: const Color(0xFFF5F5F5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF5409DA),
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                        });
                      },
                    )
                  : null,
            ),
            onChanged: (value) {
              setState(() {});
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sports_soccer, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'Belum ada lapangan',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Mulai tambahkan lapangan untuk venue Anda',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildLapanganList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredLapangan.length,
      itemBuilder: (context, index) {
        final lapangan = _filteredLapangan[index];
        return _buildLapanganCard(lapangan);
      },
    );
  }

  Widget _buildLapanganCard(Map<String, dynamic> lapangan) {
    final imageUrl = lapangan['image'] ?? '';
    final status = lapangan['status'];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE5E5E5), width: 1),
      ),
      elevation: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Header
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child:
                    imageUrl.isNotEmpty &&
                        imageUrl != 'https://via.placeholder.com/400x300'
                    ? Image.network(
                        AppConfig.buildProxyImageUrl(imageUrl),
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 180,
                            color: Colors.grey[200],
                            child: Center(
                              child: CircularProgressIndicator(
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 180,
                            color: Colors.grey[300],
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.broken_image,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Gambar tidak tersedia',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      )
                    : Container(
                        height: 180,
                        color: Colors.grey[300],
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.sports_soccer,
                              size: 48,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Belum ada foto',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
              // Status Badge
              Positioned(
                top: 12,
                right: 12,
                child: _buildLapanganStatusBadge(status),
              ),
            ],
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  lapangan['name'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // Venue
                Row(
                  children: [
                    Icon(Icons.store, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        lapangan['venue'],
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Category & Price
                Row(
                  children: [
                    Icon(Icons.category, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      lapangan['category'],
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const Spacer(),
                    Text(
                      'Rp ${_formatCurrency(lapangan['price'])}/jam',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF5409DA),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await _showCourtSessionsDialog(lapangan);
                          // Reload courts after dialog closes (in case price was updated)
                          _loadLapangan();
                        },
                        icon: const Icon(Icons.schedule, size: 18),
                        label: const Text('Jadwal'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF4E71FF),
                          side: const BorderSide(color: Color(0xFF4E71FF)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  LapanganFormPage(lapangan: lapangan),
                            ),
                          );
                          if (result == true && mounted) {
                            _loadLapangan();
                          }
                        },
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text('Edit'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF5409DA),
                          side: const BorderSide(color: Color(0xFF5409DA)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: () =>
                          _deleteLapangan(lapangan['id'], lapangan['name']),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      child: const Icon(Icons.delete, size: 18),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLapanganStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    String text;
    IconData icon;

    switch (status) {
      case 'active':
        bgColor = Colors.green;
        textColor = Colors.white;
        text = 'Active';
        icon = Icons.check_circle;
        break;
      case 'inactive':
        bgColor = Colors.grey;
        textColor = Colors.white;
        text = 'Inactive';
        icon = Icons.cancel;
        break;
      default:
        bgColor = Colors.orange;
        textColor = Colors.white;
        text = 'Unknown';
        icon = Icons.help;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: textColor, size: 16),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Court Sessions Management
  String _getDayLabel(
    String day,
    List<String> daysOfWeek,
    List<String> dayLabels,
  ) {
    final index = daysOfWeek.indexOf(day);
    return index >= 0 ? dayLabels[index] : day;
  }

  Future<void> _showCourtSessionsDialog(Map<String, dynamic> court) async {
    final request = context.read<CookieRequest>();

    // Load sessions
    List<Map<String, dynamic>> sessions = [];
    try {
      final response = await request.get(
        '${ApiConstants.baseUrl}/api/courts/${court['id']}/sessions/',
      );

      if (response['success'] == true) {
        sessions = (response['data'] as List)
            .map((session) => Map<String, dynamic>.from(session))
            .toList();
        print('Initial sessions loaded: $sessions');
        print('Court price_per_hour: ${court['price_per_hour']}');
        print('Court object keys: ${court.keys}');
        if (sessions.isNotEmpty) {
          print('First session price: ${sessions[0]['price']}');
          print('First session keys: ${sessions[0].keys}');
        }
      }
    } catch (e) {
      print('Error loading sessions: $e');
    }

    if (!mounted) return;

    // Capture class members before entering dialog context
    final daysOfWeek = _daysOfWeek;
    final dayLabels = _dayLabels;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          // Group sessions by day
          final groupedSessions = <String, List<Map<String, dynamic>>>{};
          for (final session in sessions) {
            final day = session['day_of_week'] as String;
            if (!groupedSessions.containsKey(day)) {
              groupedSessions[day] = [];
            }
            groupedSessions[day]!.add(session);
          }

          // Sort days and sessions within each day
          final sortedDays = groupedSessions.keys.toList()
            ..sort(
              (a, b) => daysOfWeek.indexOf(a).compareTo(daysOfWeek.indexOf(b)),
            );

          for (final sessions in groupedSessions.values) {
            sessions.sort((a, b) => a['start_time'].compareTo(b['start_time']));
          }

          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              constraints: const BoxConstraints(maxWidth: 700, maxHeight: 600),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Color(0xFF5409DA),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.schedule,
                          color: Colors.white,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Kelola Jadwal',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                court['name'],
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, color: Colors.white),
                          onPressed: () async {
                            await _showAddSessionDialog(
                              dialogContext,
                              court['id'],
                            );
                            // Reload sessions
                            try {
                              final response = await request.get(
                                '${ApiConstants.baseUrl}/api/courts/${court['id']}/sessions/',
                              );
                              if (response['success'] == true) {
                                setDialogState(() {
                                  sessions = (response['data'] as List)
                                      .map((s) => Map<String, dynamic>.from(s))
                                      .toList();
                                });
                              }
                            } catch (e) {
                              print('Error reloading: $e');
                            }
                          },
                          tooltip: 'Tambah Jadwal',
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.pop(dialogContext),
                        ),
                      ],
                    ),
                  ),
                  // Sessions List
                  Expanded(
                    child: sessions.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.schedule,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Belum ada jadwal',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Klik + untuk menambahkan jadwal',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: sortedDays.length,
                            itemBuilder: (context, index) {
                              final day = sortedDays[index];
                              final daySessions = groupedSessions[day]!;

                              return Card(
                                margin: const EdgeInsets.only(bottom: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Day Header
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFF5409DA,
                                        ).withOpacity(0.1),
                                        borderRadius:
                                            const BorderRadius.vertical(
                                              top: Radius.circular(12),
                                            ),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.calendar_today,
                                            color: Color(0xFF5409DA),
                                            size: 18,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            _getDayLabel(
                                              day,
                                              daysOfWeek,
                                              dayLabels,
                                            ),
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF5409DA),
                                            ),
                                          ),
                                          const Spacer(),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF5409DA),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Text(
                                              '${daySessions.length} slot',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Sessions
                                    ...daySessions.map(
                                      (session) => ListTile(
                                        leading: Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            color: const Color(
                                              0xFF4E71FF,
                                            ).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.access_time,
                                            color: Color(0xFF4E71FF),
                                            size: 22,
                                          ),
                                        ),
                                        title: Text(
                                          '${session['start_time']} - ${session['end_time']}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        subtitle: Text(
                                          'Rp ${_formatCurrency(session['price'] ?? court['price_per_hour'] ?? 0)}/jam',
                                          style: const TextStyle(
                                            color: Color(0xFF5409DA),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(
                                                Icons.edit,
                                                color: Color(0xFF5409DA),
                                                size: 20,
                                              ),
                                              onPressed: () async {
                                                await _showEditSessionDialog(
                                                  dialogContext,
                                                  court['id'],
                                                  session,
                                                );
                                                // Reload sessions after edit
                                                try {
                                                  final response = await request
                                                      .get(
                                                        '${ApiConstants.baseUrl}/api/courts/${court['id']}/sessions/',
                                                      );
                                                  if (response['success'] ==
                                                      true) {
                                                    print(
                                                      'Sessions after edit reload: ${response['data']}',
                                                    );
                                                    setDialogState(() {
                                                      sessions =
                                                          (response['data']
                                                                  as List)
                                                              .map(
                                                                (s) =>
                                                                    Map<
                                                                      String,
                                                                      dynamic
                                                                    >.from(s),
                                                              )
                                                              .toList();
                                                    });
                                                  }
                                                } catch (e) {
                                                  print(
                                                    'Error reloading after edit: $e',
                                                  );
                                                }
                                              },
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.delete,
                                                color: Colors.red,
                                                size: 20,
                                              ),
                                              onPressed: () async {
                                                await _deleteSession(
                                                  dialogContext,
                                                  court['id'],
                                                  session['id'],
                                                  '${session['start_time']} - ${session['end_time']}',
                                                );
                                                // Reload
                                                try {
                                                  final response = await request
                                                      .get(
                                                        '${ApiConstants.baseUrl}/api/courts/${court['id']}/sessions/',
                                                      );
                                                  if (response['success'] ==
                                                      true) {
                                                    setDialogState(() {
                                                      sessions =
                                                          (response['data']
                                                                  as List)
                                                              .map(
                                                                (s) =>
                                                                    Map<
                                                                      String,
                                                                      dynamic
                                                                    >.from(s),
                                                              )
                                                              .toList();
                                                    });
                                                  }
                                                } catch (e) {
                                                  print('Error: $e');
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _showAddSessionDialog(
    BuildContext parentContext,
    dynamic courtId,
  ) async {
    // Capture class members
    final daysOfWeek = _daysOfWeek;
    final dayLabels = _dayLabels;

    final startTimeController = TextEditingController();
    final endTimeController = TextEditingController();
    final priceController = TextEditingController();
    String selectedDay = daysOfWeek[0];

    return showDialog(
      context: parentContext,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Tambah Jadwal'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedDay,
                  decoration: const InputDecoration(
                    labelText: 'Hari',
                    border: OutlineInputBorder(),
                  ),
                  items: daysOfWeek.asMap().entries.map((entry) {
                    return DropdownMenuItem(
                      value: entry.value,
                      child: Text(dayLabels[entry.key]),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => selectedDay = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: startTimeController,
                  decoration: const InputDecoration(
                    labelText: 'Jam Mulai (HH:MM)',
                    hintText: '08:00',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.access_time),
                  ),
                  keyboardType: TextInputType.datetime,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: endTimeController,
                  decoration: const InputDecoration(
                    labelText: 'Jam Selesai (HH:MM)',
                    hintText: '09:00',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.access_time),
                  ),
                  keyboardType: TextInputType.datetime,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(
                    labelText: 'Harga per Jam',
                    hintText: '100000',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (startTimeController.text.isEmpty ||
                    endTimeController.text.isEmpty ||
                    priceController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Semua field harus diisi'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                try {
                  final request = Provider.of<CookieRequest>(
                    context,
                    listen: false,
                  );
                  final formData = {
                    'day_of_week': selectedDay,
                    'start_time': startTimeController.text,
                    'end_time': endTimeController.text,
                    'price': priceController.text,
                  };

                  final response = await request.postJson(
                    '${ApiConstants.baseUrl}/api/courts/$courtId/sessions/',
                    jsonEncode(formData),
                  );

                  if (response['success'] == true) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(parentContext).showSnackBar(
                      const SnackBar(
                        content: Text('Jadwal berhasil ditambahkan'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    throw Exception(
                      response['message'] ?? 'Failed to add session',
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5409DA),
                foregroundColor: Colors.white,
              ),
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditSessionDialog(
    BuildContext parentContext,
    dynamic courtId,
    Map<String, dynamic> session,
  ) async {
    // Capture class members
    final daysOfWeek = _daysOfWeek;
    final dayLabels = _dayLabels;

    final startTimeController = TextEditingController(
      text: session['start_time'],
    );
    final endTimeController = TextEditingController(text: session['end_time']);
    final priceController = TextEditingController(
      text: session['price'].toString(),
    );
    String selectedDay = session['day_of_week'];

    return showDialog(
      context: parentContext,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Jadwal'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedDay,
                  decoration: const InputDecoration(
                    labelText: 'Hari',
                    border: OutlineInputBorder(),
                  ),
                  items: daysOfWeek.asMap().entries.map((entry) {
                    return DropdownMenuItem(
                      value: entry.value,
                      child: Text(dayLabels[entry.key]),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => selectedDay = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: startTimeController,
                  decoration: const InputDecoration(
                    labelText: 'Jam Mulai (HH:MM)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.access_time),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: endTimeController,
                  decoration: const InputDecoration(
                    labelText: 'Jam Selesai (HH:MM)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.access_time),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(
                    labelText: 'Harga per Jam',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final request = Provider.of<CookieRequest>(
                    context,
                    listen: false,
                  );
                  final formData = {
                    '_method': 'PUT',
                    'day_of_week': selectedDay,
                    'start_time': startTimeController.text,
                    'end_time': endTimeController.text,
                    'price': priceController.text,
                  };

                  final response = await request.postJson(
                    '${ApiConstants.baseUrl}/api/courts/$courtId/sessions/${session['id']}/',
                    jsonEncode(formData),
                  );

                  if (response['success'] == true) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(parentContext).showSnackBar(
                      const SnackBar(
                        content: Text('Jadwal berhasil diupdate'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    throw Exception(
                      response['message'] ?? 'Failed to update session',
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5409DA),
                foregroundColor: Colors.white,
              ),
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteSession(
    BuildContext parentContext,
    dynamic courtId,
    int sessionId,
    String time,
  ) async {
    final confirm = await showDialog<bool>(
      context: parentContext,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Yakin ingin menghapus jadwal "$time"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final request = Provider.of<CookieRequest>(
          parentContext,
          listen: false,
        );
        final response = await request.postJson(
          '${ApiConstants.baseUrl}/api/courts/$courtId/sessions/$sessionId/',
          jsonEncode({'_method': 'DELETE'}),
        );

        if (response['success'] == true) {
          ScaffoldMessenger.of(parentContext).showSnackBar(
            const SnackBar(
              content: Text('Jadwal berhasil dihapus'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          throw Exception(response['message'] ?? 'Failed to delete session');
        }
      } catch (e) {
        ScaffoldMessenger.of(parentContext).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  String _formatCurrency(dynamic value) {
    int number;
    if (value is int) {
      number = value;
    } else if (value is double) {
      number = value.toInt();
    } else if (value is String) {
      number = double.tryParse(value)?.toInt() ?? 0;
    } else {
      number = 0;
    }
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }
}
