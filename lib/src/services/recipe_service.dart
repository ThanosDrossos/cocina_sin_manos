// services/recipe_service.dart

import 'dart:convert';
import 'package:cocina_sin_manos/src/models/recipe.dart';
import 'package:flutter/services.dart' show rootBundle;

class RecipeService {
  Future<List<Recipe>> loadRecipes() async {
    final data = await rootBundle.loadString('assets/recipes/sample_recipe.json');
    final jsonResult = json.decode(data);
    // Parse the JSON into Recipe objects
    final recipes = <Recipe>[];
    for (final recipe in jsonResult) {
      final title = recipe['title'];
      final imagePath = recipe['imagePath'];
      final ingredients = List<String>.from(recipe['ingredients']);
      final steps = <RecipeStep>[];
      for (final step in recipe['steps']) {
        steps.add(RecipeStep(
          description: step['description'],
          imagePath: step['imagePath'],
        ));
      }
      recipes.add(Recipe(
        title: title,
        ingredients: ingredients,
        steps: steps,
        imagePath: imagePath,
      ));
    }
  }
}
