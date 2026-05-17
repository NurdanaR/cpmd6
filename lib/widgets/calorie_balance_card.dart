import 'package:flutter/material.dart';
import '../core/constants.dart';

/// Gradient card showing daily calorie balance.
class CalorieBalanceCard extends StatelessWidget {
  const CalorieBalanceCard({
    super.key,
    required this.remaining,
    required this.eaten,
    required this.burned,
  });

  final int remaining;
  final int eaten;
  final int burned;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Container(
        key: ValueKey(remaining),
        width: double.infinity,
        margin: const EdgeInsets.all(15),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              'Daily Calorie Balance (goal ${AppConstants.dailyCalorieGoal})',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 10),
            Text(
              '$remaining kcal left',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _chip('Eaten', '$eaten', Icons.restaurant),
                _chip('Burned', '$burned', Icons.local_fire_department),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a small stat row inside the card.
  Widget _chip(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 18),
        const SizedBox(width: 5),
        Text('$label: $value', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
