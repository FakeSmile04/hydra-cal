import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_values.dart';

/// Dialog for editing meal name
class EditMealNameDialog extends StatefulWidget {
  final String initialName;

  const EditMealNameDialog({super.key, required this.initialName});

  /// Show the dialog and return the new name (or null if cancelled)
  static Future<String?> show(
    BuildContext context, {
    required String initialName,
  }) {
    return showDialog<String>(
      context: context,
      builder: (context) => EditMealNameDialog(initialName: initialName),
    );
  }

  @override
  State<EditMealNameDialog> createState() => _EditMealNameDialogState();
}

class _EditMealNameDialogState extends State<EditMealNameDialog> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_nameController.text.trim().isEmpty) {
      return;
    }
    Navigator.of(context).pop(_nameController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Edit Meal Name',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
      content: TextField(
        controller: _nameController,
        autofocus: true,
        decoration: InputDecoration(
          labelText: 'Meal Name',
          hintText: 'e.g., Breakfast, Lunch, Dinner',
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
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Cancel',
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
          child: const Text('Update'),
        ),
      ],
    );
  }
}
