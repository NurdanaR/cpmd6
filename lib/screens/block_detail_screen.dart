import 'package:flutter/material.dart';
import '../models/fitness_model.dart';
import '../repositories/favorites_repository.dart';
import '../widgets/exercise_network_image.dart';

/// Lists exercises in a workout block with add-to-favorites action.
class BlockDetailScreen extends StatelessWidget {
  BlockDetailScreen({super.key, required this.plan, FavoritesRepository? favorites})
      : _favorites = favorites ?? FavoritesRepository();

  final WorkoutPlan plan;
  final FavoritesRepository _favorites;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(plan.title)),
      body: ListView.builder(
        itemCount: plan.exercises.length,
        itemBuilder: (context, index) {
          final ex = plan.exercises[index];
          return Card(
            margin: const EdgeInsets.all(10),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                ExerciseNetworkImage(url: ex.imageUrl, height: 200, width: double.infinity),
                ListTile(
                  title: Text(ex.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: ex.subtitle != null ? Text(ex.subtitle!) : null,
                  trailing: IconButton(
                    icon: const Icon(Icons.favorite_border),
                    onPressed: () async {
                      await _favorites.add(ex.name, ex.imageUrl);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${ex.name} added to Favorites')),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
