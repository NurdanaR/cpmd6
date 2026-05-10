class Exercise {
  final String title;
  final String imageUrl;
  final String instructions;

  Exercise({required this.title, required this.imageUrl, required this.instructions});
}

class BlockExercise {
  final String name;
  final String imageUrl;
  final String? subtitle;

  BlockExercise({
    required this.name,
    required this.imageUrl,
    this.subtitle,
  });
}

class WorkoutPlan {
  final String title;
  final String tag;
  final String imgUrl;
  final List<BlockExercise> exercises;

  WorkoutPlan({
    required this.title,
    required this.tag,
    required this.imgUrl,
    required this.exercises,
  });
}

class Food {
  final String name;
  final int calories;
  final double protein;
  final double fat;
  final double carbs;

  Food({
    required this.name,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
  });

  factory Food.fromJson(Map<String, dynamic> json) {
    int id = json['id'] ?? 1;

    final List<String> realProducts = [
      "Chicken Breast",
      "Boiled Egg",
      "Cottage Cheese 5%",
      "Oatmeal",
      "Banana",
      "Beef Steaks",
      "White Rice",
      "Apple",
      "Almonds",
      "Greek Yogurt",
      "Salmon Fillet",
      "Avocado",
      "Broccoli",
      "Peanut Butter",
      "Whole Grain Bread",
      "Sweet Potato",
      "Tuna Canned",
      "Blueberries"
    ];

    return Food(
      name: realProducts[id % realProducts.length],
      calories: (id % 5 + 1) * 65 + 45,
      protein: (id % 12).toDouble() + 4.5,
      fat: (id % 7).toDouble() + 1.2,
      carbs: (id % 20).toDouble() + 8.0,
    );
  }
}