import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';
import '../models/daily_nutrition_plan.dart';
import '../models/food_log_entry.dart';
import '../models/workout_session_log.dart';

/// Local key-value storage for profile and app preferences.
class StorageService {
  static const String _nameKey = 'user_name';

  /// Persists display name.
  Future<void> saveName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, name);
  }

  /// Loads display name or default.
  Future<String> getName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_nameKey) ?? 'GYM';
  }

  /// Saves height and weight strings.
  Future<void> saveMetrics(String height, String weight) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_height', height);
    await prefs.setString('user_weight', weight);
  }

  /// Returns height and weight map.
  Future<Map<String, String>> getMetrics() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'height': prefs.getString('user_height') ?? '',
      'weight': prefs.getString('user_weight') ?? '',
    };
  }

  /// Saves today's food log entries as JSON.
  Future<void> saveFoodLog(List<FoodLogEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(entries.map((e) => e.toJson()).toList());
    await prefs.setString(AppConstants.foodLogKey, encoded);
  }

  /// Loads persisted food log entries.
  Future<List<FoodLogEntry>> loadFoodLog() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(AppConstants.foodLogKey);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => FoodLogEntry.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Saves AI daily nutrition plan.
  Future<void> saveDailyPlan(DailyNutritionPlan plan) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.dailyPlanKey, jsonEncode(plan.toJson()));
  }

  /// Loads saved daily plan or null.
  Future<DailyNutritionPlan?> loadDailyPlan() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(AppConstants.dailyPlanKey);
    if (raw == null) return null;
    return DailyNutritionPlan.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  /// Saves dark mode preference.
  Future<void> saveDarkMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.themeModeKey, isDark);
  }

  /// Reads dark mode preference (defaults to false).
  Future<bool> loadDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConstants.themeModeKey) ?? false;
  }

  /// Saves total burned calories for the current session/day.
  Future<void> saveBurnedCalories(int kcal) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(AppConstants.burnedCaloriesKey, kcal);
  }

  /// Loads burned calories total.
  Future<int> loadBurnedCalories() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(AppConstants.burnedCaloriesKey) ?? 0;
  }

  /// Appends workout session to local history.
  Future<void> addWorkoutSession(WorkoutSessionLog session) async {
    final history = await loadWorkoutHistory();
    history.insert(0, session);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      AppConstants.workoutHistoryKey,
      jsonEncode(history.map((e) => e.toJson()).toList()),
    );
  }

  /// True after the user finishes first-launch onboarding.
  Future<bool> isOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConstants.onboardingCompleteKey) ?? false;
  }

  /// Marks onboarding as finished (shown only once).
  Future<void> setOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.onboardingCompleteKey, true);
  }

  /// Loads workout history newest first.
  Future<List<WorkoutSessionLog>> loadWorkoutHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(AppConstants.workoutHistoryKey);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => WorkoutSessionLog.fromJson(e as Map<String, dynamic>)).toList();
  }
}
