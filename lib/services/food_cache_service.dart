import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';
import '../models/fitness_model.dart';

/// Persists food list JSON for offline nutrition access.
class FoodCacheService {
  /// Saves foods to SharedPreferences as JSON array.
  Future<void> saveFoods(List<Food> foods) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(foods.map((f) => f.toJson()).toList());
    await prefs.setString(AppConstants.foodsCacheKey, encoded);
  }

  /// Loads cached foods; returns empty list if none stored.
  Future<List<Food>> loadFoods() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(AppConstants.foodsCacheKey);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => Food.fromCacheJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Clears cached food data.
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.foodsCacheKey);
  }
}
