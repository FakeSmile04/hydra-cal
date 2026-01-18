import 'package:isar/isar.dart';

part 'flagged_ingredient.g.dart';

@collection
class FlaggedIngredient {
  Id id = Isar.autoIncrement;

  @Index(type: IndexType.value)
  late String name; // The display name (e.g., "Peanuts")

  late String tag; // The API tag (e.g., "en:peanuts")

  bool isSelected; // checkbox state if user wants to flag an ingredient

  FlaggedIngredient({
    required this.name,
    required this.tag,
    this.isSelected = false,
  });
}