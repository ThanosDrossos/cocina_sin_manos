// widgets/camera_widget.dart

import 'package:flutter/material.dart';

import 'camera_preview_widget.dart'; // Import the CameraPreviewWidget class

class CameraWidget extends StatelessWidget {
  final void Function(String) onGestureDetected;

  const CameraWidget({super.key, required this.onGestureDetected});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 100,
      child: CameraPreviewWidget(onGestureDetected: onGestureDetected),
    );
  }
}
