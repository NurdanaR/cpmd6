import 'package:flutter_test/flutter_test.dart';
import 'package:data_persistence_networking_app/models/food_log_entry.dart';
void main() {
  test('FoodLogEntry serializes to JSON', () {
    final entry = FoodLogEntry(
      id: '1',
      name: 'Apple',
      grams: 100,
      calories: 52,
      protein: 0.3,
      fat: 0.2,
      carbs: 14,
      loggedAt: DateTime(2026, 1, 1),
    );
    final restored = FoodLogEntry.fromJson(entry.toJson());
    expect(restored.name, 'Apple');
    expect(restored.calories, 52);
  });
}
