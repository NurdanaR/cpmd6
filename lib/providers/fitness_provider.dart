import 'dart:async';
import 'package:flutter/foundation.dart';
import '../core/constants.dart';
import '../models/fitness_model.dart';
import '../services/storage_service.dart';

/// ViewModel for nutrition selection, macros, and simulated calorie burn.
class FitnessProvider extends ChangeNotifier {
  FitnessProvider(this._storage);

  final StorageService _storage;
  final List<Food> _selectedFoods = [];
  final Map<String, Food> _catalogById = {};
  StreamSubscription<int>? _burnSub;
  int _burnedCalories = 0;

  List<Food> get selectedFoods => List.unmodifiable(_selectedFoods);
  int get burnedCalories => _burnedCalories;

  int get totalCalories =>
      _selectedFoods.fold(0, (sum, item) => sum + item.calories);

  double get totalProtein =>
      _selectedFoods.fold(0.0, (sum, item) => sum + item.protein);

  double get totalFat =>
      _selectedFoods.fold(0.0, (sum, item) => sum + item.fat);

  double get totalCarbs =>
      _selectedFoods.fold(0.0, (sum, item) => sum + item.carbs);

  /// Simulated workout calorie burn stream for demo purposes.
  Stream<int> get burnedCaloriesStream async* {
    int burned = _burnedCalories;
    while (true) {
      await Future.delayed(AppConstants.calorieTickInterval);
      burned += 1;
      _burnedCalories = burned;
      yield burned;
    }
  }

  /// Registers catalog foods and restores persisted selection.
  Future<void> bindCatalog(List<Food> catalog) async {
    _catalogById
      ..clear()
      ..addEntries(catalog.map((f) => MapEntry(f.id, f)));

    final savedIds = await _storage.loadSelectedFoodIds();
    _selectedFoods
      ..clear()
      ..addAll(
        savedIds
            .map((id) => _catalogById[id])
            .whereType<Food>(),
      );
    notifyListeners();
  }

  /// Toggles food selection and persists ids.
  Future<void> toggleFood(Food food) async {
    if (_selectedFoods.contains(food)) {
      _selectedFoods.remove(food);
    } else {
      _selectedFoods.add(food);
    }
    await _persistSelection();
    notifyListeners();
  }

  /// Clears all selected foods.
  Future<void> clearFoods() async {
    _selectedFoods.clear();
    await _persistSelection();
    notifyListeners();
  }

  /// Saves selected food ids to SharedPreferences.
  Future<void> _persistSelection() async {
    await _storage.saveSelectedFoodIds(
      _selectedFoods.map((f) => f.id).toList(),
    );
  }

  @override
  void dispose() {
    _burnSub?.cancel();
    super.dispose();
  }
}
