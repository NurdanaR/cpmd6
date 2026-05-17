import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../models/fitness_model.dart';
import '../providers/fitness_provider.dart';
import '../repositories/food_repository.dart';
import '../widgets/async_state_view.dart';
import '../widgets/calorie_balance_card.dart';

/// Nutrition tracking with offline-aware food list.
class NutritionTab extends StatefulWidget {
  const NutritionTab({super.key, this.foodRepository});

  final FoodRepository? foodRepository;

  @override
  State<NutritionTab> createState() => _NutritionTabState();
}

class _NutritionTabState extends State<NutritionTab> {
  late final FoodRepository _repository;
  List<Food> _foods = [];
  bool _loading = true;
  String? _error;
  bool _offline = false;

  @override
  void initState() {
    super.initState();
    _repository = widget.foodRepository ?? FoodRepository();
    _loadFoods();
  }

  /// Loads foods and syncs catalog with FitnessProvider.
  Future<void> _loadFoods() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final foods = await _repository.fetchFoods();
      if (!mounted) return;
      await context.read<FitnessProvider>().bindCatalog(foods);
      setState(() {
        _foods = foods;
        _loading = false;
        _offline = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
        _offline = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final fitness = context.watch<FitnessProvider>();

    return Column(
      children: [
        if (_offline)
          MaterialBanner(
            content: const Text('Offline mode — showing cached data when available'),
            leading: const Icon(Icons.wifi_off),
            actions: [
              TextButton(onPressed: _loadFoods, child: const Text('Retry')),
            ],
          ),
        StreamBuilder<int>(
          stream: fitness.burnedCaloriesStream,
          initialData: fitness.burnedCalories,
          builder: (context, snapshot) {
            final burned = snapshot.data ?? 0;
            final eaten = fitness.totalCalories;
            final remaining = AppConstants.dailyCalorieGoal - eaten + burned;
            return CalorieBalanceCard(
              remaining: remaining,
              eaten: eaten,
              burned: burned,
            );
          },
        ),
        _MacroRow(fitness: fitness),
        const SizedBox(height: 8),
        Expanded(
          child: AsyncStateView(
            isLoading: _loading,
            error: _error,
            isEmpty: !_loading && _error == null && _foods.isEmpty,
            onRetry: _loadFoods,
            emptyMessage: 'No foods found. Add documents to Firestore `foods` collection.',
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 16),
              itemCount: _foods.length,
              itemBuilder: (context, index) {
                final food = _foods[index];
                final selected = fitness.selectedFoods.contains(food);
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: selected
                        ? Theme.of(context).colorScheme.primaryContainer
                        : Theme.of(context).cardColor,
                  ),
                  child: CheckboxListTile(
                    value: selected,
                    onChanged: (_) => fitness.toggleFood(food),
                    title: Text(food.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${food.calories} kcal | P: ${food.protein}g'),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _MacroRow extends StatelessWidget {
  const _MacroRow({required this.fitness});

  final FitnessProvider fitness;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _macro('Proteins', '${fitness.totalProtein.toStringAsFixed(1)}g', Colors.blue),
            _macro('Fats', '${fitness.totalFat.toStringAsFixed(1)}g', Colors.red),
            _macro('Carbs', '${fitness.totalCarbs.toStringAsFixed(1)}g', Colors.green),
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Clear selection',
              onPressed: fitness.clearFoods,
            ),
          ],
        ),
      ),
    );
  }

  Widget _macro(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}
