import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../constants/app_values.dart';
import '../models/food.dart';

/// Dialog for adding or editing a food item
class AddEditFoodDialog extends StatefulWidget {
  final Food? food; // null for add, non-null for edit

  const AddEditFoodDialog({super.key, this.food});

  /// Show the dialog and return the created/edited food (or null if cancelled)
  static Future<Food?> show(
    BuildContext context, {
    Food? food,
  }) {
    return showDialog<Food>(
      context: context,
      builder: (context) => AddEditFoodDialog(food: food),
    );
  }

  @override
  State<AddEditFoodDialog> createState() => _AddEditFoodDialogState();
}

class _AddEditFoodDialogState extends State<AddEditFoodDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _calorieController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.food?.name ?? '');
    _calorieController =
        TextEditingController(text: widget.food?.calories.toString() ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _calorieController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_nameController.text.isEmpty || _calorieController.text.isEmpty) {
      return;
    }

    final food = Food(
      id: widget.food?.id,
      name: _nameController.text.trim(),
      calories: int.tryParse(_calorieController.text) ?? 0,
    );

    Navigator.of(context).pop(food);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.food != null;

    return AlertDialog(
      title: Text(
        isEditing ? 'Edit Food' : 'Add Food',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Food name input
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Food Name',
                hintText: 'e.g., Apple, Chicken Breast',
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
                labelText: 'Calories',
                hintText: 'e.g., 95',
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
          child: Text(isEditing ? 'Update' : AppStrings.add),
        ),
      ],
    );
  }
}
