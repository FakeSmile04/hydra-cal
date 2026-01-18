import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:mobapp_gpproject_hydracal_foodscanner/foodScanner/scanner_page.dart';
import 'package:mobapp_gpproject_hydracal_foodscanner/foodScanner/preferences_page.dart';
import 'package:mobapp_gpproject_hydracal_foodscanner/foodScanner/information_page.dart';
import 'flagged_ingredient.dart'; // list of ingredients that can be flagged
import 'scanned_product.dart'; // list of scanned products

class FoodScannerHomePage extends StatefulWidget {
  const FoodScannerHomePage({super.key});

  @override
  State<FoodScannerHomePage> createState() => _FoodScannerHomePageState();
}

class _FoodScannerHomePageState extends State<FoodScannerHomePage> {
  // set ui to not ready to check for database initialization
  // to prevent crashes in information and preferences pages later on
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  // initialize isar database
  Future<void> _initDatabase() async {
    final dir = await getApplicationDocumentsDirectory();

    // check if instance is already open to avoid errors
    Isar? isar = Isar.getInstance();

    // open the flagged ingredient and scanned products databases
    // if it's not opened yet
    isar ??= await Isar.open([
      FlaggedIngredientSchema,
      ScannedProductSchema,
    ], directory: dir.path);

    // seed common 14 allergens if database is empty
    if (await isar.flaggedIngredients.count() == 0) {
      await _seedCommonAllergens(isar);
    }

    // update state / ui to ready
    if (mounted) {
      setState(() {
        _isReady = true;
      });
    }
  }

  //list of 14 common allergens to seed into database
  Future<void> _seedCommonAllergens(Isar isar) async {
    // these tags align with OpenFoodFacts' official "en:" English taxonomy
    // reference: https://world.openfoodfacts.org/allergens
    final List<Map<String, String>> commonAllergens = [
      // top 14 common allergens - EU standard
      {'name': 'Gluten', 'tag': 'en:gluten'},
      {'name': 'Peanuts', 'tag': 'en:peanuts'},
      {'name': 'Milk (Lactose)', 'tag': 'en:milk'},
      {'name': 'Eggs', 'tag': 'en:eggs'},
      {'name': 'Soybeans', 'tag': 'en:soybeans'},
      {'name': 'Fish', 'tag': 'en:fish'},
      {
        'name': 'Crustaceans (Shellfish)',
        'tag': 'en:crustaceans',
      }, // Shrimp, Crab, Lobster
      {
        'name': 'Molluscs (Shellfish)',
        'tag': 'en:molluscs',
      }, // Clams, Oysters, Squid
      {'name': 'Tree Nuts', 'tag': 'en:nuts'}, // Almonds, Walnuts, Cashews
      {'name': 'Sesame Seeds', 'tag': 'en:sesame-seeds'},
      {'name': 'Celery', 'tag': 'en:celery'},
      {'name': 'Mustard', 'tag': 'en:mustard'},
      {'name': 'Lupin', 'tag': 'en:lupin'},
      {'name': 'Sulfites', 'tag': 'en:sulphur-dioxide-and-sulphites'},

      // flags for Haram substances
      {'name': 'Pork', 'tag': 'en:pork'},
      {'name': 'Alcohol', 'tag': 'en:alcohol'},
    ];

    // create FlaggedIngredient widgets from the list
    final batch = commonAllergens.map((e) {
      return FlaggedIngredient(
        name: e['name']!,
        tag: e['tag']!,
        isSelected: false,
      );
    }).toList();

    // write to isar database
    await isar.writeTxn(() async {
      await isar.flaggedIngredients.putAll(batch);
    });
  }

  // navigate to scanner page
  void _goToScanner() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FoodScannerCameraPage()),
    );
  }

  // navigate to preferences page
  void _goToPreferences() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const FoodScannerPreferencesPage(),
      ),
    );
  }

  // show 5 recent scans in a bottom sheet
  void _showScanHistory() async {
    final isar = Isar.getInstance();
    if (isar == null) return;

    final history = await isar.scannedProducts
        .where()
        .sortByScanDateDesc()
        .limit(5)
        .findAll();

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: 400,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Recent Scans",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const Divider(),
              if (history.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(child: Text("No history yet.")),
                )
              else
                Expanded(
                  child: ListView.separated(
                    itemCount: history.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (ctx, index) {
                      final item = history[index];
                      return ListTile(
                        leading: const Icon(Icons.qr_code_2),
                        title: Text(
                          item.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(item.barcode),
                        onTap: () {
                          Navigator.pop(context); // Close sheet
                          _navigateToProduct(item.productJson);
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  // navigate to information page with product data
  void _navigateToProduct(String jsonString) {
    try {
      final Map<String, dynamic> productMap = jsonDecode(jsonString);
      final Product product = Product.fromJson(productMap);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FoodScannerInformationPage(product: product),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Error loading product.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    // loading screen while database initializes
    // to prevent crashes
    if (!_isReady) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Loading...'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text("Initializing Database..."),
            ],
          ),
        ),
      );
    }

    // home page UI
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Scanner'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showScanHistory,
        icon: const Icon(Icons.history),
        label: const Text("History"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FilledButton.tonalIcon(
              onPressed: _goToScanner,
              icon: const Icon(Icons.camera_alt_outlined, size: 32),
              label: const Text(
                'Open Scanner',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w400),
              ),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 30,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 50),
            FilledButton.tonalIcon(
              onPressed: _goToPreferences,
              icon: const Icon(Icons.settings_outlined, size: 32),
              label: const Text('Preferences', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w400)),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 30,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
