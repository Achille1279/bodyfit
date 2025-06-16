import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

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

  @override
  void initState() {
    super.initState();
    _initializeControllerFuture = _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final camera = cameras.first; // Tu peux personnaliser (ex: caméra arrière si besoin)
    _controller = CameraController(camera, ResolutionPreset.medium);
    await _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
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
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: FloatingActionButton(
                      onPressed: () async {
                        try {
                          final file = await _controller.takePicture();
                          widget.onPictureTaken(file);
                          // ⚠️ Plus besoin de Navigator.pop ici : la navigation est gérée dans onPictureTaken !
                        } catch (e) {
                          // Optionnel : affiche une erreur à l'utilisateur
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Erreur lors de la capture : $e')),
                          );
                        }
                      },
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
