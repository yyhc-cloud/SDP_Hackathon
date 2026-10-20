import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../theme/app_colors.dart';
import '../widgets/common.dart';

/// Points balance, parking-fee redemption and points history.
class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  void _payParking(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: AppColors.white,
      builder: (_) => const _ParkingSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    const user = MockData.user;

    return Scaffold(
      appBar: AppBar(title: const Text('Rewards')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.headerGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Available points', style: TextStyle(color: AppColors.tint)),
                  const SizedBox(height: 4),
                  Text(
                    formatPoints(user.points),
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    '${MockData.pointsPerRinggit} pts = RM 1 parking credit',
                    style: const TextStyle(color: AppColors.tint, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.white,
                      foregroundColor: AppColors.primary,
                    ),
                    onPressed: () => _payParking(context),
                    icon: const Icon(Icons.local_parking_rounded),
                    label: const Text('Pay Mall Parking'),
                  ),
                ],
              ),
            ),
          ),
          const SectionHeader('How to earn'),
          const _EarnRow(Icons.qr_code_scanner_rounded, 'Scan & sort at a smart bin', '+5–20 pts / item'),
          const _EarnRow(Icons.local_shipping_outlined, 'Doorstep pickup (landed)', '+10 pts / kg'),
          const _EarnRow(Icons.local_fire_department_rounded, '7-day streak', '+100 pts'),
          const _EarnRow(Icons.shield_outlined, 'Win Guild Wars', 'Up to +5,000 pts'),
          const SectionHeader('History'),
          for (final a in MockData.activity)
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              title: Text(a.title),
              subtitle: Text(a.date),
              trailing: Text(
                '${a.points > 0 ? '+' : '−'}${formatPoints(a.points)}',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: a.points > 0 ? AppColors.primary : AppColors.accent,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _EarnRow extends StatelessWidget {
  const _EarnRow(this.icon, this.title, this.reward);

  final IconData icon;
  final String title;
  final String reward;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      leading: CircleAvatar(
        backgroundColor: AppColors.tint,
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(title),
      trailing: Pill(reward),
    );
  }
}

class _ParkingSheet extends StatelessWidget {
  const _ParkingSheet();

  @override
  Widget build(BuildContext context) {
    const fee = 3.00;
    const pointsNeeded = fee * MockData.pointsPerRinggit;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pay Parking', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          const ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.directions_car_outlined, color: AppColors.primary),
            title: Text('WXY 1234 · Setia City Mall'),
            subtitle: Text('Entered 2:14 PM · 2h 31m'),
          ),
          const Divider(),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text('Parking fee'), Text('RM 3.00')],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Points to redeem'),
              Text(
                '${pointsNeeded.toInt()} pts',
                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Parking paid with points. Have a nice day!')),
              );
            },
            child: const Text('Pay with Points'),
          ),
        ],
      ),
    );
  }
}
