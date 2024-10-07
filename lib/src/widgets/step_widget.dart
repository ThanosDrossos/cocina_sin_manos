// widgets/step_widget.dart

import 'package:flutter/material.dart';

import '../models/recipe.dart';

class StepWidget extends StatelessWidget {
  final RecipeStep step;

  const StepWidget({super.key, required this.step});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(step.imagePath),
        Text(step.description),
      ],
    );
  }
}
