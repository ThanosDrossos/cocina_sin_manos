// src/services/recipe_service.dart

import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/recipe.dart';

class RecipeService {
  Future<List<Recipe>> loadRecipes() async {
    final data = await rootBundle.loadString('assets/recipes.json');
    final List<dynamic> jsonResult = json.decode(data);

    return jsonResult.map((recipeJson) => Recipe.fromJson(recipeJson)).toList();
  }
}
