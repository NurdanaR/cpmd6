import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/app_theme.dart';
import 'providers/fitness_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/main_navigation_screen.dart';
import 'services/storage_service.dart';

/// Root widget with Provider-based MVVM setup.
class FitApp extends StatelessWidget {
  const FitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, theme, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Fit Diary',
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: theme.themeMode,
          home: const MainNavigationScreen(),
        );
      },
    );
  }
}

/// Registers global providers for the application.
Widget buildAppWithProviders() {
  final storage = StorageService();
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ThemeProvider(storage)..load()),
      ChangeNotifierProvider(create: (_) => FitnessProvider(storage)),
    ],
    child: const FitApp(),
  );
}
