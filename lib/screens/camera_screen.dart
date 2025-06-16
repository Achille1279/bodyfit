import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class CameraScreen extends StatefulWidget {
  final Function(XFile) onPictureTaken;
  final String expectedOrientation;

  const CameraScreen({
    Key? key,
    required this.onPictureTaken,
    this.expectedOrientation = 'face',
  }) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  late PoseDetector _poseDetector;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initializeControllerFuture = _initializeCamera();
    _poseDetector = PoseDetector(options: PoseDetectorOptions());
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final camera = cameras.first;
    _controller = CameraController(camera, ResolutionPreset.medium);
    await _controller.initialize();
  }

  @override
  void dispose() {
    _poseDetector.close();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _validateAndCapture() async {
    if (_isProcessing) return;
    _isProcessing = true;

    try {
      final file = await _controller.takePicture();
      final inputImage = InputImage.fromFilePath(file.path);
      final poses = await _poseDetector.processImage(inputImage);

      if (poses.isNotEmpty && _isPoseUpright(poses.first)) {
        _showTempMessage("✅ Photo valide");
        await Future.delayed(const Duration(seconds: 2));
        Navigator.of(context).pop();
        widget.onPictureTaken(file);
      } else {
        _showPostureAlert();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : $e")),
      );
    }

    _isProcessing = false;
  }

  bool _isPoseUpright(Pose pose) {
    final landmarks = pose.landmarks;

    if (!(landmarks.containsKey(PoseLandmarkType.nose) &&
        landmarks.containsKey(PoseLandmarkType.leftShoulder) &&
        landmarks.containsKey(PoseLandmarkType.rightShoulder) &&
        landmarks.containsKey(PoseLandmarkType.leftHip) &&
        landmarks.containsKey(PoseLandmarkType.rightHip))) {
      return false;
    }

    final leftShoulder = landmarks[PoseLandmarkType.leftShoulder]!.x;
    final rightShoulder = landmarks[PoseLandmarkType.rightShoulder]!.x;
    final leftHip = landmarks[PoseLandmarkType.leftHip]!.x;
    final rightHip = landmarks[PoseLandmarkType.rightHip]!.x;

    // Vérifier alignement vertical des épaules et hanches
    final shoulderCenterX = (leftShoulder + rightShoulder) / 2;
    final hipCenterX = (leftHip + rightHip) / 2;

    final horizontalDiff = (shoulderCenterX - hipCenterX).abs();

    // TOLERANCE: La personne est droite si l'écart horizontal est faible
    return horizontalDiff < 30;  // ajuste selon ton besoin, ex 30 pixels
  }

  void _showPostureAlert() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("❌ Posture invalide"),
        content: const Text("Merci de bien vous positionner : debout, droit face à la caméra."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showTempMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                CameraPreview(_controller),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: FloatingActionButton(
                      onPressed: _validateAndCapture,
                      child: const Icon(Icons.camera_alt),
                    ),
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
