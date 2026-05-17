/// Consistent calorie and macro math (Atwater factors).
class NutritionMath {
  NutritionMath._();

  /// kcal from macros: 4 kcal/g protein, 9 kcal/g fat, 4 kcal/g carbs.
  static int caloriesFromMacros(double protein, double fat, double carbs) {
    return (protein * 4 + fat * 9 + carbs * 4).round();
  }

  /// Scales per-100g macros to a portion; calories always match macros.
  static PortionMacros portionFromPer100({
    required double proteinPer100G,
    required double fatPer100G,
    required double carbsPer100G,
    required double grams,
  }) {
    final factor = grams / 100;
    final protein = proteinPer100G * factor;
    final fat = fatPer100G * factor;
    final carbs = carbsPer100G * factor;
    return PortionMacros(
      protein: protein,
      fat: fat,
      carbs: carbs,
      calories: caloriesFromMacros(protein, fat, carbs),
    );
  }
}

/// Macros for one portion with calories derived from Atwater factors.
class PortionMacros {
  const PortionMacros({
    required this.protein,
    required this.fat,
    required this.carbs,
    required this.calories,
  });

  final double protein;
  final double fat;
  final double carbs;
  final int calories;
}
