import 'package:flutter/material.dart';

/// App-wide color constants for consistent theming
class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // Primary colors
  static const Color primary = Color(0xFF6B4EAF);
  static const Color primaryLight = Color(0xFFE8E0F0);

  // Background colors
  static const Color background = Colors.white;
  static const Color cardBackground = Colors.white;

  // Text colors
  static const Color textPrimary = Colors.black87;
  static const Color textSecondary = Colors.black54;
  static const Color textHint = Colors.grey;

  // Other colors
  static const Color progressBackground = Color(0xFFE8E0F0);
  static const Color divider = Color(0xFFE0E0E0);
}
