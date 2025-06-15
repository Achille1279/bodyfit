import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/result_screen.dart';


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
      routes: {
        '/result': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as List<String>;
          return ResultScreen(pictures: args);
        },
      },
    );
  }
}
