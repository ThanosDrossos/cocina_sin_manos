// src/views/recipe_detail_view.dart

import 'package:flutter/material.dart';
import '../../platform_channel.dart';
import '../models/recipe.dart';
import '../widgets/step_widget.dart';
import '../widgets/camera_widget.dart';
import '../controllers/gesture_controller.dart'; // If needed for gesture handling

class RecipeDetailView extends StatefulWidget {
  final Recipe recipe;

  const RecipeDetailView({super.key, required this.recipe});

  @override
  _RecipeDetailViewState createState() => _RecipeDetailViewState();
}

class _RecipeDetailViewState extends State<RecipeDetailView> {
  int currentStep = 0;

  @override
  void initState() {
    super.initState();
    // Initialize gesture recognition if not already initialized
    GestureRecognitionChannel.init();
    GestureRecognitionChannel.onGestureDetected.listen((gestureName) {
      _handleGesture(gestureName);
    });
    // Start gesture recognition
    GestureRecognitionChannel.startGestureRecognition();
  }

  @override
  void dispose() {
    // Stop gesture recognition when the widget is disposed
    GestureRecognitionChannel.stopGestureRecognition();
    super.dispose();
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
          // Optional: Add on-screen navigation buttons
          Positioned(
            bottom: 16,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: currentStep > 0
                  ? () {
                      setState(() {
                        currentStep--;
                      });
                    }
                  : null,
            ),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: IconButton(
              icon: const Icon(Icons.arrow_forward),
              onPressed: currentStep < widget.recipe.steps.length - 1
                  ? () {
                      setState(() {
                        currentStep++;
                      });
                    }
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
