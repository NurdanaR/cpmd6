/// Application-wide constants for Fit Diary.
class AppConstants {
  AppConstants._();

  static const int dailyCalorieGoal = 2400;
  static const String foodsCacheKey = 'cached_foods_json';
  static const String selectedFoodsKey = 'selected_food_ids';
  static const String themeModeKey = 'theme_mode_dark';
  static const Duration networkTimeout = Duration(seconds: 15);
  static const Duration calorieTickInterval = Duration(seconds: 2);
}
