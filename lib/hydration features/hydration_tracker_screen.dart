import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'water_log.dart';
import 'settings_screen.dart';
import 'weekly_stats_screen.dart';
import 'database_service.dart';




class HydrationTrackerScreen extends StatefulWidget {
  const HydrationTrackerScreen({super.key});

  @override
  _HydrationTrackerScreenState createState() => _HydrationTrackerScreenState();
}

class _HydrationTrackerScreenState extends State<HydrationTrackerScreen> {
  double _currentIntake = 0.0;
  double _dailyGoal = 2500.0;
  List<WaterLog> _logs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // load data from Isar database
  Future<void> _loadData() async {
    final settings = await DatabaseService().getSettings();
    final logs = await DatabaseService().getTodayLogs();
    final intake = await DatabaseService().getTodayIntake();

    setState(() {
      _dailyGoal = settings.dailyGoal;
      _logs = logs;
      _currentIntake = intake;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.water_drop, size: 28),
            SizedBox(width: 8),
            Text('HydroCal', style: TextStyle(color: Colors.white)),
          ],
        ),
        backgroundColor: Color(0xFF2196F3),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () async {
              final updatedGoal = await Navigator.push<double>(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen()),
              );

              if (updatedGoal != null) {
                setState(() {
                  _dailyGoal = updatedGoal;
                });
              }

              // reload today's intake and logs
              await _loadData();
            },
          ),
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: _showInfo,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData, // pull to refresh
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              SizedBox(height: 24),
              _buildProgressRing(),
              SizedBox(height: 32),
              _buildQuickAddSection(),
              SizedBox(height: 32),
              Divider(),
              SizedBox(height: 24),
              _buildLogSection(),
              SizedBox(height: 24),
              _buildViewStatsButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Today\'s Progress', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
        SizedBox(height: 4),
        Text(DateFormat('EEEE, MMMM d, y').format(DateTime.now()),
            style: TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildProgressRing() {
    double percentage = _currentIntake / _dailyGoal;
    Color progressColor = _getProgressColor(percentage);

    return Center(
      child: CircularPercentIndicator(
        radius: 120.0,
        lineWidth: 15.0,
        percent: percentage.clamp(0.0, 1.0),
        center: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${_currentIntake.toInt()}ml',
                style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: progressColor)),
            Text('of ${_dailyGoal.toInt()}ml'),
            SizedBox(height: 8),
            Text('${(percentage * 100).toInt()}%',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: progressColor)),
          ],
        ),
        progressColor: progressColor,
        backgroundColor: progressColor.withOpacity(0.2),
        circularStrokeCap: CircularStrokeCap.round,
        animation: true,
        animationDuration: 800,
      ),
    );
  }

  Widget _buildQuickAddSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Add', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
        SizedBox(height: 16),
        Row(
          children: [
            _buildQuickAddButton(150),
            _buildQuickAddButton(250),
            _buildQuickAddButton(500),
            _buildCustomButton(),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickAddButton(int amount) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton(
          onPressed: () {
            HapticFeedback.mediumImpact();
            _addWater(amount);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF2196F3),
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text('${amount}ml', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }

  Widget _buildCustomButton() {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4),
        child: OutlinedButton(
          onPressed: _showCustomInputDialog,
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 16),
            side: BorderSide(color: Color(0xFF2196F3), width: 2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text('Custom', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }

  Widget _buildLogSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Today\'s Log', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
        SizedBox(height: 16),
        if (_logs.isEmpty)
          _buildEmptyState()
        else
          ..._logs.map((log) => _buildLogItem(log)),
      ],
    );
  }

  Widget _buildLogItem(WaterLog log) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Dismissible(
        key: Key(log.id.toString()),
        direction: DismissDirection.endToStart,
        background: Container(
          decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12)),
          alignment: Alignment.centerRight,
          padding: EdgeInsets.only(right: 20),
          child: Icon(Icons.delete, color: Colors.white, size: 28),
        ),
        onDismissed: (direction) {
          HapticFeedback.heavyImpact();
          _deleteLog(log);
        },
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: Icon(Icons.water_drop, color: Color(0xFF2196F3), size: 32),
            title: Text('${log.amount}ml', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            subtitle: Text(DateFormat('hh:mm a').format(log.timestamp)),
            trailing: IconButton(
              icon: Icon(Icons.edit, color: Color(0xFF2196F3)),
              onPressed: () => _editWaterLog(log), // open edit dialog
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Column(
          children: [
            Icon(Icons.water_drop_outlined, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text('No water logged today', style: TextStyle(fontSize: 18, color: Colors.grey)),
            SizedBox(height: 8),
            Text('Tap a button above to start tracking!', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildViewStatsButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => WeeklyStatsScreen()));
        },
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 16),
          side: BorderSide(color: Color(0xFF2196F3), width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        icon: Icon(Icons.bar_chart),
        label: Text('View Weekly Stats'),
      ),
    );
  }

  Color _getProgressColor(double percentage) {
    if (percentage < 0.3) return Color(0xFFEF5350);
    if (percentage < 0.7) return Color(0xFFFFA726);
    return Color(0xFF66BB6A);
  }
  Future<void> _editWaterLog(WaterLog log) async {
    final amountController = TextEditingController(text: log.amount.toString());
    TimeOfDay selectedTime = TimeOfDay.fromDateTime(log.timestamp);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Water Log'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Amount (ml)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Text('Time: ${selectedTime.format(context)}'),
                Spacer(),
                TextButton(
                  onPressed: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                    );
                    if (time != null) {
                      selectedTime = time;
                      setState(() {}); // refresh displayed time
                    }
                  },
                  child: Text('Change'),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: Text('Save')),
        ],
      ),
    );

    if (confirmed == true) {
      final updatedTimestamp = DateTime(
        log.timestamp.year,
        log.timestamp.month,
        log.timestamp.day,
        selectedTime.hour,
        selectedTime.minute,
      );

      final updatedLog = log
        ..amount = int.tryParse(amountController.text) ?? log.amount
        ..timestamp = updatedTimestamp;

      await DatabaseService().updateWaterLog(updatedLog); // implement this method
      await _loadData(); // refresh screen
    }
  }

  // add water to database
  Future<void> _addWater(int amount) async {
    await DatabaseService().addWaterLog(amount, DateTime.now());
    await _loadData();
    _showFeedback('${amount}ml added successfully!');
  }

  // delete from database
  Future<void> _deleteLog(WaterLog log) async {
    await DatabaseService().deleteWaterLog(log.id);
    await _loadData();
    _showFeedback('Log deleted');
  }

  Future<void> _showCustomInputDialog() async {
    final controller = TextEditingController();

    final result = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Custom Amount'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: InputDecoration(
            labelText: 'Amount',
            suffixText: 'ml',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('CANCEL')),
          ElevatedButton(
            onPressed: () {
              final amount = int.tryParse(controller.text);
              if (amount != null && amount > 0) {
                Navigator.pop(context, amount);
              }
            },
            child: Text('ADD'),
          ),
        ],
      ),
    );

    if (result != null) {
      await _addWater(result);
    }
  }

  void _showFeedback(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('About Hydration Tracking'),
        content: Text('Track your daily water intake to stay healthy and hydrated!'),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('Got it!'))],
      ),
    );
  }
}