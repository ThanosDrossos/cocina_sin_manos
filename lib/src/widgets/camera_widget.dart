// widgets/camera_widget.dart

class CameraWidget extends StatelessWidget {
  final Function(Gesture) onGestureDetected;

  const CameraWidget({required this.onGestureDetected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      child: CameraPreviewWidget(onGestureDetected: onGestureDetected),
    );
  }
}
