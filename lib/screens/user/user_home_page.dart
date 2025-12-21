import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import '../../config/config.dart';
import '../../constants/app_theme.dart';
import '../../models/venue.dart';
import '../../providers/user_provider.dart';
import 'booking_history_page.dart';
import 'venue_detail_page.dart';
import 'venue_list_page.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  bool _isLoadingFeatured = true;
  String _featuredError = '';
  List<Venue> _featuredVenues = const [];

  bool _hasFetched = false;

  static const List<_SportItem> _sports = [
    _SportItem(title: 'Futsal', icon: Icons.sports_soccer),
    _SportItem(title: 'Badminton', icon: Icons.sports_tennis),
    _SportItem(title: 'Basket', icon: Icons.sports_basketball),
    _SportItem(title: 'Tennis', icon: Icons.sports_tennis),
    _SportItem(title: 'Voli', icon: Icons.sports_volleyball),
    _SportItem(title: 'Gym', icon: Icons.fitness_center),
    _SportItem(title: 'Renang', icon: Icons.pool),
    _SportItem(title: 'Sepeda', icon: Icons.directions_bike),
    _SportItem(title: 'Lari', icon: Icons.directions_run),
    _SportItem(title: 'Bela Diri', icon: Icons.sports_mma),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchFeaturedOnce();
    });
  }

  void _fetchFeaturedOnce() {
    if (_hasFetched) return;
    _hasFetched = true;
    _fetchFeaturedVenues();
  }

  Future<void> _fetchFeaturedVenues() async {
    if (!mounted) return;

    setState(() {
      _isLoadingFeatured = true;
      _featuredError = '';
    });

    try {
      final request = context.read<CookieRequest>();

      final uri = Uri.parse(
        AppConfig.buildUrl(AppConfig.venuesEndpoint),
      ).replace(queryParameters: const {'page': '1', 'page_size': '8'});

      final response = await request.get(uri.toString());
      if (!mounted) return;

      if (response != null && response['status'] == 'ok') {
        final venueResponse = VenueListResponse.fromJson(response);
        setState(() {
          _featuredVenues = venueResponse.data.take(8).toList(growable: false);
          _isLoadingFeatured = false;
        });
      } else {
        setState(() {
          _featuredError = 'Gagal memuat rekomendasi venue.';
          _isLoadingFeatured = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _featuredError = 'Terjadi error saat memuat: $e';
        _isLoadingFeatured = false;
      });
    }
  }

  void _goToVenues() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const VenueListPage()));
  }

  void _goToBookings() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const BookingHistoryPage()));
  }

  void _openVenue(Venue venue) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => VenueDetailPage(venueId: venue.id)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final username = userProvider.user?.username.trim();
    final greetingName = (username == null || username.isEmpty)
        ? 'User'
        : username;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _fetchFeaturedVenues,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              pinned: true,
              elevation: 0,
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              expandedHeight: 260,
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.parallax,
                background: _HeroHeader(
                  greetingName: greetingName,
                  onSearchTap: _goToVenues,
                ),
              ),
              title: const Text('LapangIN'),
              actions: [
                IconButton(
                  tooltip: 'Cari venue',
                  onPressed: _goToVenues,
                  icon: const Icon(Icons.search),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.md,
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionHeader(
                      title: 'Quick Actions',
                      subtitle:
                          'Mulai dari sini — cari venue, lihat booking, dan eksplor olahraga.',
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: _QuickActionCard(
                            title: 'Cari Court',
                            subtitle: 'Temukan venue terbaik',
                            icon: Icons.travel_explore,
                            onTap: _goToVenues,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: _QuickActionCard(
                            title: 'Booking Saya',
                            subtitle: 'Cek riwayat & status',
                            icon: Icons.receipt_long,
                            onTap: _goToBookings,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.xl,
                  AppSpacing.md,
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionHeader(
                      title: 'Olahraga Populer',
                      subtitle:
                          'Banyakin vibe olahraga — pilih kategori favoritmu.',
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SizedBox(
                      height: 120,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _sports.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(width: AppSpacing.md),
                        itemBuilder: (context, index) {
                          final item = _sports[index];
                          return _SportCard(item: item);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.xl,
                  AppSpacing.md,
                  0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: _SectionHeader(
                        title: 'Court Untuk Kamu',
                        subtitle: 'Ringkasan venue populer (geser ke samping).',
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    TextButton(
                      onPressed: _goToVenues,
                      child: const Text('Lihat semua'),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 270,
                child: _FeaturedVenuesStrip(
                  isLoading: _isLoadingFeatured,
                  error: _featuredError,
                  venues: _featuredVenues,
                  onRetry: _fetchFeaturedVenues,
                  onOpenVenue: _openVenue,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.xl,
                  AppSpacing.md,
                  AppSpacing.xxl,
                ),
                child: _InfoBanner(onTap: _goToVenues),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  final String greetingName;
  final VoidCallback onSearchTap;

  const _HeroHeader({required this.greetingName, required this.onSearchTap});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.secondary],
            ),
          ),
        ),
        Positioned(
          right: -20,
          top: 40,
          child: Icon(
            Icons.sports_soccer,
            size: 160,
            color: Colors.white.withOpacity(0.12),
          ),
        ),
        Positioned(
          left: -10,
          bottom: 10,
          child: Icon(
            Icons.sports_basketball,
            size: 140,
            color: Colors.white.withOpacity(0.10),
          ),
        ),
        Positioned(
          right: 30,
          bottom: -12,
          child: Icon(
            Icons.sports_tennis,
            size: 120,
            color: Colors.white.withOpacity(0.10),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              56,
              AppSpacing.md,
              AppSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Halo, $greetingName',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Temukan venue olahraga\nimpianmu hari ini',
                  style: TextStyle(
                    fontSize: 28,
                    height: 1.15,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                InkWell(
                  onTap: onSearchTap,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.md,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.16),
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(color: Colors.white.withOpacity(0.22)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: Colors.white),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            'Cari venue, lokasi, atau olahraga…',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.95),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.h3),
        const SizedBox(height: 6),
        Text(subtitle, style: AppTextStyles.bodySmall),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(icon, color: AppColors.primary),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurface.withOpacity(0.45),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SportItem {
  final String title;
  final IconData icon;

  const _SportItem({required this.title, required this.icon});
}

class _SportCard extends StatelessWidget {
  final _SportItem item;

  const _SportCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 120,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(item.icon, color: AppColors.secondary),
          ),
          const Spacer(),
          Text(
            item.title,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w900,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text('Lihat venue', style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

class _FeaturedVenuesStrip extends StatelessWidget {
  final bool isLoading;
  final String error;
  final List<Venue> venues;
  final Future<void> Function() onRetry;
  final void Function(Venue venue) onOpenVenue;

  const _FeaturedVenuesStrip({
    required this.isLoading,
    required this.error,
    required this.venues,
    required this.onRetry,
    required this.onOpenVenue,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isLoading) {
      return ListView.separated(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
        ),
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (_, __) => const _SkeletonCard(),
      );
    }

    if (error.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            children: [
              Icon(Icons.error_outline, color: theme.colorScheme.error),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: Text(error, style: AppTextStyles.bodyMedium)),
              const SizedBox(width: AppSpacing.md),
              TextButton(
                onPressed: () {
                  onRetry();
                },
                child: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
      );
    }

    if (venues.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.divider),
          ),
          child: const Row(
            children: [
              Icon(Icons.stadium_outlined),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text('Belum ada venue untuk ditampilkan saat ini.'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
      ),
      scrollDirection: Axis.horizontal,
      itemCount: venues.length,
      separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
      itemBuilder: (context, index) {
        final venue = venues[index];
        return _FeaturedVenueCard(
          venue: venue,
          onTap: () => onOpenVenue(venue),
        );
      },
    );
  }
}

class _FeaturedVenueCard extends StatelessWidget {
  final Venue venue;
  final VoidCallback onTap;

  const _FeaturedVenueCard({required this.venue, required this.onTap});

  String _formatRupiah(double value) {
    final s = value.toStringAsFixed(0);
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final pos = s.length - i;
      buffer.write(s[i]);
      if (pos > 1 && pos % 3 == 1) buffer.write('.');
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imageUrl = venue.images.isNotEmpty ? venue.images.first : '';

    return SizedBox(
      width: 240,
      child: Material(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppRadius.lg),
                  ),
                  child: SizedBox(
                    height: 130,
                    width: double.infinity,
                    child: imageUrl.isEmpty
                        ? Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.primary.withOpacity(0.85),
                                  AppColors.secondary.withOpacity(0.85),
                                ],
                              ),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.stadium,
                                color: Colors.white,
                                size: 44,
                              ),
                            ),
                          )
                        : Image.network(
                            AppConfig.buildProxyImageUrl(imageUrl),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[200],
                                child: const Center(
                                  child: Icon(Icons.stadium, size: 44),
                                ),
                              );
                            },
                          ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          venue.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 18,
                              color: AppColors.warning,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              venue.avgRating.toStringAsFixed(1),
                              style: AppTextStyles.bodySmall.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '(${venue.ratingCount})',
                              style: AppTextStyles.caption,
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.10),
                                borderRadius: BorderRadius.circular(
                                  AppRadius.full,
                                ),
                              ),
                              child: Text(
                                venue.category.isEmpty
                                    ? 'Sport'
                                    : venue.category,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Rp ${_formatRupiah(venue.pricePerHour)}/jam',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 16,
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.55,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                venue.address,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.caption,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  final VoidCallback onTap;

  const _InfoBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.12),
            AppColors.secondary.withOpacity(0.10),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: const Icon(Icons.bolt, color: AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.md),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Siap main hari ini?',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 4),
                Text(
                  'Cari venue terdekat, pilih lapangan, lalu booking dalam beberapa langkah.',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          FilledButton(onPressed: onTap, child: Text('Explore')),
        ],
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.05),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.divider),
        ),
      ),
    );
  }
}
