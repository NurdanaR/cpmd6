import 'package:flutter/foundation.dart';
import '../models/workout_session_log.dart';
import '../repositories/user_data_repository.dart';

/// Tracks and persists calories burned from completed workouts.
class FitnessProvider extends ChangeNotifier {
  FitnessProvider(this._userData);

  final UserDataRepository _userData;
  int _burnedCalories = 0;

  int get burnedCalories => _burnedCalories;

  /// Loads burned total from Firestore / local storage.
  Future<void> load() async {
    _burnedCalories = await _userData.loadBurnedCalories();
    notifyListeners();
  }

  /// Completes a workout: adds burned kcal and saves session log.
  Future<int> completeWorkout({
    required String exerciseName,
    required double weightKg,
    required int reps,
    required int sets,
    required int caloriesBurned,
  }) async {
    _burnedCalories += caloriesBurned;
    await _userData.saveBurnedCalories(_burnedCalories);

    final session = WorkoutSessionLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      exerciseName: exerciseName,
      weightKg: weightKg,
      reps: reps,
      sets: sets,
      caloriesBurned: caloriesBurned,
      completedAt: DateTime.now(),
    );
    await _userData.addWorkoutSession(session);
    notifyListeners();
    return caloriesBurned;
  }

  /// Resets burned calories counter.
  Future<void> resetBurned() async {
    _burnedCalories = 0;
    await _userData.saveBurnedCalories(0);
    notifyListeners();
  }
}
