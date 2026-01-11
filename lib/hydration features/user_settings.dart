import 'package:isar/isar.dart';

part 'user_settings.g.dart';

@Collection()
class UserSettings {
  Id id = Isar.autoIncrement;

  late double weight;
  late int age;
  late String gender;
  late String activityLevel;
  late double dailyGoal;

  DateTime? lastUpdated;

  UserSettings({
    this.id = Isar.autoIncrement,
    this.weight = 70.0,
    this.age = 28,
    this.gender = 'male',
    this.activityLevel = 'moderate',
    this.dailyGoal = 2500.0,
    this.lastUpdated, // must match property type
  });
}
