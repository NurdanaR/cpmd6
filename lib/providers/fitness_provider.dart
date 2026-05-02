import 'dart:async';
import 'package:flutter/material.dart';
import '../models/fitness_model.dart';

class FitnessProvider extends ChangeNotifier {
  final List<Food> _selectedFoods = [];
  List<Food> get selectedFoods => _selectedFoods;

  int get totalCalories => _selectedFoods.fold(0, (sum, item) => sum + item.calories);
  double get totalProtein => _selectedFoods.fold(0.0, (sum, item) => sum + item.protein);
  double get totalFat => _selectedFoods.fold(0.0, (sum, item) => sum + item.fat);
  double get totalCarbs => _selectedFoods.fold(0.0, (sum, item) => sum + item.carbs);

  void toggleFood(Food food) {
    if (_selectedFoods.contains(food)) {
      _selectedFoods.remove(food);
    } else {
      _selectedFoods.add(food);
    }
    notifyListeners();
  }

  void clearFoods() {
    _selectedFoods.clear();
    notifyListeners();
  }

  Stream<int> get burnedCaloriesStream async* {
    int burned = 0;
    while (true) {
      await Future.delayed(const Duration(seconds: 2));
      burned += 1;
      yield burned;
    }
  }
}