/// Application-wide constants for Fit Diary.
class AppConstants {
  AppConstants._();

  static const String foodLogKey = 'nutrition_food_log_json';
  static const String dailyPlanKey = 'nutrition_daily_plan_json';
  static const String burnedCaloriesKey = 'burned_calories_today';
  static const String workoutHistoryKey = 'workout_history_json';
  static const String foodsCacheKey = 'cached_foods_json';
  static const String themeModeKey = 'theme_mode_dark';
  static const Duration networkTimeout = Duration(seconds: 15);
}
