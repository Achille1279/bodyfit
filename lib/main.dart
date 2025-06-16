import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const BodyFitApp());
}

class BodyFitApp extends StatelessWidget {
  const BodyFitApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BodyFit',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: const HomeScreen(),
    );
  }
}
