import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'flagged_ingredient.dart'; // flagged ingredient schema

class FoodScannerPreferencesPage extends StatefulWidget {
  const FoodScannerPreferencesPage({super.key});

  @override
  State<FoodScannerPreferencesPage> createState() =>
      _FoodScannerPreferencesPageState();
}

class _FoodScannerPreferencesPageState
    extends State<FoodScannerPreferencesPage> {
  late final Isar _isar;

  // local state to hold ingredient selections
  // changes will not reflect in the database until user saves
  List<FlaggedIngredient> _localIngredients = [];
  bool _isLoading = true;

  // track if there are unsaved changes
  bool _hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // load flagged ingredients from database
  Future<void> _loadData() async {
    final isar = Isar.getInstance();
    if (isar != null) {
      _isar = isar;

      final data = await _isar.flaggedIngredients
          .where()
          .sortByName()
          .findAll();

      if (mounted) {
        setState(() {
          _localIngredients = data;
          _isLoading = false;
          _hasUnsavedChanges = false; // reset unsaved changes flag on load
        });
      }
    }
  }

  // toggle ingredient selection in local state
  void _toggleLocal(int index, bool? value) {
    setState(() {
      _localIngredients[index].isSelected = value ?? false;
      _hasUnsavedChanges = true; // mark as dirty when changed
    });
  }

  // save local changes to database
  Future<void> _saveChanges() async {
    try {
      await _isar.writeTxn(() async {
        await _isar.flaggedIngredients.putAll(_localIngredients);
      });

      if (mounted) {
        setState(() {
          _hasUnsavedChanges = false; // reset flag after successful save
        });

        // success snackbar after saving
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 10),
                Text('Preferences saved successfully!'),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  // show confirmation dialog on exit
  // if there are unsaved changes
  Future<void> _showExitConfirmation() async {
    final shouldClose = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unsaved Changes'),
        content: const Text(
          'You have unsaved changes. Do you want to save them before leaving?',
        ),
        actions: [
          // cancel button: stay on page
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          // discard button: leave without saving
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Discard',
              style: TextStyle(color: Colors.black),
            ),
          ),
          // save & exit button
          FilledButton(
            onPressed: () async {
              final nav = Navigator.of(context);
              nav.pop(false); //close dialog box
              await _saveChanges();
              if (mounted) nav.pop();
            },
            child: const Text('Save & Exit'),
          ),
        ],
      ),
    );

    // if user clicked "Discard", close the page
    if (shouldClose == true && mounted) {
      Navigator.of(context).pop();
    }
  }

  // main UI
  @override
  Widget build(BuildContext context) {
    // wrap with PopScope to intercept back navigation
    // in order for confirmation dialog to work
    return PopScope(
      canPop:
          !_hasUnsavedChanges, // only allow pop if there are no unsaved changes
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        _showExitConfirmation(); // show dialog box
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Preferences'),
          centerTitle: true,
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          // save button
          actions: [
            IconButton(
              onPressed: _saveChanges,
              icon: const Icon(Icons.save, color: Colors.black),
              tooltip: "Save Changes",
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      "Ingredients to Avoid",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(height: 20),
                    const Text(
                      "The application will flag these ingredients if it is present in your food.",
                      style: TextStyle(fontSize: 15, color: Colors.black),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: _localIngredients.isEmpty
                          ? const Center(
                              child: Text(
                                "No ingredients found. Try restart the application.",
                              ),
                            )
                          : ListView(
                              itemExtent: null,
                              children: List.generate(
                                _localIngredients.length,
                                (index) {
                                  final item = _localIngredients[index];
                                  return CheckboxListTile(
                                    title: Text(item.name),
                                    value: item.isSelected,
                                    activeColor: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    onChanged: (val) =>
                                        _toggleLocal(index, val),
                                    secondary: CircleAvatar(
                                      backgroundColor: Theme.of(
                                        context,
                                      ).colorScheme.primaryContainer,
                                      child: Text(
                                        item.name.isNotEmpty
                                            ? item.name
                                                  .substring(0, 1)
                                                  .toUpperCase()
                                            : "?",
                                        style: TextStyle(
                                          color: Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}