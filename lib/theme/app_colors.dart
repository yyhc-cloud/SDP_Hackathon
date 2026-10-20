import 'package:flutter/material.dart';

/// Brand palette (see README.md).
class AppColors {
  AppColors._();

  static const primary = Color(0xFFF15921); // SDP orange
  static const dark = Color(0xFF292929); // text / dark surfaces
  static const tint = Color(0xFFFFF2EE); // light orange background
  static const accent = Color(0xFFDC3934); // red: alerts, highlights

  static const white = Colors.white;
  static const grey = Color(0xFF8A8A8A);
  static const divider = Color(0xFFEDEDED);
  static const background = Color(0xFFFAFAFA);

  static const headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, accent],
  );
}
