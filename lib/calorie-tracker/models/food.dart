/// Food item model with nutritional information
class Food {
  final String id;
  final String name;
  final int calories;

  Food({
    String? id,
    required this.name,
    required this.calories,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  /// Create a copy of the food with updated fields
  Food copyWith({
    String? id,
    String? name,
    int? calories,
  }) {
    return Food(
      id: id ?? this.id,
      name: name ?? this.name,
      calories: calories ?? this.calories,
    );
  }
}
