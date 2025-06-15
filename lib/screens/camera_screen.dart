import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class CameraScreen extends StatefulWidget {
  final Function(XFile) onPictureTaken;
  final String expectedOrientation;

  const CameraScreen({
    required this.onPictureTaken,
    this.expectedOrientation = 'face',
  });

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  late PoseDetector _poseDetector;
  bool _isStreaming = false;
  String _feedback = '';

  @override
  void initState() {
    super.initState();

    _poseDetector = PoseDetector(
      options: PoseDetectorOptions(),
    );

    // ✅ On initialise le controller ici
    _initializeControllerFuture = _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final camera = cameras.first;

    _controller = CameraController(camera, ResolutionPreset.medium);
    await _controller.initialize();

    _controller.startImageStream(_processCameraImage);
    _isStreaming = true;
  }

  void _processCameraImage(CameraImage image) async {
    if (!_isStreaming) return;

    final WriteBuffer allBytes = WriteBuffer();
    for (final plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }

    final bytes = allBytes.done().buffer.asUint8List();

    final inputImage = InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: InputImageRotation.rotation0deg,
        format: InputImageFormatValue.fromRawValue(image.format.raw) ?? InputImageFormat.nv21,
        bytesPerRow: image.planes.first.bytesPerRow,
      ),
    );

    try {
      final poses = await _poseDetector.processImage(inputImage);

      if (poses.isNotEmpty) {
        final nose = poses.first.landmarks[PoseLandmarkType.nose];
        setState(() {
          _feedback = nose != null ? '✅ Visage détecté' : '❌ Tourne-toi vers la caméra';
        });
      } else {
        setState(() {
          _feedback = '❌ Aucune personne détectée';
        });
      }
    } catch (e) {
      print('Erreur de détection de pose: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _poseDetector.close();
    super.dispose();
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
                Positioned(
                  top: 50,
                  left: 0,
                  right: 0,
                  child: Text(
                    _feedback,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 18, backgroundColor: Colors.black54),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: FloatingActionButton(
                      onPressed: () async {
                        final file = await _controller.takePicture();
                        widget.onPictureTaken(file);
                        Navigator.pop(context);
                      },
                      child: Icon(Icons.camera_alt),
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






