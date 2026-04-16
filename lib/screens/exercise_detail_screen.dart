import 'package:flutter/material.dart';
import '../models/fitness_model.dart';

class ExerciseDetailScreen extends StatelessWidget {
  final String categoryName;
  final List<Exercise> exercises;

  const ExerciseDetailScreen({super.key, required this.categoryName, required this.exercises});

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
            child: Column(
              children: [
                Image.network(ex.imageUrl, height: 200, fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, size: 100)),
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
