import 'package:flutter/material.dart';

import '../data/township_state.dart';
import '../models/landed_models.dart';
import '../theme/app_colors.dart';
import '../widgets/common.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: TownshipState.instance,
      builder: (context, _) {
        final state = TownshipState.instance;
        final user = state.user;
        final unlockedBadgeCount = state.badges.where((b) => b.isUnlocked).length;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Resident Profile'),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_outlined),
                tooltip: 'Share Eco Profile',
                onPressed: () {
                  ScaffoldMessenger.of(context).showLatestSnackBar(
                    const SnackBar(content: Text('Eco Profile link copied to clipboard!')),
                  );
                },
              ),
            ],
          ),
          body: ListView(
            children: [
              const SizedBox(height: 8),
              Center(
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.tint,
                  child: Text(
                    user.name[0],
                    style: const TextStyle(fontSize: 32, color: AppColors.primary, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(child: Text(user.name, style: Theme.of(context).textTheme.titleLarge)),
              Center(
                child: Text(
                  '${user.residence} · ${user.isLanded ? 'Landed resident' : 'Resident'}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _Stat(formatPoints(user.points), 'Points'),
                    _Stat('${user.streakDays}d', 'Streak'),
                    _Stat('${state.unlockedPokemon.length}', 'Pokémon'),
                    _Stat('$unlockedBadgeCount/${state.badges.length}', 'Badges'),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Township Biodiversity Badge Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFC8E6C9)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.verified_rounded, color: Color(0xFF2E7D32), size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Township Eco-Guardian (Tier 2)',
                              style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF1B5E20), fontSize: 13),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Active Companion: ${state.activeCompanion.displayName} • ${state.todayWalkedKm.toStringAsFixed(1)} km walked today',
                              style: const TextStyle(fontSize: 11, color: Color(0xFF2E7D32)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Township Badges Section
              const SectionHeader('Township Honors & Badges'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: state.badges.map((badge) => _TownshipBadgeCard(badge: badge)).toList(),
                ),
              ),

              const SizedBox(height: 12),
              const SectionHeader('Township Services & Account'),
              const _MenuTile(Icons.directions_car_outlined, 'My Vehicles (EV Pass)'),
              const _MenuTile(Icons.home_work_outlined, 'My Property & Maintenance'),
              const _MenuTile(Icons.history_rounded, 'Recycling & Smart Bin History'),
              const _MenuTile(Icons.leaderboard_outlined, 'Street Leaderboard (Jalan Makmur #1)'),
              const _MenuTile(Icons.notifications_none_rounded, 'Township Alerts'),
              const _MenuTile(Icons.help_outline_rounded, 'Help & Support'),
              const _MenuTile(Icons.settings_outlined, 'Settings'),
              ListTile(
                leading: const Icon(Icons.logout_rounded, color: AppColors.accent),
                title: const Text('Log Out', style: TextStyle(color: AppColors.accent)),
                onTap: () {},
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }
}

class _TownshipBadgeCard extends StatelessWidget {
  const _TownshipBadgeCard({required this.badge});

  final TownshipBadge badge;

  @override
  Widget build(BuildContext context) {
    final isUnlocked = badge.isUnlocked;
    final progressRatio = (badge.progress / badge.target).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isUnlocked ? const Color(0xFFF9FBE7) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isUnlocked ? const Color(0xFFDCE775) : const Color(0xFFE0E0E0),
          width: isUnlocked ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isUnlocked ? const Color(0xFFFFF9C4) : const Color(0xFFF5F5F5),
              shape: BoxShape.circle,
              border: Border.all(
                color: isUnlocked ? const Color(0xFFFFD54F) : Colors.grey.shade300,
              ),
            ),
            child: Icon(
              badge.icon,
              color: isUnlocked ? const Color(0xFFF57F17) : Colors.grey.shade500,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        badge.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: isUnlocked ? AppColors.dark : Colors.grey.shade700,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: isUnlocked ? const Color(0xFFE8F5E9) : const Color(0xFFEEEEEE),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        badge.category,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isUnlocked ? const Color(0xFF2E7D32) : Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  badge.description,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
                const SizedBox(height: 8),
                if (isUnlocked)
                  Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, color: Color(0xFF2E7D32), size: 14),
                      const SizedBox(width: 4),
                      Text(
                        'Unlocked • ${badge.unlockedDate ?? 'Earned'}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                    ],
                  )
                else ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progress: ${badge.progress} / ${badge.target}',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
                      ),
                      Text(
                        '${(progressRatio * 100).toInt()}%',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progressRatio,
                      minHeight: 5,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.value, this.label);

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.tint,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primary),
            ),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile(this.icon, this.title);

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.dark),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.grey),
      onTap: () {},
    );
  }
}
