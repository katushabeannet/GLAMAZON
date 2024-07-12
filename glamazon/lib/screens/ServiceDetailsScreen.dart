import 'package:flutter/material.dart';

class ServiceDetailsScreen extends StatelessWidget {
  final String imagePath;
  final String label;

  const ServiceDetailsScreen({required this.imagePath, required this.label, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: Text(label),
      ),
      // body: Center(
      //   child: Column(
      //     mainAxisAlignment: MainAxisAlignment.center,
      //     children: [
      //       ClipRRect(
      //         borderRadius: BorderRadius.circular(10),
      //         child: Image.asset(
      //           imagePath,
      //           fit: BoxFit.cover,
      //           width: 300,
      //           height: 300,
      //         ),
      //       ),
      //       const SizedBox(height: 16.0),
      //       Text(
      //         label,
      //         style: const TextStyle(
      //           fontSize: 24,
      //           fontWeight: FontWeight.bold,
      //         ),
      //       ),
      //       const SizedBox(height: 16.0),
      //       const Text(
      //         'Detailed information about the service can be added here.',
      //         textAlign: TextAlign.center,
      //         style: TextStyle(
      //           fontSize: 16,
      //         ),
      //       ),
      //     ],
      //   ),
      // ),
    );
  }
}