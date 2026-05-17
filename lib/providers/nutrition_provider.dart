import 'package:flutter/foundation.dart';
import '../core/api_error_message.dart';
import '../core/nutrition_math.dart';
import '../models/daily_nutrition_plan.dart';
import '../models/food_log_entry.dart';
import '../repositories/user_data_repository.dart';
import '../services/nutrition_calculator_service.dart';
import '../services/openai_service.dart';

/// ViewModel: food log, daily norm, OpenAI with offline fallback for daily plan.
class NutritionProvider extends ChangeNotifier {
  NutritionProvider(
    this._userData, {
    OpenAIService? openAi,
    NutritionCalculatorService? local,
  })  : _openAi = openAi ?? OpenAIService(),
        _local = local ?? NutritionCalculatorService();

  final UserDataRepository _userData;
  final OpenAIService _openAi;
  final NutritionCalculatorService _local;

  final List<FoodLogEntry> _entries = [];
  DailyNutritionPlan? _dailyPlan;
  bool _loading = false;
  String? _error;

  List<FoodLogEntry> get entries => List.unmodifiable(_entries);
  DailyNutritionPlan? get dailyPlan => _dailyPlan;
  bool get isLoading => _loading;
  String? get error => _error;

  int get dailyCalorieGoal => _dailyPlan?.dailyCalories ?? 2400;

  int get totalCalories => _entries.fold(0, (s, e) => s + e.calories);

  double get totalProtein => _entries.fold(0.0, (s, e) => s + e.protein);

  double get totalFat => _entries.fold(0.0, (s, e) => s + e.fat);

  double get totalCarbs => _entries.fold(0.0, (s, e) => s + e.carbs);

  /// Loads data from Firestore (if signed in) and local cache.
  Future<void> load() async {
    _setLoading(true);
    try {
      await _userData.migrateLocalToCloudIfNeeded();
      _entries
        ..clear()
        ..addAll(await _userData.loadFoodLog());
      _normalizeEntryCalories();
      _dailyPlan = await _userData.loadDailyPlan();
      await _fixCorruptDailyPlan();
      await _ensureOfflineDailyPlan();
      _error = null;
    } catch (e) {
      _error = shortApiErrorMessage(e);
    } finally {
      _setLoading(false);
    }
  }

  /// Adds food using OpenAI only (macros from AI).
  Future<void> addFood(String name, double grams) async {
    _setLoading(true);
    _error = null;
    try {
      final entry = await _openAi.analyzeFood(name: name.trim(), grams: grams);
      _entries.insert(0, entry);
      await _userData.saveFoodLog(_entries);
    } catch (e) {
      _error = shortApiErrorMessage(e);
    } finally {
      _setLoading(false);
    }
  }

  /// Re-runs OpenAI analysis for an existing log entry.
  Future<void> reanalyzeEntry(String entryId) async {
    final index = _entries.indexWhere((e) => e.id == entryId);
    if (index < 0) return;

    final old = _entries[index];
    _setLoading(true);
    _error = null;
    try {
      final updated = await _openAi.analyzeFood(name: old.name, grams: old.grams);
      _entries[index] = FoodLogEntry(
        id: old.id,
        name: old.name,
        grams: old.grams,
        calories: updated.calories,
        protein: updated.protein,
        fat: updated.fat,
        carbs: updated.carbs,
        loggedAt: old.loggedAt,
      );
      await _userData.saveFoodLog(_entries);
    } catch (e) {
      _error = shortApiErrorMessage(e);
    } finally {
      _setLoading(false);
    }
  }

  /// Recalculates daily norm; [useAi] true uses OpenAI, false uses offline formula.
  Future<void> refreshDailyPlan({bool useAi = true}) async {
    final profile = await _userData.loadProfile();
    final height = double.tryParse(profile['height'] ?? '');
    final weight = double.tryParse(profile['weight'] ?? '');

    if (height == null || height <= 0 || weight == null || weight <= 0) {
      _error = 'Set height and weight in Profile first.';
      notifyListeners();
      return;
    }

    _setLoading(true);
    try {
      if (useAi) {
        try {
          _dailyPlan = await _openAi.calculateDailyPlan(heightCm: height, weightKg: weight);
          _error = null;
        } catch (e) {
          _dailyPlan = _local.calculateDailyPlan(heightCm: height, weightKg: weight);
          _error = shortApiErrorMessage(e);
        }
      } else {
        _dailyPlan = _local.calculateDailyPlan(heightCm: height, weightKg: weight);
        _error = null;
      }
      await _userData.saveDailyPlan(_dailyPlan!);
    } catch (e) {
      _error = shortApiErrorMessage(e);
    } finally {
      _setLoading(false);
    }
  }

  /// Fixes daily plan saved with old carbs bug (e.g. 1670g carbs).
  Future<void> _fixCorruptDailyPlan() async {
    final plan = _dailyPlan;
    if (plan == null || plan.carbsG <= 800) return;

    final profile = await _userData.loadProfile();
    final height = double.tryParse(profile['height'] ?? '');
    final weight = double.tryParse(profile['weight'] ?? '');
    if (height == null || height <= 0 || weight == null || weight <= 0) return;

    _dailyPlan = _local.calculateDailyPlan(heightCm: height, weightKg: weight);
    await _userData.saveDailyPlan(_dailyPlan!);
  }

  /// Builds offline plan when none saved yet.
  Future<void> _ensureOfflineDailyPlan() async {
    if (_dailyPlan != null) return;
    final profile = await _userData.loadProfile();
    final height = double.tryParse(profile['height'] ?? '');
    final weight = double.tryParse(profile['weight'] ?? '');
    if (height == null || height <= 0 || weight == null || weight <= 0) return;
    _dailyPlan = _local.calculateDailyPlan(heightCm: height, weightKg: weight);
    await _userData.saveDailyPlan(_dailyPlan!);
  }

  /// Removes one log entry by id.
  Future<void> removeEntry(String id) async {
    _entries.removeWhere((e) => e.id == id);
    await _userData.saveFoodLog(_entries);
    notifyListeners();
  }

  /// Clears today's food log.
  Future<void> clearLog() async {
    _entries.clear();
    await _userData.saveFoodLog(_entries);
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  /// Fixes kcal when they disagree with P/F/C (old AI responses).
  void _normalizeEntryCalories() {
    var changed = false;
    for (var i = 0; i < _entries.length; i++) {
      final e = _entries[i];
      final expected = NutritionMath.caloriesFromMacros(e.protein, e.fat, e.carbs);
      if ((expected - e.calories).abs() > 1) {
        _entries[i] = FoodLogEntry(
          id: e.id,
          name: e.name,
          grams: e.grams,
          calories: expected,
          protein: e.protein,
          fat: e.fat,
          carbs: e.carbs,
          loggedAt: e.loggedAt,
        );
        changed = true;
      }
    }
    if (changed) {
      _userData.saveFoodLog(_entries);
    }
  }
}
