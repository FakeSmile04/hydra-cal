import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'water_log.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';
import 'app_spacing.dart';
import 'app_buttons.dart';
import 'app_input_decoration.dart';

///  this is dialog for entering custom water amount
/// it allow users to enter any amount and optionally adjust timestamp
class CustomInputDialog extends StatefulWidget {
  final WaterLog? existingLog;

  const CustomInputDialog({super.key, this.existingLog});

  @override
  _CustomInputDialogState createState() => _CustomInputDialogState();
}

class _CustomInputDialogState extends State<CustomInputDialog> {
  final TextEditingController _amountController = TextEditingController();
  DateTime _selectedTime = DateTime.now();
  bool _isManualTime = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    if (widget.existingLog != null) {
      _amountController.text = widget.existingLog!.amount.toString();
      _selectedTime = widget.existingLog!.timestamp;
      _isManualTime = true;
    }
  }

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and close button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.existingLog != null ? 'EDIT ENTRY' : 'CUSTOM INPUT',
                  style: AppTextStyles.h2,
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
              ],
            ),
            AppSpacing.verticalLG,

            // amount input section
            Text('Enter amount:', style: AppTextStyles.bodyLarge),
            AppSpacing.verticalSM,
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              autofocus: true,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(4),
              ],
              decoration: AppInputDecoration.standard('Amount').copyWith(
                suffixText: 'ml',
                errorText: _errorText,
                hintText: 'e.g., 350',
              ),
              onChanged: (value) {
                setState(() {
                  _errorText = _validateAmount(value);
                });
              },
            ),
            AppSpacing.verticalLG,

            // time selection section
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
                SizedBox(width: 8),
                Text('Time: ', style: AppTextStyles.bodyLarge),
                Text(
                  _isManualTime
                      ? DateFormat('hh:mm a').format(_selectedTime)
                      : 'Now (${DateFormat('hh:mm a').format(DateTime.now())})',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            AppSpacing.verticalSM,

            // change time button
            TextButton(
              onPressed: _selectTime,
              style: AppButtons.text,
              child: Text(_isManualTime ? 'Change time' : 'Adjust time?'),
            ),

            // reset to current time button (shown only if manual time set)
            if (_isManualTime) ...[
              AppSpacing.verticalSM,
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _selectedTime = DateTime.now();
                    _isManualTime = false;
                  });
                },
                icon: Icon(Icons.restore, size: 16),
                label: Text('Use current time'),
                style: AppButtons.text,
              ),
            ],

            AppSpacing.verticalXL,

            // action buttons (cancel & add or update)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: AppButtons.outlined,
                    child: Text('CANCEL'),
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _errorText == null ? _handleAdd : null,
                    style: AppButtons.primary,
                    child: Text(widget.existingLog != null ? 'UPDATE' : 'ADD'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// this is to validates the entered amount
  /// returns error message if invalid, null if valid
  String? _validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an amount';
    }

    int? amount = int.tryParse(value);
    if (amount == null) {
      return 'Please enter a valid number';
    }

    if (amount < 50) {
      return 'Minimum amount is 50ml';
    }

    if (amount > 5000) {
      return 'Maximum amount is 5000ml';
    }

    return null; // Valid
  }

  /// opens time picker dialog
  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedTime),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedTime = DateTime(
          _selectedTime.year,
          _selectedTime.month,
          _selectedTime.day,
          picked.hour,
          picked.minute,
        );
        _isManualTime = true;
      });
    }
  }

  /// handles the add/update button press
  void _handleAdd() {
    final amount = double.tryParse(_amountController.text);
    if (amount != null && _validateAmount(_amountController.text) == null) {
      Navigator.pop(context, {
        'id': widget.existingLog?.id,
        'amount': amount,
        'timestamp': _isManualTime ? _selectedTime : DateTime.now(),
      });
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }
}