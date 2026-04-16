import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _nameKey = 'user_name';

  Future<void> saveName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, name);
  }

  Future<String> getName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_nameKey) ?? 'GYM';
  }

  Future<void> saveMetrics(String height, String weight) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_height', height);
    await prefs.setString('user_weight', weight);
  }

  Future<Map<String, String>> getMetrics() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'height': prefs.getString('user_height') ?? "",
      'weight': prefs.getString('user_weight') ?? "",
    };
  }
}