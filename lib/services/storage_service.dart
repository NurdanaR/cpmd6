import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';

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

  /// Persists selected food ids as comma-separated string.
  Future<void> saveSelectedFoodIds(List<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(AppConstants.selectedFoodsKey, ids);
  }

  /// Loads previously selected food ids.
  Future<List<String>> loadSelectedFoodIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(AppConstants.selectedFoodsKey) ?? [];
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
}
