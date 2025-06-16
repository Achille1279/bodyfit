import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'camera_screen.dart';
import 'result_screen.dart';

class PhotoStepScreen extends StatefulWidget {
  final int stepIndex;
  final List<XFile> pictures;

  const PhotoStepScreen({
    Key? key,
    required this.stepIndex,
    required this.pictures,
  }) : super(key: key);

  @override
  State<PhotoStepScreen> createState() => _PhotoStepScreenState();
}

class _PhotoStepScreenState extends State<PhotoStepScreen> {
  final List<String> steps = ['face', 'profil_droit', 'profil_gauche', 'dos'];

  void _launchCamera() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CameraScreen(
          expectedOrientation: steps[widget.stepIndex],
          onPictureTaken: (file) {
            final updated = [...widget.pictures, file];
            if (widget.stepIndex < steps.length - 1) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => PhotoStepScreen(
                    stepIndex: widget.stepIndex + 1,
                    pictures: updated,
                  ),
                ),
              );
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ResultScreen(pictures: updated),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentStep = steps[widget.stepIndex];
    return Scaffold(
      appBar: AppBar(title: Text("Étape ${widget.stepIndex + 1}: $currentStep")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.camera_alt),
              label: const Text("Prendre la photo"),
              onPressed: _launchCamera,
            ),
            const SizedBox(height: 20),
            const Text("Prenez une photo pour cette étape pour continuer."),
          ],
        ),
      ),
    );
  }
}
