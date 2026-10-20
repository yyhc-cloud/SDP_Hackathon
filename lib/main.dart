import 'package:flutter/material.dart';

import 'app_shell.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const SdpApp());
}

class SdpApp extends StatelessWidget {
  const SdpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SDP Community',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const AppShell(),
    );
  }
}
