import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';
import 'app_spacing.dart';
import 'app_buttons.dart';
import 'app_input_decoration.dart';
import 'app_card.dart';
import 'recalculate_result_dialog.dart';
import 'package:flutter/material.dart';
import 'database_service.dart';
import 'user_settings.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _weightController = TextEditingController();
  final _ageController = TextEditingController();
  final _goalController = TextEditingController();

  String _gender = 'male';
  String _activityLevel = 'moderate';
  double _currentGoal = 2500;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // load from Isar database
  Future<void> _loadSettings() async {
    final settings = await DatabaseService().getSettings();

    setState(() {
      _weightController.text = settings.weight.toString();
      _ageController.text = settings.age.toString();
      _gender = settings.gender;
      _activityLevel = settings.activityLevel;
      _currentGoal = settings.dailyGoal;
      _goalController.text = _currentGoal.toInt().toString();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('SETTINGS'), backgroundColor: Color(0xFF2196F3)),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('SETTINGS', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF2196F3),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('👤 PROFILE INFORMATION',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[600])),
            SizedBox(height: 16),
            _buildProfileCard(),
            SizedBox(height: 32),
            Text('💧 HYDRATION GOAL',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[600])),
            SizedBox(height: 16),
            _buildGoalCard(),
            SizedBox(height: 32),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Weight:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            SizedBox(height: 8),
            TextField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                suffixText: 'kg',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            SizedBox(height: 16),
            Text('Age:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            SizedBox(height: 8),
            TextField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                suffixText: 'years',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            SizedBox(height: 16),
            Text('Gender:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: Text('Male'),
                    value: 'male',
                    groupValue: _gender,
                    onChanged: (v) => setState(() => _gender = v!),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: Text('Female'),
                    value: 'female',
                    groupValue: _gender,
                    onChanged: (v) => setState(() => _gender = v!),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text('Activity Level:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            _buildActivityLevel('sedentary', 'Sedentary', 'Office work'),
            _buildActivityLevel('moderate', 'Moderate', 'Light exercise'),
            _buildActivityLevel('active', 'Active', 'Regular exercise'),
            _buildActivityLevel('veryActive', 'Very Active', 'Intense training'),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityLevel(String value, String title, String subtitle) {
    return RadioListTile<String>(
      title: Text(title),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12)),
      value: value,
      groupValue: _activityLevel,
      onChanged: (v) => setState(() => _activityLevel = v!),
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }

  Widget _buildGoalCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Current Goal:', style: TextStyle(fontSize: 16)),
                  Text('${_currentGoal.toInt()} ml/day',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2196F3))),
                ],
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _recalculateGoal,
                icon: Icon(Icons.calculate),
                label: Text('RECALCULATE GOAL'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2196F3),
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            SizedBox(height: 16),
            Divider(),
            SizedBox(height: 16),
            Text('Or set manually:', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            SizedBox(height: 8),
            TextField(
              controller: _goalController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                suffixText: 'ml',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (value) {
                final goal = double.tryParse(value);
                if (goal != null) setState(() => _currentGoal = goal);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: Color(0xFF2196F3), width: 2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('CANCEL'),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _saveSettings,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF2196F3),
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('SAVE'),
          ),
        ),
      ],
    );
  }

  Future<void> _recalculateGoal() async {
    final weight = double.tryParse(_weightController.text);
    if (weight == null) return;

    final newGoal = _calculateGoal(weight, _gender, _activityLevel);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('New Daily Goal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.water_drop, size: 64, color: Color(0xFF2196F3)),
            SizedBox(height: 16),
            Text('${newGoal.toInt()} ml', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Color(0xFF2196F3))),
            Text('per day'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('CANCEL')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: Text('APPLY')),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _currentGoal = newGoal;
        _goalController.text = newGoal.toInt().toString();
      });
    }
  }

  double _calculateGoal(double weight, String gender, String activity) {
    double base = weight * 33;
    double activityBonus = {
      'sedentary': 0.0,
      'moderate': 300.0,
      'active': 500.0,
      'veryActive': 700.0,
    }[activity] ?? 0.0;
    double genderAdjustment = gender == 'male' ? 100.0 : 0.0;
    return ((base + activityBonus + genderAdjustment) / 100).round() * 100.0;
  }

  // save to Isar database
  Future<void> _saveSettings() async {
    final weight = double.tryParse(_weightController.text);
    final age = int.tryParse(_ageController.text);
    final goal = double.tryParse(_goalController.text);

    if (weight == null || age == null || goal == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields correctly'), backgroundColor: Colors.red),
      );
      return;
    }

    // load the existing settings from database
    final settings = await DatabaseService().getSettings();

    // update the fields
    settings.weight = weight;
    settings.age = age;
    settings.gender = _gender;
    settings.activityLevel = _activityLevel;
    settings.dailyGoal = goal;
    settings.lastUpdated = DateTime.now();

    await DatabaseService().updateSettings(settings);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Settings saved successfully!'), backgroundColor: Colors.green),
    );


    Navigator.pop(context, goal);
  }

  @override
  void dispose() {
    _weightController.dispose();
    _ageController.dispose();
    _goalController.dispose();
    super.dispose();
  }
}