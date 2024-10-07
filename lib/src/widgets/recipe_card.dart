// widgets/recipe_card.dart

import 'package:flutter/material.dart';

import '../models/recipe.dart';

class RecipeCard extends StatelessWidget {
  final Recipe recipe;

  const RecipeCard({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Image.asset(recipe.imagePath),
        title: Text(recipe.title),
        onTap: () {
          // Navigate to RecipeDetailView
        },
      ),
    );
  }
}
