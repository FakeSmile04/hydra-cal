import 'package:flutter/material.dart';

class FoodScannerInformationPage extends StatelessWidget {
  const FoodScannerInformationPage({super.key});
  
  //Dummy scanner results
  static final List<String> flaggedIngredients = [
    "Artificial Flavors",
    "High Fructose Corn Syrup",
    "Sodium Nitrite",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Information'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'BarcodeValue - FoodName',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w400
              ),
            ),
            Divider(
              thickness: 1,
              height: 10,
              color: Theme.of(context).colorScheme.outlineVariant
            ),
            const Text(
              'The application has found these flagged ingredients to be present in your food',
              style: TextStyle(
                fontSize: 15,
              ),
            ),
            //item list
            Expanded(
              child: ListView.builder(
                itemCount: flaggedIngredients.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: Colors.black,
                      child: Icon(
                        Icons.priority_high, 
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      flaggedIngredients[index],
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
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