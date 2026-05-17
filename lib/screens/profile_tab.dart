import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../services/storage_service.dart';

/// User profile and app settings (theme toggle).
class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key, required this.onNameChanged, this.storage});

  final VoidCallback onNameChanged;
  final StorageService? storage;

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  late final StorageService _storage;
  final _nameController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _storage = widget.storage ?? StorageService();
    _load();
  }

  /// Loads profile fields from SharedPreferences.
  Future<void> _load() async {
    final name = await _storage.getName();
    final metrics = await _storage.getMetrics();
    if (!mounted) return;
    setState(() {
      _nameController.text = name;
      _heightController.text = metrics['height'] ?? '';
      _weightController.text = metrics['weight'] ?? '';
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: const Icon(Icons.person, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 24),
          _field(_nameController, 'Name', Icons.edit),
          const SizedBox(height: 12),
          _field(_heightController, 'Height (cm)', Icons.height, keyboard: TextInputType.number),
          const SizedBox(height: 12),
          _field(_weightController, 'Weight (kg)', Icons.monitor_weight_outlined, keyboard: TextInputType.number),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Dark theme'),
            subtitle: const Text('Material 3 light / dark mode'),
            value: themeProvider.isDark,
            onChanged: (_) => themeProvider.toggle(),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () async {
              await _storage.saveName(_nameController.text);
              await _storage.saveMetrics(_heightController.text, _weightController.text);
              widget.onNameChanged();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile updated')),
              );
            },
            style: FilledButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
            child: const Text('Save profile'),
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
