import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'water_log.dart';
import 'user_settings.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Isar? _isar;

  Future<void> initialize() async {
    if (_isar != null) return;

    final dir = await getApplicationDocumentsDirectory();

    _isar = await Isar.open(
      [WaterLogSchema, UserSettingsSchema],
      directory: dir.path,
    );
  }

  Isar get isar {
    if (_isar == null) {
      throw Exception('Database not initialized. Call initialize() first.');
    }
    return _isar!;
  }

  // get user settings
  Future<UserSettings> getSettings() async {
    var settings = await isar.userSettings.get(1);

    if (settings == null) {
      settings = UserSettings(lastUpdated: DateTime.now());
      await isar.writeTxn(() async {
        await isar.userSettings.put(settings!);
      });
    }

    return settings;
  }

  // update user settings
  Future<void> updateSettings(UserSettings settings) async {
    settings.lastUpdated = DateTime.now();
    await isar.writeTxn(() async {
      await isar.userSettings.put(settings);
    });
  }

  // update daily goal only
  Future<void> updateDailyGoal(double goal) async {
    final settings = await getSettings();
    settings.dailyGoal = goal;
    await updateSettings(settings);
  }

  // add water log
  Future<void> addWaterLog(int amount, DateTime timestamp) async {
    final log = WaterLog(
      amount: amount,
      timestamp: timestamp,
    );

    await isar.writeTxn(() async {
      await isar.waterLogs.put(log);
    });
  }

  // get today's water logs
  Future<List<WaterLog>> getTodayLogs() async {
    final todayString = WaterLog.getTodayString();

    return await isar.waterLogs
        .filter()
        .dateStringEqualTo(todayString)
        .sortByTimestampDesc()
        .findAll();
  }

// get total water intake for today
  Future<double> getTodayIntake() async {
    final logs = await getTodayLogs();
    return logs.fold<double>(0.0, (double sum, log) => sum + log.amount.toDouble());
  }

// get logs for a specific date
  Future<List<WaterLog>> getLogsForDate(DateTime date) async {
    final dateString =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    return await isar.waterLogs
        .filter()
        .dateStringEqualTo(dateString)
        .sortByTimestampDesc()
        .findAll();
  }

// get total intake for a specific date
  Future<double> getIntakeForDate(DateTime date) async {
    final logs = await getLogsForDate(date);
    return logs.fold<double>(0.0, (double sum, log) => sum + log.amount.toDouble());
  }

// get weekly data
  Future<Map<String, double>> getWeeklyData() async {
    final Map<String, double> weeklyData = {};
    final now = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayName = _getDayName(date.weekday);
      final intake = await getIntakeForDate(date); // uses fold<double> internally
      weeklyData[dayName] = intake;
    }

    return weeklyData;
  }

  String _getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }
  Future<void> updateWaterLog(WaterLog log) async {
    await isar.writeTxn(() async {
      await isar.waterLogs.put(log);
    });
  }

  // delete water log
  Future<void> deleteWaterLog(int logId) async {
    await isar.writeTxn(() async {
      await isar.waterLogs.delete(logId);
    });
  }
}