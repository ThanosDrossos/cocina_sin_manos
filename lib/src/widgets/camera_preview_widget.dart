import 'package:flutter/material.dart';
    
class CameraPreviewWidget extends StatelessWidget {
  final void Function(String) onGestureDetected;

  const CameraPreviewWidget({super.key, required this.onGestureDetected});

  @override
  Widget build(BuildContext context) {
    // Implement your camera preview and gesture detection logic here
    // For demonstration, let's assume we detect a gesture and call the callback
    // Replace this with actual gesture detection logic
    return GestureDetector(
      onPanUpdate: (details) {
        // Dummy gesture detection logic
        if (details.delta.dx > 0) {
          onGestureDetected('Open_Palm');
        } else {
          onGestureDetected('Closed_Fist');
        }
      },
      child: Container(
        color: Colors.black,
      ),
    );
  }
}