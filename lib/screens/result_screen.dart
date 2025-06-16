import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class ResultScreen extends StatelessWidget {
  final List<XFile> pictures;

  const ResultScreen({Key? key, required this.pictures}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prise de mesure terminée')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "🎉 Prise de mesure terminée !",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: pictures.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Image.file(File(pictures[index].path)),
                  );
                },
              ),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.straighten),
              label: const Text("Voir mes mesures"),
              onPressed: () {
                _showMeasurements(context);
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.home),
              label: const Text("Retour à l'accueil"),
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showMeasurements(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Mesures calculées"),
        content: const Text("Les mensurations s’afficheront ici…"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Fermer"),
          ),
        ],
      ),
    );
  }
}
