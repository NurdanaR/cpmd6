import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/daily_nutrition_plan.dart';
import '../models/food_log_entry.dart';
import '../models/workout_session_log.dart';

/// Cloud persistence for profile, food log, and daily plan under `users/{uid}`.
class FirestoreUserDataService {
  FirestoreUserDataService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> _userDoc(String userId) {
    return _db.collection('users').doc(userId);
  }

  /// Saves profile fields merged into the user document.
  Future<void> saveProfile(
    String userId, {
    required String name,
    required String height,
    required String weight,
  }) async {
    await _userDoc(userId).set(
      {
        'profile': {
          'name': name,
          'height': height,
          'weight': weight,
        },
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  /// Loads profile map or null if missing.
  Future<Map<String, String>?> loadProfile(String userId) async {
    final snap = await _userDoc(userId).get();
    final profile = snap.data()?['profile'] as Map<String, dynamic>?;
    if (profile == null) return null;
    return {
      'name': profile['name'] as String? ?? '',
      'height': profile['height'] as String? ?? '',
      'weight': profile['weight'] as String? ?? '',
    };
  }

  /// Persists the full food log array on the user document.
  Future<void> saveFoodLog(String userId, List<FoodLogEntry> entries) async {
    await _userDoc(userId).set(
      {
        'foodLog': entries.map((e) => e.toJson()).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  /// Loads food log from Firestore.
  Future<List<FoodLogEntry>> loadFoodLog(String userId) async {
    final snap = await _userDoc(userId).get();
    final raw = snap.data()?['foodLog'] as List<dynamic>?;
    if (raw == null) return [];
    return raw
        .map((e) => FoodLogEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Saves daily nutrition plan on the user document.
  Future<void> saveDailyPlan(String userId, DailyNutritionPlan plan) async {
    await _userDoc(userId).set(
      {
        'dailyPlan': plan.toJson(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  /// Loads daily plan from Firestore.
  Future<DailyNutritionPlan?> loadDailyPlan(String userId) async {
    final snap = await _userDoc(userId).get();
    final raw = snap.data()?['dailyPlan'] as Map<String, dynamic>?;
    if (raw == null) return null;
    return DailyNutritionPlan.fromJson(raw);
  }

  /// Saves total burned calories on user document.
  Future<void> saveBurnedCalories(String userId, int kcal) async {
    await _userDoc(userId).set(
      {'burnedCalories': kcal, 'updatedAt': FieldValue.serverTimestamp()},
      SetOptions(merge: true),
    );
  }

  /// Loads burned calories from Firestore.
  Future<int> loadBurnedCalories(String userId) async {
    final snap = await _userDoc(userId).get();
    return (snap.data()?['burnedCalories'] as num?)?.toInt() ?? 0;
  }

  /// Appends a workout session to history array.
  Future<void> addWorkoutSession(String userId, WorkoutSessionLog session) async {
    await _userDoc(userId).set(
      {
        'workoutHistory': FieldValue.arrayUnion([session.toJson()]),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  /// Loads workout history from Firestore.
  Future<List<WorkoutSessionLog>> loadWorkoutHistory(String userId) async {
    final snap = await _userDoc(userId).get();
    final raw = snap.data()?['workoutHistory'] as List<dynamic>?;
    if (raw == null) return [];
    return raw
        .map((e) => WorkoutSessionLog.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));
  }
}
