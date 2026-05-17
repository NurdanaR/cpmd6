import '../core/nutrition_math.dart';
import '../models/daily_nutrition_plan.dart';
import '../models/food_log_entry.dart';

/// Offline nutrition math (Mifflin-St Jeor + common food table per 100 g).
class NutritionCalculatorService {
  /// Per 100 g: calories, protein, fat, carbs.
  static const Map<String, List<double>> _per100g = {
    'chicken': [165, 31, 3.6, 0],
    'egg': [155, 13, 11, 1.1],
    'milk': [52, 3, 2.5, 4.8],
    'oat': [389, 17, 7, 66],
    'oats': [389, 17, 7, 66],
    'rice': [130, 2.7, 0.3, 28],
    'banana': [89, 1.1, 0.3, 23],
    'apple': [52, 0.3, 0.2, 14],
    'beef': [250, 26, 15, 0],
    'bread': [265, 9, 3.2, 49],
    'potato': [77, 2, 0.1, 17],
    'salmon': [208, 20, 13, 0],
    'yogurt': [59, 10, 0.4, 3.6],
    'cheese': [402, 25, 33, 1.3],
    'pasta': [131, 5, 1.1, 25],
    'buckwheat': [92, 3.4, 0.6, 20],
    'греч': [92, 3.4, 0.6, 20],
    'куриц': [165, 31, 3.6, 0],
  };

  /// Daily targets from height/weight (moderate activity, adult).
  DailyNutritionPlan calculateDailyPlan({
    required double heightCm,
    required double weightKg,
    int age = 25,
    bool isMale = true,
  }) {
    final bmr = 10 * weightKg + 6.25 * heightCm - 5 * age + (isMale ? 5 : -161);
    final calories = (bmr * 1.55).round();
    final proteinG = weightKg * 1.8;
    final fatG = calories * 0.25 / 9;
    final carbKcal = (calories - proteinG * 4 - fatG * 9).clamp(100, calories.toDouble());
    final carbsG = carbKcal / 4;

    return DailyNutritionPlan(
      dailyCalories: NutritionMath.caloriesFromMacros(proteinG, fatG, carbsG),
      proteinG: proteinG,
      fatG: fatG,
      carbsG: carbsG,
      note: 'Offline estimate (Mifflin-St Jeor, moderate activity). Tap ✨ for AI refine.',
    );
  }

  /// Estimates macros for a portion using keyword table or generic average.
  FoodLogEntry estimateFood({required String name, required double grams}) {
    final per100 = _matchPer100(name.toLowerCase());
    final factor = grams / 100;

    final protein = per100[1] * factor;
    final fat = per100[2] * factor;
    final carbs = per100[3] * factor;
    return FoodLogEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      grams: grams,
      calories: NutritionMath.caloriesFromMacros(protein, fat, carbs),
      protein: protein,
      fat: fat,
      carbs: carbs,
      loggedAt: DateTime.now(),
    );
  }

  /// Finds best matching food row or returns generic mixed-food values.
  List<double> _matchPer100(String name) {
    for (final entry in _per100g.entries) {
      if (name.contains(entry.key)) return entry.value;
    }
    return [120, 5, 4, 15];
  }
}
