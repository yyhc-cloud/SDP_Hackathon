import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../theme/app_colors.dart';
import '../widgets/common.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const user = MockData.user;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
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
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _Stat(formatPoints(user.points), 'Points'),
                _Stat('${user.streakDays}', 'Day streak'),
                const _Stat('#4', 'Rank'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const _MenuTile(Icons.directions_car_outlined, 'My Vehicles'),
          const _MenuTile(Icons.home_work_outlined, 'My Property'),
          const _MenuTile(Icons.history_rounded, 'Pickup History'),
          const _MenuTile(Icons.notifications_none_rounded, 'Notifications'),
          const _MenuTile(Icons.help_outline_rounded, 'Help & Support'),
          const _MenuTile(Icons.settings_outlined, 'Settings'),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: AppColors.accent),
            title: const Text('Log Out', style: TextStyle(color: AppColors.accent)),
            onTap: () {},
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
