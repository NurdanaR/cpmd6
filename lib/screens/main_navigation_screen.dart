import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/fitness_provider.dart';
import '../providers/nutrition_provider.dart';
import '../services/storage_service.dart';
import 'favorites_tab.dart';
import 'nutrition_tab.dart';
import 'profile_tab.dart';
import 'workout_tab.dart';

/// Root shell with bottom navigation and calorie burn indicator.
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key, this.storage});

  final StorageService? storage;

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _index = 0;
  late final StorageService _storage;
  String _userName = 'User';

  @override
  void initState() {
    super.initState();
    _storage = widget.storage ?? StorageService();
    _loadName();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NutritionProvider>().load();
      context.read<FitnessProvider>().load();
    });
  }

  /// Refreshes displayed user name from storage.
  Future<void> _loadName() async {
    final name = await _storage.getName();
    if (mounted) setState(() => _userName = name);
  }

  @override
  Widget build(BuildContext context) {
    final fitness = context.watch<FitnessProvider>();

    final screens = [
      WorkoutTab(userName: _userName),
      const NutritionTab(),
      const FavoritesTab(),
      ProfileTab(onNameChanged: _loadName),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Fit Diary: $_userName'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Text(
                '🔥 ${fitness.burnedCalories} kcal',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
              ),
            ),
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: screens[_index],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.fitness_center), label: 'Workout'),
          NavigationDestination(icon: Icon(Icons.restaurant_menu), label: 'Nutrition'),
          NavigationDestination(icon: Icon(Icons.favorite), label: 'Favorites'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
