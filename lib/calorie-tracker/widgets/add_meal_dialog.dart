import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../constants/app_values.dart';
import '../models/meal.dart';

/// Dialog for adding a new meal entry
class AddMealDialog extends StatefulWidget {
  const AddMealDialog({super.key});

  /// Show the dialog and return the created meal (or null if cancelled)
  static Future<Meal?> show(BuildContext context) {
    return showDialog<Meal>(
      context: context,
      builder: (context) => const AddMealDialog(),
    );
  }

  @override
  State<AddMealDialog> createState() => _AddMealDialogState();
}

class _AddMealDialogState extends State<AddMealDialog> {
  final _nameController = TextEditingController();
  final _calorieController = TextEditingController();
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  void dispose() {
    _nameController.dispose();
    _calorieController.dispose();
    super.dispose();
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _submit() {
    if (_nameController.text.isEmpty || _calorieController.text.isEmpty) {
      return;
    }

    final now = DateTime.now();
    final mealTime = DateTime(
      now.year,
      now.month,
      now.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final meal = Meal(
      name: _nameController.text.trim(),
      time: mealTime,
    );

    Navigator.of(context).pop(meal);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        AppStrings.addMeal,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Meal name input
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: AppStrings.mealName,
                hintText: AppStrings.mealNameHint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppValues.inputRadius),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppValues.inputRadius),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppValues.paddingMedium),

            // Calories input
            TextField(
              controller: _calorieController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: AppStrings.calories,
                hintText: AppStrings.caloriesHint,
                suffixText: AppStrings.caloriesSuffix,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppValues.inputRadius),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppValues.inputRadius),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppValues.paddingMedium),

            // Time picker
            InkWell(
              onTap: _selectTime,
              child: Container(
                padding: const EdgeInsets.all(AppValues.paddingMedium),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(AppValues.inputRadius),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${AppStrings.time}: ${_selectedTime.format(context)}',
                      style: const TextStyle(
                        fontSize: AppValues.fontSizeMedium,
                      ),
                    ),
                    const Icon(Icons.access_time, color: AppColors.primary),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            AppStrings.cancel,
            style: TextStyle(color: AppColors.textHint),
          ),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppValues.inputRadius),
            ),
          ),
          child: const Text(AppStrings.add),
        ),
      ],
    );
  }
}
