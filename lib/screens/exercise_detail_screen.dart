import 'package:flutter/material.dart';
import '../models/fitness_model.dart';
import '../widgets/exercise_network_image.dart';

/// Lists exercises for a single muscle category.
class ExerciseDetailScreen extends StatelessWidget {
  const ExerciseDetailScreen({
    super.key,
    required this.categoryName,
    required this.exercises,
  });

  final String categoryName;
  final List<Exercise> exercises;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(categoryName)),
      body: ListView.builder(
        itemCount: exercises.length,
        itemBuilder: (context, index) {
          final ex = exercises[index];
          return Card(
            margin: const EdgeInsets.all(10),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                ExerciseNetworkImage(url: ex.imageUrl, height: 200, width: double.infinity),
                ListTile(
                  title: Text(ex.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(ex.instructions),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
