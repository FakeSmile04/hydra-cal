import 'package:flutter/material.dart';
import 'package:hydra_cal/firebase_options.dart';
import 'calorie-tracker/screens/calorie_tracker_screen.dart';
import 'calorie-tracker/constants/app_colors.dart';
import 'hydration features/hydration_tracker_screen.dart';
import 'food_scanner/home_page.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HydraCal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        scaffoldBackgroundColor: AppColors.background,
      ),
      home: const MyHomePage(title: 'HydraCal'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(title),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        color: AppColors.background,
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Welcome Text
                  const Text(
                    'Welcome to HydraCal',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6200EE),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Choose a feature to get started',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF757575),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  
                  // Calorie Tracker Button
                  _buildFeatureButton(
                    context: context,
                    icon: Icons.local_fire_department,
                    label: 'Calorie Tracker',
                    color: AppColors.primary,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CalorieTrackerScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  
                  // Hydration Tracker Button
                  _buildFeatureButton(
                    context: context,
                    icon: Icons.water_drop,
                    label: 'Hydration Tracker',
                    color: AppColors.primary,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HydrationTrackerScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  
                  // Food Scanner Button
                  _buildFeatureButton(
                    context: context,
                    icon: Icons.camera_alt,
                    label: 'Food Scanner',
                    color: AppColors.primary,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FoodScannerHomePage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildFeatureButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color, color.withOpacity(0.8)],
              ),
            ),
            child: Row(
              children: [
                Icon(icon, size: 40, color: Colors.white),
                const SizedBox(width: 20),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_forward, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}