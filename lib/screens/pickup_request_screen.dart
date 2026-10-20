import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

enum PickupType { recycling, foodWaste }

/// Landed residents request a collector: recycling weekly, food waste daily.
class PickupRequestScreen extends StatefulWidget {
  const PickupRequestScreen({super.key});

  @override
  State<PickupRequestScreen> createState() => _PickupRequestScreenState();
}

class _PickupRequestScreenState extends State<PickupRequestScreen> {
  PickupType _type = PickupType.recycling;
  String _slot = 'Morning (8–11am)';
  final _notes = TextEditingController();

  static const _slots = ['Morning (8–11am)', 'Afternoon (12–4pm)', 'Evening (5–8pm)'];

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  void _submit() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pickup requested! Points are credited after collection.')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Request Pickup')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Waste type', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _TypeCard(
                  icon: Icons.recycling_rounded,
                  title: 'Recycling',
                  subtitle: 'Collected weekly',
                  selected: _type == PickupType.recycling,
                  onTap: () => setState(() => _type = PickupType.recycling),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _TypeCard(
                  icon: Icons.restaurant_rounded,
                  title: 'Food Waste',
                  subtitle: 'Collected daily',
                  selected: _type == PickupType.foodWaste,
                  onTap: () => setState(() => _type = PickupType.foodWaste),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text('Preferred time', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              for (final s in _slots)
                ChoiceChip(
                  label: Text(s),
                  selected: _slot == s,
                  onSelected: (_) => setState(() => _slot = s),
                  labelStyle: TextStyle(color: _slot == s ? AppColors.white : AppColors.dark),
                  showCheckmark: false,
                ),
            ],
          ),
          const SizedBox(height: 24),
          Text('Pickup address', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          const TextField(
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.home_outlined),
              hintText: 'No. 12, Jalan Bukit Raja 3/1',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _notes,
            maxLines: 3,
            decoration: const InputDecoration(hintText: 'Notes for the collector (optional)'),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.tint,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline_rounded, color: AppColors.primary),
                SizedBox(width: 10),
                Expanded(child: Text('You earn points based on the weight collected.')),
              ],
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(onPressed: _submit, child: const Text('Confirm Request')),
        ],
      ),
    );
  }
}

class _TypeCard extends StatelessWidget {
  const _TypeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? AppColors.tint : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.divider,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(height: 8),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
