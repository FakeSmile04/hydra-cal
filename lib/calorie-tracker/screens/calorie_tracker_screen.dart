import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../constants/app_values.dart';
import '../models/meal.dart';
import '../screens/meal_detail_screen.dart';
import '../widgets/calorie_circle.dart';
import '../widgets/meal_card.dart';
import '../../food_scanner/home_page.dart';

/// Main screen for the calorie tracker feature
class CalorieTrackerScreen extends StatefulWidget {
  const CalorieTrackerScreen({super.key});

  @override
  State<CalorieTrackerScreen> createState() => _CalorieTrackerScreenState();
}

class _CalorieTrackerScreenState extends State<CalorieTrackerScreen> {
  late int _dailyGoal;
  final List<Meal> _meals = [];

  @override
  void initState() {
    super.initState();
    _dailyGoal = AppValues.defaultDailyGoal;
  }

  /// Add a new meal to the list
  void _addMeal(Meal meal) {
    setState(() {
      _meals.add(meal);
    });
  }

  /// Update an existing meal
  void _updateMeal(Meal updatedMeal) {
    setState(() {
      final index = _meals.indexWhere((m) => m.id == updatedMeal.id);
      if (index != -1) {
        _meals[index] = updatedMeal;
      }
    });
  }

  /// Delete a meal
  void _deleteMeal(String mealId) {
    setState(() {
      _meals.removeWhere((m) => m.id == mealId);
    });
  }

  /// Calculate total calories consumed
  int get _totalCalories =>
      _meals.fold(0, (sum, meal) => sum + meal.totalCalories);

  /// Calculate remaining calories for the day
  int get _remainingCalories => _dailyGoal - _totalCalories;

  /// Show the add meal dialog
  Future<void> _showAddMealDialog() async {
    // Create a new empty meal with current time
    final now = DateTime.now();
    final newMeal = Meal(
      name: 'Meal ${_meals.length + 1}',
      time: now,
    );

    // Navigate to meal detail screen to add foods
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MealDetailScreen(
          meal: newMeal,
          onSave: (meal) {
            // Only add if meal has at least one food
            if (meal.foods.isNotEmpty) {
              _addMeal(meal);
            }
          },
        ),
      ),
    );
  }

  /// Navigate to meal detail screen for editing
  void _openMealDetails(Meal meal) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MealDetailScreen(
          meal: meal,
          onSave: _updateMeal,
        ),
      ),
    );
  }

  /// Handle scan food button press
  void _onScanFood() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const FoodScannerHomePage(),
      ),
    );
  }

  /// Show dialog to edit daily calorie goal
  Future<void> _showEditDailyGoalDialog() async {
    final textController = TextEditingController(text: _dailyGoal.toString());
    
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Daily Goal'),
          content: TextField(
            controller: textController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: 'Enter daily calorie goal',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final newGoal = int.tryParse(textController.text);
                if (newGoal != null && newGoal > 0) {
                  setState(() {
                    _dailyGoal = newGoal;
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Daily goal updated to $newGoal calories'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a valid number'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Calorie circle display
          CalorieCircle(
            remainingCalories: _remainingCalories,
            totalCalories: _totalCalories,
            dailyGoal: _dailyGoal,
          ),

          // Meals section header
          _buildMealsHeader(),

          // Meals list
          _buildMealsList(),

          // Scan food button
          _buildScanFoodButton(),
        ],
      ),
    );
  }

  /// Build the app bar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primary,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      title: const Text(
        AppStrings.appTitle,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      centerTitle: true,
      elevation: 0,
    );
  }

  /// Build the meals section header with add button
  Widget _buildMealsHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppValues.paddingLarge),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            AppStrings.meals,
            style: TextStyle(
              fontSize: AppValues.fontSizeLarge,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: AppColors.textSecondary, size: 20),
                onPressed: _showEditDailyGoalDialog,
                tooltip: 'Edit daily goal',
              ),
              IconButton(
                icon: const Icon(Icons.add, color: AppColors.textSecondary),
                onPressed: _showAddMealDialog,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build the scrollable meals list
  Widget _buildMealsList() {
    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: AppValues.paddingMedium),
        itemCount: _meals.length,
        itemBuilder: (context, index) {
          final meal = _meals[index];
          return MealCard(
            meal: meal,
            onTap: () => _openMealDetails(meal),
            onDelete: () => _deleteMeal(meal.id),
          );
        },
      ),
    );
  }

  /// Build the scan food button
  Widget _buildScanFoodButton() {
    return Padding(
      padding: const EdgeInsets.all(AppValues.paddingLarge),
      child: SizedBox(
        width: double.infinity,
        height: AppValues.buttonHeight,
        child: ElevatedButton(
          onPressed: _onScanFood,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryLight,
            foregroundColor: AppColors.primary,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppValues.buttonRadius),
            ),
          ),
          child: const Text(
            AppStrings.scanFood,
            style: TextStyle(
              fontSize: AppValues.fontSizeMedium,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
