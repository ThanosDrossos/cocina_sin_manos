
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
}

class RecipeStep {
  final String description;
  final String imagePath;

  RecipeStep({
    required this.description,
    required this.imagePath,
  });
}
