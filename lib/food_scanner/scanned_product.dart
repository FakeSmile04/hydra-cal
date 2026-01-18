import 'package:isar/isar.dart';

part 'scanned_product.g.dart';

@collection
class ScannedProduct {
  Id id = Isar.autoIncrement;

  late String barcode;
  late String name;
  late DateTime scanDate;

  // store the full product data as a JSON string.
  // this allows for offline use without re-fetching from the API
  late String productJson; 
}