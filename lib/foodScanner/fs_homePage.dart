import 'package:flutter/material.dart';
import 'package:mobapp_gpproject_hydracal_foodscanner/foodScanner/fs_scannerPage.dart';
import 'package:mobapp_gpproject_hydracal_foodscanner/foodScanner/fs_preferencesPage.dart';

// Importing the Information Page for debug purposes
import 'package:mobapp_gpproject_hydracal_foodscanner/foodScanner/fs_informationPage.dart';

class FoodScannerHomePage extends StatelessWidget {
  const FoodScannerHomePage({super.key});

void _goToScanner (BuildContext context) {
  print("Navigating to Scanner...");
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const FoodScannerCameraPage(),
    ),
  );
}

void _goToPreferences (BuildContext context) {
  print("Navigating to Preferences...");
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const FoodScannerPreferencesPage(),
    ),
  );
}

//debug function to navigate to Information Page
void _goToInformation (BuildContext context) {
  print("Navigating to Information Page...");
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const FoodScannerInformationPage(),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Scanner'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FilledButton.tonalIcon(
              onPressed: () => _goToScanner(context),
              icon: Icon(
                Icons.camera_alt_outlined,
                size: 32,
                color: Theme.of(context).colorScheme.primary,
              ),
              label: Text(
                'Open Scanner',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 30),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 50),
            FilledButton.tonalIcon(
              onPressed: () => _goToPreferences(context),
              icon: Icon(
                Icons.settings,
                size: 32,
                color: Theme.of(context).colorScheme.primary,
              ),
              label: Text(
                'Preferences',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 30),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>_goToInformation(context),
        tooltip: 'Information(debug)',
        child: const Icon(Icons.info_outline),
        ),
    );
  }
}