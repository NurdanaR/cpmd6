import 'package:flutter_test/flutter_test.dart';
import 'package:data_persistence_networking_app/models/fitness_model.dart';
import 'package:data_persistence_networking_app/providers/fitness_provider.dart';
import 'package:data_persistence_networking_app/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('FitnessProvider calculates total calories', () {
    final provider = FitnessProvider(StorageService());
    final food = Food(
      id: 't1',
      name: 'Apple',
      calories: 50,
      protein: 0.5,
      fat: 0.3,
      carbs: 14,
    );
    provider.toggleFood(food);
    expect(provider.totalCalories, 50);
  });

  test('Food equality uses id', () {
    final a = Food(id: 'x', name: 'A', calories: 1, protein: 0, fat: 0, carbs: 0);
    final b = Food(id: 'x', name: 'B', calories: 2, protein: 0, fat: 0, carbs: 0);
    expect(a, equals(b));
  });

  test('Food.fromJson maps JSONPlaceholder post', () {
    final food = Food.fromJson({'id': 3});
    expect(food.name, isNotEmpty);
    expect(food.calories, greaterThan(0));
  });
}
