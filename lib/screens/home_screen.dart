import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../theme/app_colors.dart';
import '../widgets/common.dart';
import 'pickup_request_screen.dart';
import 'report_screen.dart';
import 'scan_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onNavigate});

  /// Switches the bottom tab (1 = Rewards, 3 = Community).
  final ValueChanged<int> onNavigate;

  void _push(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    const user = MockData.user;

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          _Header(user: user, onPointsTap: () => onNavigate(1)),
          const SectionHeader('Quick Access'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 0.78,
              children: [
                QuickActionTile(
                  icon: Icons.qr_code_scanner_rounded,
                  label: 'Scan Waste',
                  highlight: true,
                  onTap: () => _push(context, const ScanScreen()),
                ),
                QuickActionTile(
                  icon: Icons.local_shipping_outlined,
                  label: 'Request Pickup',
                  onTap: () => _push(context, const PickupRequestScreen()),
                ),
                QuickActionTile(
                  icon: Icons.report_outlined,
                  label: 'Report Waste',
                  onTap: () => _push(context, const ReportScreen()),
                ),
                QuickActionTile(
                  icon: Icons.local_parking_rounded,
                  label: 'Pay Parking',
                  onTap: () => onNavigate(1),
                ),
                QuickActionTile(
                  icon: Icons.leaderboard_outlined,
                  label: 'Leaderboard',
                  onTap: () => onNavigate(3),
                ),
                QuickActionTile(
                  icon: Icons.shield_outlined,
                  label: 'Guild Wars',
                  onTap: () => onNavigate(3),
                ),
                QuickActionTile(
                  icon: Icons.place_outlined,
                  label: 'Centres',
                  onTap: () {},
                ),
                QuickActionTile(
                  icon: Icons.storefront_outlined,
                  label: 'Mall Deals',
                  onTap: () {},
                ),
              ],
            ),
          ),
          _StreakCard(days: user.streakDays),
          const SectionHeader('What\'s New'),
          SizedBox(
            height: 140,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: MockData.announcements.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (_, i) => _AnnouncementCard(item: MockData.announcements[i]),
            ),
          ),
          const SectionHeader('Nearby Collection Centres', action: 'See all'),
          for (final centre in MockData.centres)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: _CentreTile(centre: centre),
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.user, required this.onPointsTap});

  final UserProfile user;
  final VoidCallback onPointsTap;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 170 + top,
          padding: EdgeInsets.fromLTRB(20, top + 16, 12, 0),
          decoration: const BoxDecoration(
            gradient: AppColors.headerGradient,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, ${user.name}',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, color: AppColors.white, size: 16),
                        const SizedBox(width: 4),
                        Text(user.residence, style: const TextStyle(color: AppColors.white)),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Badge(
                  backgroundColor: AppColors.dark,
                  smallSize: 8,
                  child: Icon(Icons.notifications_none_rounded, color: AppColors.white),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(20, top + 92, 20, 0),
          child: _PointsCard(user: user, onTap: onPointsTap),
        ),
      ],
    );
  }
}

class _PointsCard extends StatelessWidget {
  const _PointsCard({required this.user, required this.onTap});

  final UserProfile user;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ringgit = user.points / MockData.pointsPerRinggit;

    return Material(
      color: AppColors.white,
      elevation: 6,
      shadowColor: AppColors.dark.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(color: AppColors.tint, shape: BoxShape.circle),
                child: const Icon(Icons.eco_rounded, color: AppColors.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Green Points', style: TextStyle(color: AppColors.grey, fontSize: 12)),
                    Text(
                      formatPoints(user.points),
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                    ),
                    Text(
                      '≈ RM ${ringgit.toStringAsFixed(2)} parking credit',
                      style: const TextStyle(color: AppColors.primary, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  const _StreakCard({required this.days});

  final int days;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.dark,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(Icons.local_fire_department_rounded, color: AppColors.primary, size: 36),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$days-day recycling streak!',
                    style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      for (var i = 0; i < 7; i++)
                        Expanded(
                          child: Container(
                            height: 6,
                            margin: const EdgeInsets.only(right: 4),
                            decoration: BoxDecoration(
                              color: i < days ? AppColors.primary : AppColors.grey.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Recycle tomorrow to earn a +100 bonus',
                    style: TextStyle(color: AppColors.tint, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  const _AnnouncementCard({required this.item});

  final Announcement item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.tint,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Pill(item.tag, filled: true),
          const Spacer(),
          Text(item.title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(item.subtitle, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _CentreTile extends StatelessWidget {
  const _CentreTile({required this.centre});

  final CollectionCentre centre;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.tint,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.recycling_rounded, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(centre.name, style: Theme.of(context).textTheme.titleMedium),
                  Text('${centre.distance} · ${centre.hours}', style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [for (final a in centre.accepts) Pill(a)],
                  ),
                ],
              ),
            ),
            const Icon(Icons.directions_outlined, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
