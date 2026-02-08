import 'package:flutter/material.dart';

void main() {
  runApp(const TestApp());
}

class TestApp extends StatelessWidget {
  const TestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Test App Running', style: TextStyle(fontSize: 24)),
              SizedBox(height: 20),
              Text('If you see this, Flutter is working!'),
            ],
          ),
        ),
      ),
    );
  }
}
