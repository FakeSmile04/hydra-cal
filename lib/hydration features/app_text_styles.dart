import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  static const String fontFamily = 'Roboto';

  static const TextStyle h1 = TextStyle(
    fontFamily: fontFamily, fontSize: 32,
    fontWeight: FontWeight.bold, color: AppColors.textPrimary,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: fontFamily, fontSize: 24,
    fontWeight: FontWeight.w600, color: AppColors.textPrimary,
  );

  static const TextStyle h3 = TextStyle(
    fontFamily: fontFamily, fontSize: 20,
    fontWeight: FontWeight.w600, color: AppColors.textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily, fontSize: 16,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily, fontSize: 14,
    color: AppColors.textSecondary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily, fontSize: 12,
    color: AppColors.textSecondary,
  );

  static const TextStyle button = TextStyle(
    fontFamily: fontFamily, fontSize: 16,
    fontWeight: FontWeight.w600, color: Colors.white,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily, fontSize: 12,
    color: AppColors.textHint,
  );

  static const TextStyle progressLarge = TextStyle(
    fontFamily: fontFamily, fontSize: 48,
    fontWeight: FontWeight.bold, color: AppColors.primary,
  );

  AppTextStyles._();
}