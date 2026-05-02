import 'package:flutter_test/flutter_test.dart';
import 'package:data_persistence_networking_app/models/fitness_model.dart';
import 'package:data_persistence_networking_app/providers/fitness_provider.dart';

void main() {
  test('Проверка расчета калорий в FitnessProvider', () {
    final provider = FitnessProvider();
    final food = Food(
        name: 'Apple',
        calories: 50,
        protein: 0.5,
        fat: 0.3,
        carbs: 14.0
    );

    provider.toggleFood(food);
    expect(provider.totalCalories, 50);
  });
}