// src/widgets/recipe_card.dart

import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../views/recipe_detail_view.dart';

class RecipeCard extends StatelessWidget {
  final Recipe recipe;

  const RecipeCard({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Image.asset(
          recipe.imagePath,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
        ),
        title: Text(recipe.title),
        onTap: () {
          // Navigate to the RecipeDetailView
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecipeDetailView(recipe: recipe),
            ),
          );
        },
      ),
    );
  }
}
