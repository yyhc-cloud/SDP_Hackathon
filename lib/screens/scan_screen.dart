import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/common.dart';

/// AI waste scanner. The camera and the classifier are placeholders: swap
/// `_simulateScan` for a real camera feed and model/API call.
class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanResult {
  const _ScanResult(this.item, this.category, this.bin, this.points, this.tip);

  final String item;
  final String category;
  final String bin;
  final int points;
  final String tip;
}

class _ScanScreenState extends State<ScanScreen> {
  bool _scanning = false;
  _ScanResult? _result;

  Future<void> _simulateScan() async {
    setState(() {
      _scanning = true;
      _result = null;
    });
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() {
      _scanning = false;
      _result = const _ScanResult(
        'PET plastic bottle',
        'Plastic',
        'Blue bin — Recyclables',
        10,
        'Remove the cap and rinse before dropping it in.',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: AppBar(
        backgroundColor: AppColors.dark,
        foregroundColor: AppColors.white,
        title: const Text('Scan Waste', style: TextStyle(color: AppColors.white)),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primary, width: 3),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Center(
                  child: _scanning
                      ? const CircularProgressIndicator(color: AppColors.primary)
                      : const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.camera_alt_outlined, color: AppColors.white, size: 48),
                            SizedBox(height: 12),
                            Text(
                              'Point the camera at your item',
                              style: TextStyle(color: AppColors.white),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.paddingOf(context).bottom),
            decoration: const BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: _result == null ? _idle() : _resultView(_result!),
          ),
        ],
      ),
    );
  }

  Widget _idle() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Our AI identifies your item and tells you which bin it goes in. '
          'Correctly sorted items earn Green Points.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _scanning ? null : _simulateScan,
          icon: const Icon(Icons.center_focus_strong_rounded),
          label: Text(_scanning ? 'Analysing…' : 'Scan Item'),
        ),
      ],
    );
  }

  Widget _resultView(_ScanResult r) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(r.item, style: Theme.of(context).textTheme.titleLarge)),
            Pill('+${r.points} pts', filled: true),
          ],
        ),
        const SizedBox(height: 8),
        Pill(r.category),
        const SizedBox(height: 12),
        _row(Icons.delete_outline_rounded, r.bin),
        _row(Icons.lightbulb_outline_rounded, r.tip),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Collect Points'),
        ),
        const SizedBox(height: 8),
        OutlinedButton(onPressed: _simulateScan, child: const Text('Scan Another')),
      ],
    );
  }

  Widget _row(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
