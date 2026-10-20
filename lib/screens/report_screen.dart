import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Report waste awaiting collection (overflowing bin, dumped waste, etc.).
class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  String _issue = 'Waste ready for collection';

  static const _issues = [
    'Waste ready for collection',
    'Overflowing bin',
    'Illegal dumping',
    'Smart bin faulty',
  ];

  void _submit() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Report submitted. Thank you for keeping the community clean!')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report Waste')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('What are you reporting?', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          RadioGroup<String>(
            groupValue: _issue,
            onChanged: (v) => setState(() => _issue = v!),
            child: Column(
              children: [
                for (final issue in _issues)
                  RadioListTile<String>(
                    value: issue,
                    title: Text(issue),
                    activeColor: AppColors.primary,
                    contentPadding: EdgeInsets.zero,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('Photo', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          InkWell(
            onTap: () {}, // TODO: open camera / image picker
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 140,
              decoration: BoxDecoration(
                color: AppColors.tint,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo_outlined, color: AppColors.primary, size: 32),
                  SizedBox(height: 8),
                  Text('Add a photo', style: TextStyle(color: AppColors.primary)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const TextField(
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.place_outlined),
              hintText: 'Location',
            ),
          ),
          const SizedBox(height: 12),
          const TextField(
            maxLines: 3,
            decoration: InputDecoration(hintText: 'Describe the issue'),
          ),
          const SizedBox(height: 24),
          FilledButton(onPressed: _submit, child: const Text('Submit Report')),
        ],
      ),
    );
  }
}
