import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/fitness_provider.dart';
import '../repositories/user_data_repository.dart';
import '../services/workout_calorie_service.dart';
import '../widgets/exercise_network_image.dart';

/// Workout mode: enter weight, reps, sets and log calories burned.
class WorkoutSessionScreen extends StatefulWidget {
  const WorkoutSessionScreen({
    super.key,
    required this.exerciseName,
    this.imageUrl,
  });

  final String exerciseName;
  final String? imageUrl;

  @override
  State<WorkoutSessionScreen> createState() => _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends State<WorkoutSessionScreen> {
  final _weightController = TextEditingController();
  final _repsController = TextEditingController();
  final _setsController = TextEditingController(text: '3');
  final _calorieService = WorkoutCalorieService();

  int? _previewKcal;
  bool _saving = false;

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    _setsController.dispose();
    super.dispose();
  }

  /// Parses form fields or returns null if invalid.
  ({double weight, int reps, int sets})? _readInputs() {
    final weight = double.tryParse(_weightController.text.replaceAll(',', '.'));
    final reps = int.tryParse(_repsController.text);
    final sets = int.tryParse(_setsController.text);
    if (weight == null || weight <= 0 || reps == null || reps <= 0 || sets == null || sets <= 0) {
      return null;
    }
    return (weight: weight, reps: reps, sets: sets);
  }

  /// Updates preview calories from current inputs.
  Future<void> _updatePreview() async {
    final inputs = _readInputs();
    if (inputs == null) {
      setState(() => _previewKcal = null);
      return;
    }
    final profile = await context.read<UserDataRepository>().loadProfile();
    final userWeight = double.tryParse(profile['weight'] ?? '') ?? 70;
    final kcal = _calorieService.estimateBurned(
      weightKg: inputs.weight,
      reps: inputs.reps,
      sets: inputs.sets,
      userWeightKg: userWeight,
    );
    setState(() => _previewKcal = kcal);
  }

  /// Saves workout and returns burned calories to the app total.
  Future<void> _finishWorkout() async {
    final inputs = _readInputs();
    if (inputs == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter valid weight, reps, and sets')),
      );
      return;
    }

    setState(() => _saving = true);
    final fitness = context.read<FitnessProvider>();
    final profile = await context.read<UserDataRepository>().loadProfile();
    final userWeight = double.tryParse(profile['weight'] ?? '') ?? 70;
    final kcal = _calorieService.estimateBurned(
      weightKg: inputs.weight,
      reps: inputs.reps,
      sets: inputs.sets,
      userWeightKg: userWeight,
    );

    await fitness.completeWorkout(
          exerciseName: widget.exerciseName,
          weightKg: inputs.weight,
          reps: inputs.reps,
          sets: inputs.sets,
          caloriesBurned: kcal,
        );

    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Workout saved: $kcal kcal burned')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = widget.imageUrl;

    return Scaffold(
      appBar: AppBar(title: Text(widget.exerciseName)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (imageUrl != null && imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: ExerciseNetworkImage(url: imageUrl, height: 180, width: double.infinity),
              ),
            const SizedBox(height: 20),
            Text(
              'Workout mode',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter your working weight and volume. Calories are estimated from load × reps × sets and your body weight from Profile.',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
            const SizedBox(height: 24),
            _field(_weightController, 'Working weight (kg)', Icons.fitness_center, onChanged: (_) => _updatePreview()),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _field(_repsController, 'Reps per set', Icons.repeat, onChanged: (_) => _updatePreview()),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _field(_setsController, 'Sets', Icons.format_list_numbered, onChanged: (_) => _updatePreview()),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_previewKcal != null)
              Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Text('🔥', style: TextStyle(fontSize: 28)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Estimated burn', style: TextStyle(fontSize: 13)),
                            Text(
                              '$_previewKcal kcal',
                              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _saving ? null : _finishWorkout,
              icon: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.check_circle_outline),
              label: Text(_saving ? 'Saving...' : 'Finish workout'),
              style: FilledButton.styleFrom(minimumSize: const Size(double.infinity, 52)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    void Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
