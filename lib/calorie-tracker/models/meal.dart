import 'food.dart';

/// Meal model class representing a single meal entry
class Meal {
  final String id;
  final String name;
  final DateTime time;
  final List<Food> foods;

  Meal({
    String? id,
    required this.name,
    required this.time,
    List<Food>? foods,
  })  : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        foods = foods ?? [];

  /// Get total calories for this meal
  int get totalCalories => foods.fold(0, (sum, food) => sum + food.calories);

  /// Create a copy of the meal with updated fields
  Meal copyWith({
    String? id,
    String? name,
    DateTime? time,
    List<Food>? foods,
  }) {
    return Meal(
      id: id ?? this.id,
      name: name ?? this.name,
      time: time ?? this.time,
      foods: foods ?? this.foods,
    );
  }

  /// Add a food to this meal
  Meal addFood(Food food) {
    return copyWith(foods: [...foods, food]);
  }

  /// Remove a food from this meal
  Meal removeFood(String foodId) {
    return copyWith(foods: foods.where((f) => f.id != foodId).toList());
  }

  /// Update a food in this meal
  Meal updateFood(Food updatedFood) {
    return copyWith(
      foods: foods.map((f) => f.id == updatedFood.id ? updatedFood : f).toList(),
    );
  }
}

