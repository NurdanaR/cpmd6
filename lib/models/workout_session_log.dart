/// Completed strength workout set logged by the user.
class WorkoutSessionLog {
  const WorkoutSessionLog({
    required this.id,
    required this.exerciseName,
    required this.weightKg,
    required this.reps,
    required this.sets,
    required this.caloriesBurned,
    required this.completedAt,
  });

  final String id;
  final String exerciseName;
  final double weightKg;
  final int reps;
  final int sets;
  final int caloriesBurned;
  final DateTime completedAt;

  /// Serializes session for Firestore / local storage.
  Map<String, dynamic> toJson() => {
        'id': id,
        'exerciseName': exerciseName,
        'weightKg': weightKg,
        'reps': reps,
        'sets': sets,
        'caloriesBurned': caloriesBurned,
        'completedAt': completedAt.toIso8601String(),
      };

  /// Restores session from stored JSON.
  factory WorkoutSessionLog.fromJson(Map<String, dynamic> json) => WorkoutSessionLog(
        id: json['id'] as String,
        exerciseName: json['exerciseName'] as String,
        weightKg: (json['weightKg'] as num).toDouble(),
        reps: (json['reps'] as num).toInt(),
        sets: (json['sets'] as num).toInt(),
        caloriesBurned: (json['caloriesBurned'] as num).toInt(),
        completedAt: DateTime.parse(json['completedAt'] as String),
      );
}
