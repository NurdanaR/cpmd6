/// Single food item logged by the user with AI-estimated macros.
class FoodLogEntry {
  const FoodLogEntry({
    required this.id,
    required this.name,
    required this.grams,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
    required this.loggedAt,
  });

  final String id;
  final String name;
  final double grams;
  final int calories;
  final double protein;
  final double fat;
  final double carbs;
  final DateTime loggedAt;

  /// Serializes entry for local persistence.
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'grams': grams,
        'calories': calories,
        'protein': protein,
        'fat': fat,
        'carbs': carbs,
        'loggedAt': loggedAt.toIso8601String(),
      };

  /// Restores entry from JSON map.
  factory FoodLogEntry.fromJson(Map<String, dynamic> json) => FoodLogEntry(
        id: json['id'] as String,
        name: json['name'] as String,
        grams: (json['grams'] as num).toDouble(),
        calories: (json['calories'] as num).toInt(),
        protein: (json['protein'] as num).toDouble(),
        fat: (json['fat'] as num).toDouble(),
        carbs: (json['carbs'] as num).toDouble(),
        loggedAt: DateTime.parse(json['loggedAt'] as String),
      );
}
