import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/nutrition_provider.dart';
import '../providers/theme_provider.dart';
import '../repositories/user_data_repository.dart';

/// User profile, theme, and sign-out.
class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key, required this.onNameChanged});

  final VoidCallback onNameChanged;

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final _nameController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  /// Loads profile from Firestore or local cache.
  Future<void> _load() async {
    final profile = await context.read<UserDataRepository>().loadProfile();
    if (!mounted) return;
    setState(() {
      _nameController.text = profile['name'] ?? '';
      _heightController.text = profile['height'] ?? '';
      _weightController.text = profile['weight'] ?? '';
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final auth = context.watch<AuthProvider>();
    final email = auth.user?.email ?? '';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: const Icon(Icons.person, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 12),
          if (email.isNotEmpty)
            Text(email, style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 24),
          _field(_nameController, 'Display name', Icons.edit),
          const SizedBox(height: 12),
          _field(_heightController, 'Height (cm)', Icons.height, keyboard: TextInputType.number),
          const SizedBox(height: 12),
          _field(_weightController, 'Weight (kg)', Icons.monitor_weight_outlined, keyboard: TextInputType.number),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Dark theme'),
            value: themeProvider.isDark,
            onChanged: (_) => themeProvider.toggle(),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () async {
              await context.read<UserDataRepository>().saveProfile(
                    name: _nameController.text,
                    height: _heightController.text,
                    weight: _weightController.text,
                  );
              widget.onNameChanged();
              if (!context.mounted) return;
              await context.read<NutritionProvider>().refreshDailyPlan(useAi: false);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile updated — daily norm recalculated')),
              );
            },
            style: FilledButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
            child: const Text('Save profile'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () async {
              await auth.signOut();
            },
            icon: const Icon(Icons.logout),
            label: const Text('Sign out'),
            style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
          ),
        ],
      ),
    );
  }

  Widget _field(TextEditingController c, String label, IconData icon, {TextInputType? keyboard}) {
    return TextField(
      controller: c,
      keyboardType: keyboard,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
