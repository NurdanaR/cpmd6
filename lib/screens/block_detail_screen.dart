import 'package:flutter/material.dart';
import '../models/fitness_model.dart';
import '../widgets/exercise_network_image.dart';
import '../widgets/favorite_toggle_button.dart';
import 'workout_session_screen.dart';

/// Lists exercises in a workout block with favorite and workout actions.
class BlockDetailScreen extends StatelessWidget {
  const BlockDetailScreen({super.key, required this.plan});

  final WorkoutPlan plan;

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
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Start workout',
                        icon: Icon(Icons.play_circle_outline, color: Theme.of(context).colorScheme.primary),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => WorkoutSessionScreen(
                                exerciseName: ex.name,
                                imageUrl: ex.imageUrl,
                              ),
                            ),
                          );
                        },
                      ),
                      FavoriteToggleButton(title: ex.name, imageUrl: ex.imageUrl),
                    ],
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
