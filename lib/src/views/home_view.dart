// src/views/home_view.dart

import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../services/recipe_service.dart';
import '../settings/settings_view.dart';
import 'recipe_list_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final recipeService = RecipeService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, SettingsView.routeName);
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Recipe>>(
        future: recipeService.loadRecipes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // While the future is loading, display a progress indicator
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // If the future completed with an error, display the error
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            // If the future completed successfully, display the recipes
            final recipes = snapshot.data!;
            return RecipeListView(recipes: recipes);
          } else {
            // If snapshot has no data, display a message
            return const Center(child: Text('No recipes found.'));
          }
        },
      ),
    );
  }
}
