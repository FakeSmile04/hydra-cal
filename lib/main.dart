import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Word Analyzer',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MyHomePage(title: "Word Analyzer"),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _word = '';
  int _characterCount = 0;
  int _vowelCount = 0;
  int _consonantCount = 0;

  void _setWord(String word) {
    setState(() {
      _word = word;
    });
  }

  void _analyzeWord() {
    setState(() {
      _characterCount = _word.length;
      
      _vowelCount = 0;
      _consonantCount = 0;
      
      for (String char in _word.split('')) {
        String lowerChar = char.toLowerCase();
        if (RegExp(r'[aeiou]').hasMatch(lowerChar)) {
          _vowelCount++;
        } else if (RegExp(r'[a-z]').hasMatch(lowerChar)) {
          _consonantCount++;
        }
      }
    });

    _showDialog('Word: $_word\nNumber of consonants: $_consonantCount\nNumber of vowels: $_vowelCount\nNumber of characters: $_characterCount\nPalindrome: ${_word == _word.split('').reversed.join('') ? "Yes" : "No"} ');
  }

  void _showDialog(String status) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Word Analysis", textAlign: TextAlign.center),
          content: Text(status),
          actions: <Widget>[
            ElevatedButton(
              child: const Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
                margin: const EdgeInsets.all(20),
                child: TextField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Enter your Word',
                  ),
                  onChanged: (text) {
                    _setWord(text);
                  },
                )),
            Container(
                margin: const EdgeInsets.all(20),
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _analyzeWord,
                  child: const Text('Analyze'),
                ))
          ],
        ),
      ),
    );
  }
}