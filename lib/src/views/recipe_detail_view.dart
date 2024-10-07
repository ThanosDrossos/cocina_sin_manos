// views/recipe_detail_view.dart

import 'package:flutter/material.dart';

import '../../platform_channel.dart';
import '../models/recipe.dart';
import '../widgets/camera_widget.dart';
import '../widgets/step_widget.dart';


class RecipeDetailView extends StatefulWidget {
  final Recipe recipe;

  const RecipeDetailView({super.key, required this.recipe});

  @override
  _RecipeDetailViewState createState() => _RecipeDetailViewState();
}

class _RecipeDetailViewState extends State<RecipeDetailView> {
  int currentStep = 0;

  @override
  Widget build(BuildContext context) {
    final step = widget.recipe.steps[currentStep];

    return Scaffold(
      appBar: AppBar(title: Text(widget.recipe.title)),
      body: Stack(
        children: [
          StepWidget(step: step),
          Positioned(
            top: 16,
            right: 16,
            child: CameraWidget(onGestureDetected: _handleGesture),
          ),
        ],
      ),
    );
  }

    @override
  void initState() {
    super.initState();
    GestureRecognitionChannel.init();
    GestureRecognitionChannel.onGestureDetected.listen((gestureName) {
      _handleGesture(gestureName);
    });
    // Start gesture recognition
    GestureRecognitionChannel.startGestureRecognition();
  }

  void _handleGesture(String gestureName) {
    setState(() {
      if (gestureName == 'Open_Palm' && currentStep < widget.recipe.steps.length - 1) {
        currentStep++;
      } else if (gestureName == 'Closed_Fist' && currentStep > 0) {
        currentStep--;
      }
    });
  }

  @override
  void dispose() {
    // Stop gesture recognition when the widget is disposed
    GestureRecognitionChannel.stopGestureRecognition();
    super.dispose();
  }
}
