import 'package:data_persistence_networking_app/core/nutrition_math.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('caloriesFromMacros uses 4-9-4 rule', () {
    expect(NutritionMath.caloriesFromMacros(80, 60, 0), 860);
    expect(NutritionMath.caloriesFromMacros(16, 3.6, 84), 432);
  });

  test('portionFromPer100 scales and matches calories', () {
    final portion = NutritionMath.portionFromPer100(
      proteinPer100G: 31,
      fatPer100G: 3.6,
      carbsPer100G: 0,
      grams: 400,
    );
    expect(portion.protein, 124);
    expect(portion.calories, 860);
    expect(
      portion.calories,
      NutritionMath.caloriesFromMacros(portion.protein, portion.fat, portion.carbs),
    );
  });
}
