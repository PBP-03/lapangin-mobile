import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import '../../config/config.dart';
import '../../constants/app_theme.dart';
import '../../models/venue.dart';
import 'venue_detail_page.dart';
import 'venue_list_page.dart';

class VenueSearchPage extends StatefulWidget {
  const VenueSearchPage({super.key, this.initialQuery});

  final String? initialQuery;

  @override
  State<VenueSearchPage> createState() => _VenueSearchPageState();
}

class _VenueSearchPageState extends State<VenueSearchPage> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _debounce;

  bool _isSearching = false;
  String _error = '';
  List<Venue> _results = const [];

  @override
  void initState() {
    super.initState();

    final initial = widget.initialQuery?.trim() ?? '';
    if (initial.isNotEmpty) {
      _controller.text = initial;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
        _performSearch(initial);
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }

    _controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onChanged() {
    final q = _controller.text.trim();
    _debounce?.cancel();

    if (q.length < 2) {
      setState(() {
        _isSearching = false;
        _error = '';
        _results = const [];
      });
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 300), () {
      _performSearch(q);
    });
  }

  Future<void> _performSearch(String query) async {
    if (!mounted) return;

    setState(() {
      _isSearching = true;
      _error = '';
    });

    try {
      final request = context.read<CookieRequest>();

      final uri = Uri.parse(AppConfig.buildUrl(AppConfig.venuesEndpoint))
          .replace(
            queryParameters: <String, String>{
              'search': query,
              'page': '1',
              'page_size': '10',
            },
          );

      final response = await request.get(uri.toString());
      if (!mounted) return;

      if (response != null && response['status'] == 'ok') {
        final venueResponse = VenueListResponse.fromJson(response);
        setState(() {
          _results = venueResponse.data.take(10).toList(growable: false);
          _isSearching = false;
        });
      } else {
        setState(() {
          _error = 'Gagal memuat hasil pencarian.';
          _results = const [];
          _isSearching = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Search error: $e';
        _results = const [];
        _isSearching = false;
      });
    }
  }

  void _openVenue(Venue venue) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => VenueDetailPage(venueId: venue.id)),
    );
  }

  void _openAllResults() {
    final q = _controller.text.trim();
    if (q.isEmpty) return;
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => VenueListPage(initialSearch: q)));
  }

  @override
  Widget build(BuildContext context) {
    final q = _controller.text.trim();

    return Scaffold(
      appBar: AppBar(title: const Text('Cari Venue')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        textInputAction: TextInputAction.search,
                        onSubmitted: (_) => _openAllResults(),
                        decoration: const InputDecoration(
                          hintText: 'Cari venue, lokasi, atau olahraga…',
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                    if (q.isNotEmpty)
                      IconButton(
                        tooltip: 'Hapus',
                        onPressed: _controller.clear,
                        icon: const Icon(Icons.close_rounded),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              if (_isSearching)
                const Padding(
                  padding: EdgeInsets.only(top: AppSpacing.md),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: AppSpacing.md),
                      Expanded(child: Text('Mencari…')),
                    ],
                  ),
                )
              else if (_error.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.md),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(_error, style: AppTextStyles.bodyMedium),
                      ),
                    ],
                  ),
                )
              else if (q.length < 2)
                const Padding(
                  padding: EdgeInsets.only(top: AppSpacing.md),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Ketik minimal 2 huruf untuk mulai mencari.'),
                  ),
                )
              else if (_results.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: AppSpacing.md),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Tidak ada hasil.'),
                  ),
                )
              else
                Expanded(
                  child: ListView.separated(
                    itemCount: _results.length + 1,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      if (index == _results.length) {
                        return ListTile(
                          leading: const Icon(Icons.travel_explore),
                          title: Text('Lihat semua hasil untuk "$q"'),
                          onTap: _openAllResults,
                        );
                      }

                      final venue = _results[index];
                      final imageUrl = venue.images.isNotEmpty
                          ? venue.images.first
                          : '';

                      return ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          child: SizedBox(
                            width: 44,
                            height: 44,
                            child: imageUrl.isEmpty
                                ? Container(
                                    color: AppColors.primary.withOpacity(0.10),
                                    child: const Icon(Icons.stadium_outlined),
                                  )
                                : Image.network(
                                    AppConfig.buildProxyImageUrl(imageUrl),
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) {
                                      return Container(
                                        color: Colors.black.withOpacity(0.05),
                                        child: const Icon(
                                          Icons.stadium_outlined,
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ),
                        title: Text(
                          venue.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        subtitle: Text(
                          venue.address,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.caption,
                        ),
                        onTap: () => _openVenue(venue),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
