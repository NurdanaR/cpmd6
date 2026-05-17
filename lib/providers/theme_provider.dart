import 'package:flutter/material.dart';
import '../services/storage_service.dart';

/// Manages light/dark theme and persists user choice.
class ThemeProvider extends ChangeNotifier {
  ThemeProvider(this._storage);

  final StorageService _storage;
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;
  bool get isDark => _themeMode == ThemeMode.dark;

  /// Loads saved theme from storage.
  Future<void> load() async {
    final dark = await _storage.loadDarkMode();
    _themeMode = dark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  /// Toggles between light and dark themes.
  Future<void> toggle() async {
    _themeMode = isDark ? ThemeMode.light : ThemeMode.dark;
    await _storage.saveDarkMode(isDark);
    notifyListeners();
  }
}
