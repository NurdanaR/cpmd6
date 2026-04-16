import 'dart:async';
import 'package:flutter/material.dart';
import '../models/fitness_model.dart';

class FitnessProvider extends ChangeNotifier {
  final List<Food> _selectedFoods = [];
  List<Food> get selectedFoods => _selectedFoods;

  void toggleFood(Food food) {
    if (_selectedFoods.contains(food)) {
      _selectedFoods.remove(food);
    } else {
      _selectedFoods.add(food);
    }
    notifyListeners();
  }

  void clearSelection() {
    _selectedFoods.clear();
    notifyListeners();
  }

  int get totalCalories => _selectedFoods.fold(0, (sum, item) => sum + item.calories);
  double get totalProtein => _selectedFoods.fold(0.0, (sum, item) => sum + item.protein);
  double get totalFat => _selectedFoods.fold(0.0, (sum, item) => sum + item.fat);
  double get totalCarbs => _selectedFoods.fold(0.0, (sum, item) => sum + item.carbs);

  // STREAMS
  final _burnController = StreamController<int>();
  Stream<int> get liveBurnStream => _burnController.stream;

  void startBurningCalories() {
    int burned = 0;
    Timer.periodic(const Duration(seconds: 3), (timer) {
      burned += 2;
      if (!_burnController.isClosed) _burnController.add(burned);
    });
  }

  @override
  void dispose() {
    _burnController.close();
    super.dispose();
  }
}