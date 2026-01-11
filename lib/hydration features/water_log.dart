
import 'package:isar/isar.dart';

part 'water_log.g.dart';

@Collection()
class WaterLog {
  Id id = Isar.autoIncrement;

  late int amount;
  late DateTime timestamp;

  @Index()
  late String dateString;

  WaterLog({
    this.id = Isar.autoIncrement,
    required this.amount,
    required this.timestamp,
  }) {
    dateString = _getDateString(timestamp);
  }

  String _getDateString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  static String getTodayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}