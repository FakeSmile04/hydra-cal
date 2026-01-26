// **************************************
// UNUSED - PLACEHOLDER main.dart for hydration features
// **************************************

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'hydration_tracker_screen.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';
import 'app_icons.dart';
import 'database_service.dart';

Future<void> main() async {
  // ensure flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // initialize Isar database
  await DatabaseService().initialize();

  // set status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const HydroCalApp());
}

class HydroCalApp extends StatelessWidget {
  const HydroCalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HydroCal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF2196F3),
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        fontFamily: 'Roboto',
      ),
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _screens = [
     HydrationTrackerScreen(),
    const PlaceholderScreen(title: 'Calorie Tracker'),
    const PlaceholderScreen(title: 'Personal Trainer'),
    const PlaceholderScreen(title: 'Food Scanner'),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textHint,
        items: const [
          BottomNavigationBarItem(icon: Icon(AppIcons.hydration), label: 'Hydration'),
          BottomNavigationBarItem(icon: Icon(AppIcons.calories), label: 'Calories'),
          BottomNavigationBarItem(icon: Icon(AppIcons.trainer), label: 'Trainer'),
          BottomNavigationBarItem(icon: Icon(AppIcons.scanner), label: 'Scanner'),
        ],
      ),
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), backgroundColor: AppColors.primary),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.construction, size: 80, color: AppColors.textHint),
            const SizedBox(height: 24),
            Text('Coming Soon!', style: AppTextStyles.h2),
          ],
        ),
      ),
    );
  }
}
