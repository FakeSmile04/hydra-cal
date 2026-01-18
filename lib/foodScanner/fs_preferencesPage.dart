import 'package:flutter/material.dart';

//create Ingredient class to make Ingredient objects
class Ingredient {
  final String name;
  bool isSelected;

  Ingredient({required this.name, this.isSelected = false});
}

class FoodScannerPreferencesPage extends StatefulWidget{
  const FoodScannerPreferencesPage({super.key});

  @override
  State<FoodScannerPreferencesPage> createState() => _FoodScannerPreferencesPageState();
}

class _FoodScannerPreferencesPageState extends State<FoodScannerPreferencesPage>{

  //dummy list, need to add proper premade lists + custom add
  final List<Ingredient> _ingredients = [
    Ingredient(name: 'Artificial Flavors'),
    Ingredient(name: 'High Fructose Corn Syrup'),
    Ingredient(name: 'Monosodium Glutamate (MSG)'),
    Ingredient(name: 'Aspartame'),
    Ingredient(name: 'Sodium Nitrite'),
  ];

  void _checkboxToggle (bool? updatedValue, Ingredient ingredient){
    setState(() {
    ingredient.isSelected = updatedValue ?? false;
    //debug
    print("${ingredient.name} is ${ingredient.isSelected ? 'checked' : 'unchecked'}");
    });
  }

  @override
  Widget build (BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preferences'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "Ingredients To Avoid",
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 24,
                color: Colors.black,
                fontWeight: FontWeight.w400
              )
            ),
            Divider(
              thickness: 1,
              height: 10,
              color: Theme.of(context).colorScheme.outlineVariant
            ),
            Text(
              "The application will flag these ingredients if it is present in your food",
              style: TextStyle(
                fontSize: 15,
              ),
            ),
            Expanded(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _ingredients.length,
                // Divider between list items
                separatorBuilder: (context, index) => Divider(
                  height: 0,
                  color: Colors.transparent,
                ),
                itemBuilder: (context, index) {
                  final item = _ingredients[index];
                  
                  return CheckboxListTile(
                    value: item.isSelected,
                    onChanged: (newValue) => _checkboxToggle(newValue, item),
                    title: Text(
                      item.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    // Leading Circle Avatar
                    secondary: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                      child: Text(
                        item.name[0], // Uses first letter
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSecondaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Checkbox styling
                    activeColor: Theme.of(context).colorScheme.primary,
                    checkboxShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    controlAffinity: ListTileControlAffinity.trailing,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  );
                },
              ),
            ),
        ],
        ),
      ),
    );
  }
}