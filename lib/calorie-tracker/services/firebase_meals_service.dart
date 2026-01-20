import 'package:firebase_database/firebase_database.dart';
import '../models/meal.dart';
import '../models/food.dart';

/// Firebase service for managing meals data
class FirebaseMealsService {
  final FirebaseDatabase _firebaseDatabase = FirebaseDatabase.instance;
  static const String _mealsPath = 'meals';
  static const String _settingsPath = 'settings';

  /// Get all meals for today
  Future<List<Meal>> getTodayMeals() async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final todayTimestamp = today.millisecondsSinceEpoch;
      
      final ref = _firebaseDatabase.ref().child(_mealsPath);
      final snapshot = await ref.orderByChild('date').startAt(todayTimestamp).endAt(todayTimestamp + 86400000).get();
      
      if (!snapshot.exists) {
        return [];
      }

      List<Meal> meals = [];
      for (final child in snapshot.children) {
        final meal = _mealFromSnapshot(child);
        if (meal != null) {
          meals.add(meal);
        }
      }
      return meals;
    } catch (e) {
      print('Error fetching today meals: $e');
      return [];
    }
  }

  /// Add a new meal
  Future<void> addMeal(Meal meal) async {
    try {
      final ref = _firebaseDatabase.ref().child('$_mealsPath/${meal.id}');
      await ref.set(_mealToMap(meal));
    } catch (e) {
      print('Error adding meal: $e');
      rethrow;
    }
  }

  /// Update an existing meal
  Future<void> updateMeal(Meal meal) async {
    try {
      final ref = _firebaseDatabase.ref().child('$_mealsPath/${meal.id}');
      await ref.set(_mealToMap(meal));
    } catch (e) {
      print('Error updating meal: $e');
      rethrow;
    }
  }

  /// Delete a meal
  Future<void> deleteMeal(String mealId) async {
    try {
      final ref = _firebaseDatabase.ref().child('$_mealsPath/$mealId');
      await ref.remove();
    } catch (e) {
      print('Error deleting meal: $e');
      rethrow;
    }
  }

  /// Get daily calorie goal
  Future<int> getDailyGoal() async {
    try {
      final ref = _firebaseDatabase.ref().child('$_settingsPath/dailyGoal');
      final snapshot = await ref.get();
      
      if (snapshot.exists) {
        return snapshot.value as int;
      }
      return 2500; // Default goal
    } catch (e) {
      print('Error fetching daily goal: $e');
      return 2500;
    }
  }

  /// Save daily calorie goal
  Future<void> saveDailyGoal(int goal) async {
    try {
      final ref = _firebaseDatabase.ref().child('$_settingsPath/dailyGoal');
      await ref.set(goal);
    } catch (e) {
      print('Error saving daily goal: $e');
      rethrow;
    }
  }

  /// Get total calories consumed today
  Future<int> getTodayTotalCalories() async {
    try {
      final meals = await getTodayMeals();
      int total = 0;
      for (final meal in meals) {
        total += meal.totalCalories;
      }
      return total;
    } catch (e) {
      print('Error calculating total calories: $e');
      return 0;
    }
  }

  /// Stream meals updates in real-time
  Stream<List<Meal>> streamTodayMeals() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayTimestamp = today.millisecondsSinceEpoch;
    
    return _firebaseDatabase
        .ref()
        .child(_mealsPath)
        .orderByChild('date')
        .startAt(todayTimestamp)
        .endAt(todayTimestamp + 86400000)
        .onValue
        .map((event) {
      if (!event.snapshot.exists) {
        return [];
      }

      List<Meal> meals = [];
      for (final child in event.snapshot.children) {
        final meal = _mealFromSnapshot(child);
        if (meal != null) {
          meals.add(meal);
        }
      }
      return meals;
    });
  }

  /// Convert Meal to Firebase map
  Map<String, dynamic> _mealToMap(Meal meal) {
    return {
      'id': meal.id,
      'name': meal.name,
      'date': meal.time.millisecondsSinceEpoch,
      'time': meal.time.toIso8601String(),
      'foods': meal.foods.map((f) => {
        'id': f.id,
        'name': f.name,
        'calories': f.calories,
      }).toList(),
    };
  }

  /// Convert Firebase snapshot to Meal
  Meal? _mealFromSnapshot(DataSnapshot snapshot) {
    try {
      final data = snapshot.value as Map<dynamic, dynamic>;
      final id = data['id'] ?? snapshot.key;
      final name = data['name'] ?? 'Meal';
      final timeString = data['time'] ?? DateTime.now().toIso8601String();
      
      final time = DateTime.parse(timeString.toString());
      
      final foodsList = (data['foods'] as List<dynamic>?)?.map((f) {
        final foodData = f as Map<dynamic, dynamic>;
        return Food(
          id: foodData['id'] ?? '',
          name: foodData['name'] ?? '',
          calories: foodData['calories'] ?? 0,
        );
      }).toList() ?? [];

      return Meal(
        id: id,
        name: name,
        time: time,
        foods: foodsList,
      );
    } catch (e) {
      print('Error parsing meal: $e');
      return null;
    }
  }
}
