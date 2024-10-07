// src/models/recipe.dart

class Recipe {
  final String title;
  final List<String> ingredients;
  final List<RecipeStep> steps;
  final String imagePath;

  Recipe({
    required this.title,
    required this.ingredients,
    required this.steps,
    required this.imagePath,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      title: json['title'],
      ingredients: List<String>.from(json['ingredients']),
      steps: (json['steps'] as List<dynamic>)
          .map((stepJson) => RecipeStep.fromJson(stepJson))
          .toList(),
      imagePath: json['imagePath'],
    );
  }
}

class RecipeStep {
  final String description;
  final String imagePath;

  RecipeStep({
    required this.description,
    required this.imagePath,
  });

  factory RecipeStep.fromJson(Map<String, dynamic> json) {
    return RecipeStep(
      description: json['description'],
      imagePath: json['imagePath'],
    );
  }
}
