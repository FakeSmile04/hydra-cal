import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../constants/app_values.dart';

/// Circular progress indicator showing remaining calories
class CalorieCircle extends StatelessWidget {
  final int remainingCalories;
  final int totalCalories;
  final int dailyGoal;

  const CalorieCircle({
    super.key,
    required this.remainingCalories,
    required this.totalCalories,
    required this.dailyGoal,
  });

  /// Format number with comma separators (e.g., 1,760)
  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = dailyGoal > 0 ? totalCalories / dailyGoal : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppValues.paddingXLarge),
      child: Center(
        child: SizedBox(
          width: AppValues.circleSize,
          height: AppValues.circleSize,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Progress indicator
              SizedBox(
                width: AppValues.circleSize,
                height: AppValues.circleSize,
                child: CircularProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  strokeWidth: AppValues.circleStrokeWidth,
                  backgroundColor: AppColors.progressBackground,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.primary,
                  ),
                ),
              ),
              // Center text
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _formatNumber(remainingCalories),
                    style: const TextStyle(
                      fontSize: AppValues.fontSizeXLarge,
                      fontWeight: FontWeight.w300,
                      color: AppColors.primary,
                    ),
                  ),
                  const Text(
                    AppStrings.remaining,
                    style: TextStyle(
                      fontSize: AppValues.fontSizeMedium,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
