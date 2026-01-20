import 'package:flutter/material.dart';

import 'app_buttons.dart';
import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_text_styles.dart';

class RecalculateResultDialog extends StatelessWidget {
  final double weight;
  final double newGoal;
  final double oldGoal;
  final int age;
  final String activityLevel;
  final String gender;

  const RecalculateResultDialog({super.key, 
    required this.weight,
    required this.age,
    required this.activityLevel,
    required this.gender,
    required this.newGoal,
    required this.oldGoal,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            AppSpacing.verticalLG,
            _buildGoalCard(),
            AppSpacing.verticalLG,
            _buildBreakdownCard(),
            if (newGoal != oldGoal) ...[
              AppSpacing.verticalLG,
              _buildComparison(),
            ],
            AppSpacing.verticalXL,
            _buildActions(context),
          ],
        ),
      ),
    );
  }
  // UI SECTIONS
  Widget _buildHeader() {
    return Row(
      children: [
        Icon(
          Icons.water_drop,
          color: AppColors.primary,
          size: 32,
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            'YOUR NEW DAILY GOAL',
            style: AppTextStyles.h2,
          ),
        ),
      ],
    );
  }

  Widget _buildGoalCard() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryLight,
            AppColors.primary,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            '${newGoal.toInt()} ml',
            style: AppTextStyles.progressLarge.copyWith(
              color: Colors.white,
              fontSize: 56,
            ),
          ),
          Text(
            'per day',
            style: AppTextStyles.h3.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownCard() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📊 Breakdown:',
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          AppSpacing.verticalSM,
          _buildRow(
            'Base (${weight.toInt()}kg)',
            '${(weight * 33).toInt()}ml',
          ),
          _buildRow(
            'Activity',
            '+${_getActivityBonus(activityLevel).toInt()}ml',
          ),
          _buildRow(
            'Gender',
            gender == 'male' ? '+100ml' : '+0ml',
          ),
        ],
      ),
    );
  }

  Widget _buildComparison() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Previous:', style: AppTextStyles.bodyMedium),
            Text(
              '${oldGoal.toInt()}ml',
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Difference:',
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${(newGoal - oldGoal) > 0 ? '+' : ''}${(newGoal - oldGoal).toInt()}ml',
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.success,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context, false),
            style: AppButtons.outlined,
            child: Text('CANCEL'),
          ),
        ),
        SizedBox(width: AppSpacing.md),
        Expanded(
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: AppButtons.primary,
            child: Text('APPLY'),
          ),
        ),
      ],
    );
  }

  // HELPERS
  Widget _buildRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodySmall),
          Text(
            value,
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  double _getActivityBonus(String activity) {
    return {
      'sedentary': 0.0,
      'moderate': 300.0,
      'active': 500.0,
      'veryActive': 700.0,
    }[activity] ??
        0.0;
  }
}
