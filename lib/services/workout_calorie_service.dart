/// Estimates calories burned during a strength training set.
class WorkoutCalorieService {
  /// Estimates kcal from volume (weight × reps × sets) and user body weight.
  int estimateBurned({
    required double weightKg,
    required int reps,
    required int sets,
    required double userWeightKg,
  }) {
    if (weightKg <= 0 || reps <= 0 || sets <= 0) return 0;

    final totalVolume = weightKg * reps * sets;
    final volumeKcal = totalVolume * 0.05;
    final effortPerSet = sets * 6.0;
    final bodyCost = userWeightKg * 0.08 * sets;

    return (volumeKcal + effortPerSet + bodyCost).round().clamp(5, 800);
  }
}
