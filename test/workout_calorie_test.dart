import 'package:flutter_test/flutter_test.dart';
import 'package:data_persistence_networking_app/services/workout_calorie_service.dart';

void main() {
  test('WorkoutCalorieService returns positive kcal for valid input', () {
    final service = WorkoutCalorieService();
    final kcal = service.estimateBurned(
      weightKg: 80,
      reps: 10,
      sets: 4,
      userWeightKg: 75,
    );
    expect(kcal, greaterThan(0));
  });
}
