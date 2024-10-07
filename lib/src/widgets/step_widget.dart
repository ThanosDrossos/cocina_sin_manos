// src/widgets/step_widget.dart

import 'package:flutter/material.dart';
import '../models/recipe.dart';

class StepWidget extends StatelessWidget {
  final RecipeStep step;

  const StepWidget({super.key, required this.step});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          if (step.imagePath.isNotEmpty)
            Image.asset(
              step.imagePath,
              fit: BoxFit.cover,
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              step.description,
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}
