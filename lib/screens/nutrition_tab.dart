import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/openai_config.dart';
import '../providers/fitness_provider.dart';
import '../providers/nutrition_provider.dart';
import '../widgets/calorie_balance_card.dart';

/// AI nutrition diary with offline fallback when OpenAI quota is exceeded.
class NutritionTab extends StatefulWidget {
  const NutritionTab({super.key});

  @override
  State<NutritionTab> createState() => _NutritionTabState();
}

class _NutritionTabState extends State<NutritionTab> {
  /// Opens dialog to add product name and grams.
  Future<void> _showAddFoodDialog() async {
    final nameController = TextEditingController();
    final gramsController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add product'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Product name',
                hintText: 'e.g. Chicken breast',
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: gramsController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Weight (grams)',
                hintText: 'e.g. 150',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Analyze with AI'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final name = nameController.text.trim();
    final grams = double.tryParse(gramsController.text.replaceAll(',', '.'));
    if (name.isEmpty || grams == null || grams <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter product name and valid grams')),
      );
      return;
    }

    await context.read<NutritionProvider>().addFood(name, grams);
    if (!mounted) return;
    final nutrition = context.read<NutritionProvider>();
    if (nutrition.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(nutrition.error!), backgroundColor: Colors.red.shade700),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Added — calories calculated by AI')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final nutrition = context.watch<NutritionProvider>();
    final fitness = context.watch<FitnessProvider>();

    if (!OpenAIConfig.isConfigured) {
      return _missingKeyView();
    }

    return Stack(
      children: [
        Column(
          children: [
            CalorieBalanceCard(
              remaining: nutrition.dailyCalorieGoal - nutrition.totalCalories + fitness.burnedCalories,
              eaten: nutrition.totalCalories,
              burned: fitness.burnedCalories,
              dailyGoal: nutrition.dailyCalorieGoal,
              aiNote: nutrition.dailyPlan?.note,
            ),
            _MacroTargetsRow(nutrition: nutrition),
            if (nutrition.error != null)
              Material(
                color: Colors.orange.shade100,
                child: ListTile(
                  dense: true,
                  leading: const Icon(Icons.info_outline, size: 20),
                  title: Text(
                    nutrition.error!,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: nutrition.clearError,
                  ),
                ),
              ),
            Expanded(
              child: nutrition.entries.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'No products yet.\nTap + — OpenAI will calculate calories and macros.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(15, 8, 15, 88),
                      itemCount: nutrition.entries.length,
                      itemBuilder: (context, index) {
                        final item = nutrition.entries[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'AI',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Text(
                              '${item.grams.toStringAsFixed(0)} g · ${item.calories} kcal · '
                              'P ${item.protein.toStringAsFixed(1)}g · F ${item.fat.toStringAsFixed(1)}g · '
                              'C ${item.carbs.toStringAsFixed(1)}g',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: 'Recalculate with AI',
                                  icon: const Icon(Icons.auto_awesome, size: 20),
                                  onPressed: nutrition.isLoading
                                      ? null
                                      : () => nutrition.reanalyzeEntry(item.id),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                  onPressed: () => nutrition.removeEntry(item.id),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
        if (nutrition.isLoading)
          const ColoredBox(
            color: Color(0x66000000),
            child: Center(child: CircularProgressIndicator()),
          ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton.extended(
            onPressed: nutrition.isLoading ? null : _showAddFoodDialog,
            icon: const Icon(Icons.add),
            label: const Text('Add product'),
          ),
        ),
      ],
    );
  }

  Widget _missingKeyView() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.key_off, size: 56),
          const SizedBox(height: 16),
          const Text(
            'OpenAI API key required',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Add OPENAI_API_KEY to .env and restart:\nflutter run -d chrome',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

class _MacroTargetsRow extends StatelessWidget {
  const _MacroTargetsRow({required this.nutrition});

  final NutritionProvider nutrition;

  @override
  Widget build(BuildContext context) {
    final plan = nutrition.dailyPlan;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _cell('Eaten P', '${nutrition.totalProtein.toStringAsFixed(0)}g', Colors.blue),
                _cell('Eaten F', '${nutrition.totalFat.toStringAsFixed(0)}g', Colors.red),
                _cell('Eaten C', '${nutrition.totalCarbs.toStringAsFixed(0)}g', Colors.green),
                IconButton(
                  tooltip: 'Recalculate with AI (uses quota)',
                  icon: const Icon(Icons.auto_awesome),
                  onPressed: nutrition.isLoading
                      ? null
                      : () => nutrition.refreshDailyPlan(useAi: true),
                ),
                IconButton(
                  tooltip: 'Offline formula only',
                  icon: const Icon(Icons.calculate_outlined),
                  onPressed: nutrition.isLoading
                      ? null
                      : () => nutrition.refreshDailyPlan(useAi: false),
                ),
                IconButton(
                  tooltip: 'Clear log',
                  icon: const Icon(Icons.delete_sweep_outlined),
                  onPressed: nutrition.isLoading ? null : () => nutrition.clearLog(),
                ),
              ],
            ),
            if (plan != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Target: P ${plan.proteinG.toStringAsFixed(0)}g · '
                  'F ${plan.fatG.toStringAsFixed(0)}g · C ${plan.carbsG.toStringAsFixed(0)}g',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _cell(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 13)),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }
}
