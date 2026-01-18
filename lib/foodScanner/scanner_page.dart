import 'dart:convert';
import 'package:isar/isar.dart';
import 'scanned_product.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'information_page.dart';

class FoodScannerCameraPage extends StatefulWidget {
  const FoodScannerCameraPage({super.key});

  @override
  State<FoodScannerCameraPage> createState() => _FoodScannerCameraPageState();
}

class _FoodScannerCameraPageState extends State<FoodScannerCameraPage> {
  // scanner controller
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  // flag to prevent multiple fetches at the same time
  bool _isProcessing = false;

  // trigger manual focus
  void _triggerManualFocus() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Refocusing..."),
        duration: Duration(milliseconds: 500),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(bottom: 110, left: 50, right: 50),
      ),
    );

    // restart camera to refocus
    // there isn't a direct manual focus function in mobile_scanner
    await _controller.stop();
    await Future.delayed(const Duration(milliseconds: 100));
    await _controller.start();

    setState(() {
      _isProcessing = false;
    });
  }

  // barcode detection handler
  void _handleBarcodeDetection(BarcodeCapture capture) {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;

    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        setState(() {
          _isProcessing = true;
        });

        final String code = barcode.rawValue!;
        _fetchProduct(code);
        break;
      }
    }
  }

  // fetch product details from OpenFoodFacts
  Future<void> _fetchProduct(String code) async {
    // show loading snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 16),
            Text('Fetching details...'),
          ],
        ),
        // set long duration to ensure it stays until manually hidden
        // when fetch completes of fails
        duration: Duration(minutes: 1),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(bottom: 110, left: 16, right: 16),
        dismissDirection: DismissDirection.none, // prevent swipe to dismiss
      ),
    );

    // fetch product data
    try {
      OpenFoodAPIConfiguration.userAgent = UserAgent(
        name: 'HydraCalFoodScanner',
        url: 'https://github.com/FakeSmile04/hydra-cal',
      );

      final ProductQueryConfiguration configuration = ProductQueryConfiguration(
        code,
        language: OpenFoodFactsLanguage.ENGLISH,
        fields: [
          ProductField.NAME,
          ProductField.BARCODE,
          ProductField.INGREDIENTS_TEXT,
          ProductField.ADDITIVES,
          ProductField.ALLERGENS,
          ProductField.IMAGE_FRONT_URL,
          ProductField.NUTRIMENTS,
          ProductField.NUTRISCORE,
        ],
        version: ProductQueryVersion.v3,
      );

      final ProductResultV3 result = await OpenFoodAPIClient.getProductV3(
        configuration,
      );
      // hide loading snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }

      if (result.status == ProductResultV3.statusSuccess &&
          result.product != null) {
        //save results to scan history
        final isar = Isar.getInstance();
        if (isar != null) {
          final historyItem = ScannedProduct()
            ..barcode = result.product!.barcode ?? code
            ..name = result.product!.productName ?? "Unknown Product"
            ..scanDate = DateTime.now()
            ..productJson = jsonEncode(result.product!.toJson());

          await isar.writeTxn(() async {
            // add the new scanned item
            await isar.scannedProducts.put(historyItem);
            // get all items sorted by date descending
            final allItems = await isar.scannedProducts
                .where()
                .sortByScanDateDesc()
                .findAll();
            // only keep 5 most recent items
            if (allItems.length > 5) {
              // delete everything after the 5th item
              final itemsToDelete = allItems
                  .sublist(5)
                  .map((e) => e.id)
                  .toList();
              await isar.scannedProducts.deleteAll(itemsToDelete);
            }
          });
        }
        // navigate to information page with product details
        if (mounted) {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  FoodScannerInformationPage(product: result.product!),
            ),
          );

          if (mounted) {
            setState(() {
              _isProcessing = false;
            });
          }
        }
      } else {
        _showErrorSnackbar('Product not found in database.');
      }
    } catch (e) {
      // hide loading snackbar if it's still there
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }
      _showErrorSnackbar('Connection failed. Check internet.');
    }
  }

  // show error snackbar
  // this happens when product fetch fails
  void _showErrorSnackbar(String message) {
    if (!mounted) return;

    // this will replace the "Processing" snackbar if it wasn't hidden already
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.deepOrange,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 110, left: 16, right: 16),
        duration: const Duration(seconds: 3),
      ),
    );

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  //main UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // stack layers for camera, focus box, and control bar
      body: Stack(
        children: [
          // camera layer
          MobileScanner(
            controller: _controller,
            onDetect: _handleBarcodeDetection,
            fit: BoxFit.cover,
          ),

          // target box layer
          // this is an overlay box to guide user where to align barcode
          Center(
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.yellow, width: 3),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),

          // control bar layer
          // allows the user to go back, toggle flashlight, and manual focus (if necessary)
          // auto focus is usually enough in most cases
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                color: ThemeData.light().colorScheme.primaryContainer,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // back button
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      size: 30,
                      color: Colors.black,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),

                  // manual focus button
                  GestureDetector(
                    onTap: _triggerManualFocus,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 4),
                        color: Colors.transparent,
                      ),
                      child: const Icon(
                        Icons.filter_center_focus,
                        size: 30,
                        color: Colors.black,
                      ),
                    ),
                  ),

                  // flashlight toggle button
                  ValueListenableBuilder(
                    valueListenable: _controller,
                    builder: (context, state, child) {
                      final isTorchOn = state.torchState == TorchState.on;
                      return IconButton(
                        icon: Icon(
                          isTorchOn
                              ? Icons.flashlight_on
                              : Icons.flashlight_off,
                          size: 30,
                          color: isTorchOn ? Colors.white : Colors.black,
                        ),
                        onPressed: () => _controller.toggleTorch(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // instruction text layer
          // placed above the focus box to guide user
          const Positioned(
            top: 80,
            left: 0,
            right: 0,
            child: Text(
              "Align code within the yellow box",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                shadows: [Shadow(blurRadius: 4, color: Colors.black)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
