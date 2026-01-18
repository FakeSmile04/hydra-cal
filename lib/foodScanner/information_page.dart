// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:isar/isar.dart';
import 'flagged_ingredient.dart'; // flagged ingredient schema

class FoodScannerInformationPage extends StatefulWidget {
  final Product product;

  const FoodScannerInformationPage({super.key, required this.product});

  @override
  State<FoodScannerInformationPage> createState() =>
      _FoodScannerInformationPageState();
}

class _FoodScannerInformationPageState
    extends State<FoodScannerInformationPage> {
  // state to hold the results of analysis
  List<String> _matchedWarnings = [];
  bool _isAnalyzing = true;

  @override
  void initState() {
    super.initState();
    _analyzeProductSafety();
  }

  // analyze product details against user preferences
  Future<void> _analyzeProductSafety() async {
    final isar = Isar.getInstance();

    // make sure database is already initialized
    if (isar == null) {
      setState(() => _isAnalyzing = false);
      return;
    }

    // get user's blacklisted ingredients from database
    final userBlacklist = await isar.flaggedIngredients
        .filter()
        .isSelectedEqualTo(true)
        .findAll();

    // collect all tags from the product (Allergens, Additives, Traces, Ingredients)
    // use Set to avoid duplicates
    final Set<String> productTags = {};

    if (widget.product.allergens?.ids != null) {
      productTags.addAll(widget.product.allergens!.ids);
    }
    if (widget.product.additives?.names != null) {
      productTags.addAll(widget.product.additives!.names);
    }
    if (widget.product.tracesTags != null) {
      productTags.addAll(widget.product.tracesTags!);
    }
    if (widget.product.ingredientsTags != null) {
      productTags.addAll(widget.product.ingredientsTags!);
    }

    // find matches between product tags and user blacklist
    final List<String> warnings = [];

    // pre-calculate raw text for fallback search
    // in case tags are missing
    final String rawIngredients =
        widget.product.ingredientsText?.toLowerCase() ?? "";

    for (final bannedItem in userBlacklist) {
      bool found = false;

      // check for tags first
      if (productTags.contains(bannedItem.tag)) {
        found = true;
      }
      // fallback: check raw ingredients text for name match
      // check if the name (e.g., "Soybeans") appears in the text
      else if (rawIngredients.contains(bannedItem.name.toLowerCase())) {
        found = true;
      }

      if (found) {
        warnings.add(bannedItem.name);
      }
    }

    //food tag console debug
    print("--- DEBUG: PRODUCT TAGS ---");
    for (var tag in productTags) {
      print(tag);
    }
    print("---------------------------");

    // update state with results
    if (mounted) {
      setState(() {
        _matchedWarnings = warnings;
        _isAnalyzing = false;
      });
    }
  }

  // main UI
  @override
  Widget build(BuildContext context) {
    // Lavender color from your design
    final Color lavenderHeaderColor = const Color(0xFFE0C3FC);

    // determine status
    final bool isSafe = !_isAnalyzing && _matchedWarnings.isEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Information',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w400),
        ),
        centerTitle: true,
        backgroundColor: lavenderHeaderColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isAnalyzing
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // header: barcode - product name
                  Text(
                    '${widget.product.barcode ?? "Unknown"} - ${widget.product.productName ?? "Food Name"}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Divider(color: Colors.grey, thickness: 1),
                  const SizedBox(height: 10),

                  // subtitle: safety status
                  Text(
                    "The application will warn you if any checked ingredients from your preferences are found.",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // flagged items list
                  if (!isSafe)
                    ..._matchedWarnings.map(
                      (ingredient) => _buildWarningListItem(ingredient),
                    )
                  else
                    _buildSafeListItem(),

                  // nutrition & ingredients list
                  // for user reference
                  if (widget.product.nutriments != null ||
                      widget.product.ingredientsText != null) ...[
                    const Divider(color: Colors.grey, thickness: 1),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        "Comprehensive Nutrition (per 100g)",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],

                  if (widget.product.nutriments != null)
                    _buildExtendedNutritionSection(widget.product.nutriments!),

                  if (widget.product.ingredientsText != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Text(
                        "Full Ingredients: ${widget.product.ingredientsText}",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  // build list item for tagged / warned ingredients
  Widget _buildWarningListItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.priority_high,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              "Contains $text",
              style: const TextStyle(fontSize: 18, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  // build list item for safe status
  Widget _buildSafeListItem() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.green.shade600,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 15),
          const Expanded(
            child: Text(
              "Safe based on your preferences.",
              style: TextStyle(fontSize: 18,),
            ),
          ),
        ],
      ),
    );
  }

  // build nutrition section
  Widget _buildExtendedNutritionSection(Nutriments nutriments) {
    final Map<Nutrient, String> nutrientMap = {
      Nutrient.energyKCal: "Energy (kcal)",
      Nutrient.fat: "Total Fat",
      Nutrient.saturatedFat: "Saturated Fat",
      Nutrient.carbohydrates: "Carbohydrates",
      Nutrient.sugars: "Sugars",
      Nutrient.fiber: "Fiber",
      Nutrient.proteins: "Proteins",
      Nutrient.salt: "Salt",
      Nutrient.sodium: "Sodium",
      Nutrient.calcium: "Calcium",
      Nutrient.iron: "Iron",
      Nutrient.cholesterol: "Cholesterol",
    };

    List<Widget> rows = [];

    nutrientMap.forEach((nutrient, label) {
      final double? value = nutriments.getValue(
        nutrient,
        PerSize.oneHundredGrams,
      );

      if (value != null) {
        String unit = _guessUnit(nutrient);
        rows.add(
          _buildSimpleNutrientRow(label, "${value.toStringAsFixed(1)} $unit"),
        );
      }
    });

    if (rows.isEmpty) {
      return const Text("No nutrition data available.");
    }

    return Column(children: rows);
  }

  String _guessUnit(Nutrient nutrient) {
    if ([
      Nutrient.fat,
      Nutrient.saturatedFat,
      Nutrient.carbohydrates,
      Nutrient.sugars,
      Nutrient.fiber,
      Nutrient.proteins,
      Nutrient.salt,
    ].contains(nutrient)) {
      return "g";
    }
    if ([
      Nutrient.calcium,
      Nutrient.iron,
      Nutrient.cholesterol,
      Nutrient.sodium,
    ].contains(nutrient)) {
      return "mg";
    }
    if (nutrient == Nutrient.energyKCal) return "kcal";
    return "";
  }

  Widget _buildSimpleNutrientRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
