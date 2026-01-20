import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/meal.dart';
import '../models/food.dart';

/// Firestore service for managing meals data
class FirestoreMealsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _mealsCollection = 'meals';
  static const String _settingsCollection = 'settings';
  static const String _settingsDoc = 'userSettings';

  /// Get all meals for today
  Future<List<Meal>> getTodayMeals() async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final querySnapshot = await _firestore
          .collection(_mealsCollection)
          .where('date',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThan: Timestamp.fromDate(endOfDay))
          .orderBy('date', descending: false)
          .get();

      return querySnapshot.docs
          .map((doc) => _mealFromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error fetching today meals: $e');
      return [];
    }
  }

  /// Add a new meal to Firestore
  Future<void> addMeal(Meal meal) async {
    try {
      await _firestore
          .collection(_mealsCollection)
          .doc(meal.id)
          .set(_mealToFirestore(meal));
    } catch (e) {
      print('Error adding meal: $e');
      rethrow;
    }
  }

  /// Update an existing meal in Firestore
  Future<void> updateMeal(Meal meal) async {
    try {
      await _firestore
          .collection(_mealsCollection)
          .doc(meal.id)
          .update(_mealToFirestore(meal));
    } catch (e) {
      print('Error updating meal: $e');
      rethrow;
    }
  }

  /// Delete a meal from Firestore
  Future<void> deleteMeal(String mealId) async {
    try {
      await _firestore.collection(_mealsCollection).doc(mealId).delete();
    } catch (e) {
      print('Error deleting meal: $e');
      rethrow;
    }
  }

  /// Get daily calorie goal
  Future<int> getDailyGoal() async {
    try {
      final doc = await _firestore
          .collection(_settingsCollection)
          .doc(_settingsDoc)
          .get();

      if (doc.exists) {
        return doc['dailyGoal'] ?? 2500;
      }
      return 2500; // Default goal
    } catch (e) {
      print('Error fetching daily goal: $e');
      return 2500;
    }
  }

  /// Save daily calorie goal to Firestore
  Future<void> saveDailyGoal(int goal) async {
    try {
      await _firestore
          .collection(_settingsCollection)
          .doc(_settingsDoc)
          .set({'dailyGoal': goal}, SetOptions(merge: true));
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

  /// Stream today's meals in real-time
  Stream<List<Meal>> streamTodayMeals() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _firestore
        .collection(_mealsCollection)
        .where('date',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThan: Timestamp.fromDate(endOfDay))
        .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => _mealFromFirestore(doc))
          .toList();
    });
  }

  /// Stream daily goal changes in real-time
  Stream<int> streamDailyGoal() {
    return _firestore
        .collection(_settingsCollection)
        .doc(_settingsDoc)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        return snapshot['dailyGoal'] ?? 2500;
      }
      return 2500;
    });
  }

  /// Convert Meal to Firestore map
  Map<String, dynamic> _mealToFirestore(Meal meal) {
    return {
      'id': meal.id,
      'name': meal.name,
      'date': Timestamp.fromDate(meal.time),
      'time': meal.time.toIso8601String(),
      'foods': meal.foods
          .map((f) => {
                'id': f.id,
                'name': f.name,
                'calories': f.calories,
              })
          .toList(),
    };
  }

  /// Convert Firestore document to Meal
  Meal _mealFromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    
    final id = data['id'] ?? doc.id;
    final name = data['name'] ?? 'Meal';
    final timeString = data['time'] ?? DateTime.now().toIso8601String();
    final time = DateTime.parse(timeString.toString());

    final foodsList = ((data['foods'] as List<dynamic>?) ?? [])
        .map((f) {
          final foodData = f as Map<dynamic, dynamic>;
          return Food(
            id: foodData['id']?.toString() ?? '',
            name: foodData['name']?.toString() ?? '',
            calories: (foodData['calories'] as num?)?.toInt() ?? 0,
          );
        })
        .toList();

    return Meal(
      id: id,
      name: name,
      time: time,
      foods: foodsList,
    );
  }
}
