import 'dart:io';
import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  final List<String> pictures;

  const ResultScreen({Key? key, required this.pictures}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Résultats')),
      body: ListView.builder(
        itemCount: pictures.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.file(File(pictures[index])),
          );
        },
      ),
    );
  }
}
