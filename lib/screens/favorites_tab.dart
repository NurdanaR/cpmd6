import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/favorite_exercise.dart';
import '../providers/auth_provider.dart';
import '../repositories/favorites_repository.dart';
import '../widgets/async_state_view.dart';
import '../widgets/exercise_network_image.dart';
import 'workout_session_screen.dart';

/// Displays favorite workouts; tap to start workout mode.
class FavoritesTab extends StatefulWidget {
  const FavoritesTab({super.key});

  @override
  State<FavoritesTab> createState() => _FavoritesTabState();
}

class _FavoritesTabState extends State<FavoritesTab> {
  List<FavoriteExercise> _items = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  /// Reloads favorites from Firestore for current user.
  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await context.read<FavoritesRepository>().getAll();
      if (!mounted) return;
      setState(() {
        _items = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  /// Opens workout session screen for the selected exercise.
  void _openWorkout(FavoriteExercise item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WorkoutSessionScreen(
          exerciseName: item.title,
          imageUrl: item.imageUrl,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final email = context.watch<AuthProvider>().user?.email ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (email.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Text(
              'Account: $email',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Text(
            'Tap an exercise to start workout mode',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ),
        Expanded(
          child: AsyncStateView(
            isLoading: _loading,
            error: _error,
            isEmpty: !_loading && _error == null && _items.isEmpty,
            onRetry: _load,
            emptyMessage: 'No favorite exercises yet.\nOpen a workout block and tap ♥ to add.',
            child: RefreshIndicator(
              onRefresh: _load,
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return Dismissible(
                    key: ValueKey(item.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      color: Colors.red.shade400,
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (_) async {
                      await context.read<FavoritesRepository>().remove(item.id);
                      _load();
                    },
                    child: Card(
                      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                      child: ListTile(
                        onTap: () => _openWorkout(item),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: ExerciseNetworkImage(
                            url: item.imageUrl,
                            width: 60,
                            height: 60,
                          ),
                        ),
                        title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: const Text('Tap to start workout'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.play_circle_outline, color: Theme.of(context).colorScheme.primary),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                              onPressed: () async {
                                await context.read<FavoritesRepository>().remove(item.id);
                                _load();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
