import 'package:flutter/material.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  _LanguageSelectionScreenState createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  int selectedIndex = 0;

  final List<Map<String, String>> languages = [
    {'name': 'English', 'greeting': 'Hi'},
    {'name': 'Hindi', 'greeting': 'नमस्ते'},
    {'name': 'Bengali', 'greeting': 'হ্যালো'},
    {'name': 'Kannada', 'greeting': 'ನಮಸ್ಕಾರ'},
    {'name': 'Punjabi', 'greeting': 'ਸਤ ਸ੍ਰੀ ਅਕਾਲ'},
    {'name': 'Tamil', 'greeting': 'வணக்கம்'},
    {'name': 'Telugu', 'greeting': 'హలో'},
    {'name': 'French', 'greeting': 'Bonjour'},
    {'name': 'Spanish', 'greeting': 'Hola'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Choose Your Language",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              margin: EdgeInsets.all(20),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: ListView.builder(
                itemCount: languages.length,
                itemBuilder: (context, index) {
                  return RadioListTile<int>(
                    value: index,
                    groupValue: selectedIndex,
                    onChanged: (val) {
                      setState(() => selectedIndex = val!);
                    },
                    title: Text(languages[index]['name']!),
                    subtitle: Text(languages[index]['greeting']!),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  // Navigate to Signup screen
                  Navigator.pushNamed(context, '/signup');
                },
                child: Text(
                  "Select",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
