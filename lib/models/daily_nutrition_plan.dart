/// AI-generated daily calorie and macro targets from height/weight.
class DailyNutritionPlan {
  const DailyNutritionPlan({
    required this.dailyCalories,
    required this.proteinG,
    required this.fatG,
    required this.carbsG,
    this.note,
  });

  final int dailyCalories;
  final double proteinG;
  final double fatG;
  final double carbsG;
  final String? note;

  /// Serializes plan for local persistence.
  Map<String, dynamic> toJson() => {
        'dailyCalories': dailyCalories,
        'proteinG': proteinG,
        'fatG': fatG,
        'carbsG': carbsG,
        'note': note,
      };

  /// Restores plan from JSON map.
  factory DailyNutritionPlan.fromJson(Map<String, dynamic> json) => DailyNutritionPlan(
        dailyCalories: (json['dailyCalories'] as num).toInt(),
        proteinG: (json['proteinG'] as num).toDouble(),
        fatG: (json['fatG'] as num).toDouble(),
        carbsG: (json['carbsG'] as num).toDouble(),
        note: json['note'] as String?,
      );
}
