import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_values.dart';
import 'calorie_tracker_screen.dart';

/// Home screen with navigation to main features
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text(
          'Health Tracker',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppValues.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppValues.paddingXLarge),
              
              // Welcome text
              const Text(
                'Welcome!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Choose a feature to get started',
                style: TextStyle(
                  fontSize: AppValues.fontSizeMedium,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: AppValues.paddingXLarge),
              
              // Feature buttons
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Food Scanner Button
                    _FeatureButton(
                      icon: Icons.qr_code_scanner,
                      label: 'Food Scanner',
                      onTap: () {
                        // TODO: Navigate to Food Scanner
                        _showComingSoon(context, 'Food Scanner');
                      },
                    ),
                    
                    const SizedBox(height: AppValues.paddingMedium),
                    
                    // Hydration Tracker Button
                    _FeatureButton(
                      icon: Icons.water_drop,
                      label: 'Hydration Tracker',
                      onTap: () {
                        // TODO: Navigate to Hydration Tracker
                        _showComingSoon(context, 'Hydration Tracker');
                      },
                    ),
                    
                    const SizedBox(height: AppValues.paddingMedium),
                    
                    // Calorie Tracker Button
                    _FeatureButton(
                      icon: Icons.local_fire_department,
                      label: 'Calorie Tracker',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CalorieTrackerScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Show coming soon snackbar for unimplemented features
  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature coming soon!'),
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}

/// Reusable feature button widget
class _FeatureButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _FeatureButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 80,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryLight,
          foregroundColor: AppColors.primary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppValues.cardRadius),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(
                fontSize: AppValues.fontSizeLarge,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
