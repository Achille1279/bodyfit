import 'package:flutter/material.dart';
import 'photo_step_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BobyFit'),
      ),
      body: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.camera_alt),
          label: const Text("Commencer la prise de mesures"),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PhotoStepScreen(
                  stepIndex: 0,
                  pictures: [],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
