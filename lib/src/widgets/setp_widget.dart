// widgets/step_widget.dart

class StepWidget extends StatelessWidget {
  final RecipeStep step;

  const StepWidget({required this.step});

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
