import 'package:flutter/material.dart';
import 'show_qr_screen.dart';

/// Legacy alias forwarder for ShowQrScreen
class ScanScreen extends StatelessWidget {
  const ScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ShowQrScreen();
  }
}
