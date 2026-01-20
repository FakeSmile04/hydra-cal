import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';
import '../constants/app_values.dart';
import '../models/meal.dart';
import '../models/food.dart';
import '../widgets/food_item_card.dart';
import '../widgets/add_edit_food_dialog.dart';
import '../widgets/edit_meal_name_dialog.dart';

/// Detailed meal view with CRUD operations for foods
class MealDetailScreen extends StatefulWidget {
  final Meal meal;
  final Function(Meal) onSave;

  const MealDetailScreen({
    super.key,
    required this.meal,
    required this.onSave,
  });

  @override
  State<MealDetailScreen> createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends State<MealDetailScreen> {
  late Meal _currentMeal;

  @override
  void initState() {
    super.initState();
    _currentMeal = widget.meal;
  }

  /// Add a new food to the meal
  Future<void> _addFood() async {
    final food = await AddEditFoodDialog.show(context);
    if (food != null) {
      setState(() {
        _currentMeal = _currentMeal.addFood(food);
      });
    }
  }

  /// Edit an existing food
  Future<void> _editFood(Food food) async {
    final updatedFood = await AddEditFoodDialog.show(context, food: food);
    if (updatedFood != null) {
      setState(() {
        _currentMeal = _currentMeal.updateFood(updatedFood);
      });
    }
  }

  /// Delete a food from the meal
  void _deleteFood(String foodId) {
    setState(() {
      _currentMeal = _currentMeal.removeFood(foodId);
    });
  }

  /// Edit the meal name
  Future<void> _editMealName() async {
    final newName = await EditMealNameDialog.show(
      context,
      initialName: _currentMeal.name,
    );
    if (newName != null) {
      setState(() {
        _currentMeal = _currentMeal.copyWith(name: newName);
      });
    }
  }

  /// Save the updated meal
  void _saveMeal() {
    widget.onSave(_currentMeal);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('hh:mm a');

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: GestureDetector(
            onTap: _editMealName,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    _currentMeal.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.edit, color: Colors.white, size: 18),
              ],
            ),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        body: Column(
          children: [
            // Header with time and total calories
            Container(
              color: AppColors.primaryLight,
              padding: const EdgeInsets.all(AppValues.paddingMedium),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    timeFormat.format(_currentMeal.time),
                    style: const TextStyle(
                      fontSize: AppValues.fontSizeMedium,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    '${_currentMeal.totalCalories} Cal',
                    style: const TextStyle(
                      fontSize: AppValues.fontSizeLarge,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),

            // Foods list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(AppValues.paddingMedium),
                itemCount: _currentMeal.foods.length,
                itemBuilder: (context, index) {
                  final food = _currentMeal.foods[index];
                  return FoodItemCard(
                    food: food,
                    onEdit: () => _editFood(food),
                    onDelete: () => _deleteFood(food.id),
                  );
                },
              ),
            ),

            // Add food and save buttons
            Padding(
              padding: const EdgeInsets.all(AppValues.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton.icon(
                    onPressed: _addFood,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryLight,
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppValues.paddingMedium,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppValues.cardRadius),
                      ),
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text(
                      'Add Food',
                      style: TextStyle(
                        fontSize: AppValues.fontSizeMedium,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _saveMeal,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppValues.paddingMedium,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppValues.cardRadius),
                      ),
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(
                        fontSize: AppValues.fontSizeMedium,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
