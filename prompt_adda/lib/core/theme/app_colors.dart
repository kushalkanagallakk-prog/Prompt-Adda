import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color background = Color(0xFFFFFBFF);
  static const Color backgroundLavender = Color(0xFFF1E8FF);
  static const Color backgroundPeach = Color(0xFFFFEEE8);

  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSoft = Color(0xFFF8F4FF);

  static const Color primary = Color(0xFF7547D8);
  static const Color primaryDark = Color(0xFF4B249A);
  static const Color primarySoft = Color(0xFFE9DCFF);

  static const Color textPrimary = Color(0xFF171728);
  static const Color textSecondary = Color(0xFF686879);
  static const Color divider = Color(0xFFE8E1EE);

  static const Color success = Color(0xFF2E9D65);
  static const Color error = Color(0xFFD64A5B);

  static const LinearGradient appBackgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFF2E9FF),
      Color(0xFFFFFBF9),
      Color(0xFFF8F1FF),
      Color(0xFFFFEEE8),
    ],
    stops: [0, 0.38, 0.72, 1],
  );

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFA776FF), Color(0xFF7547D8), Color(0xFF4B249A)],
  );
}
