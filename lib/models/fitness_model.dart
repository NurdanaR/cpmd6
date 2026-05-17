/// Single exercise with instructions and image.
class Exercise {
  final String title;
  final String imageUrl;
  final String instructions;

  Exercise({required this.title, required this.imageUrl, required this.instructions});
}

/// Exercise inside a workout block carousel.
class BlockExercise {
  final String name;
  final String imageUrl;
  final String? subtitle;

  BlockExercise({required this.name, required this.imageUrl, this.subtitle});
}

/// Predefined workout plan shown in horizontal carousel.
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

/// Nutrition item from Firestore, REST API, or local cache.
class Food {
  final String id;
  final String name;
  final int calories;
  final double protein;
  final double fat;
  final double carbs;

  Food({
    required this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
  });

  /// Creates a [Food] from JSONPlaceholder post JSON (REST fallback).
  factory Food.fromJson(Map<String, dynamic> json) {
    final int postId = json['id'] ?? 1;
    const products = [
      'Chicken Breast',
      'Boiled Egg',
      'Cottage Cheese 5%',
      'Oatmeal',
      'Banana',
      'Beef Steaks',
      'White Rice',
      'Apple',
      'Almonds',
      'Greek Yogurt',
      'Salmon Fillet',
      'Avocado',
      'Broccoli',
      'Peanut Butter',
      'Whole Grain Bread',
      'Sweet Potato',
      'Tuna Canned',
      'Blueberries',
    ];
    return Food(
      id: 'api_$postId',
      name: products[postId % products.length],
      calories: (postId % 5 + 1) * 65 + 45,
      protein: (postId % 12).toDouble() + 4.5,
      fat: (postId % 7).toDouble() + 1.2,
      carbs: (postId % 20).toDouble() + 8.0,
    );
  }

  /// Creates a [Food] from Firestore document data.
  factory Food.fromFirestore(String docId, Map<String, dynamic> data) {
    return Food(
      id: 'fs_$docId',
      name: data['name'] as String? ?? 'Unknown',
      calories: (data['calories'] as num?)?.toInt() ?? 0,
      protein: (data['protein'] as num?)?.toDouble() ?? 0,
      fat: (data['fat'] as num?)?.toDouble() ?? 0,
      carbs: (data['carbs'] as num?)?.toDouble() ?? 0,
    );
  }

  /// Serializes food for offline cache storage.
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'calories': calories,
        'protein': protein,
        'fat': fat,
        'carbs': carbs,
      };

  /// Restores food from cached JSON.
  factory Food.fromCacheJson(Map<String, dynamic> json) => Food(
        id: json['id'] as String,
        name: json['name'] as String,
        calories: json['calories'] as int,
        protein: (json['protein'] as num).toDouble(),
        fat: (json['fat'] as num).toDouble(),
        carbs: (json['carbs'] as num).toDouble(),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Food && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
