import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/fitness_provider.dart';
import 'providers/nutrition_provider.dart';
import 'providers/theme_provider.dart';
import 'repositories/favorites_repository.dart';
import 'repositories/user_data_repository.dart';
import 'screens/auth_gate.dart';
import 'services/auth_service.dart';
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
          home: const AuthGate(),
        );
      },
    );
  }
}

/// Registers global providers for the application.
Widget buildAppWithProviders() {
  final storage = StorageService();
  final authService = AuthService();
  final userDataRepository = UserDataRepository(authService: authService, storage: storage);
  final favoritesRepository = FavoritesRepository(authService: authService);

  return MultiProvider(
    providers: [
      Provider<AuthService>.value(value: authService),
      Provider<StorageService>.value(value: storage),
      Provider<UserDataRepository>.value(value: userDataRepository),
      Provider<FavoritesRepository>.value(value: favoritesRepository),
      ChangeNotifierProvider(create: (_) => ThemeProvider(storage)..load()),
      ChangeNotifierProvider(
        create: (_) => FitnessProvider(userDataRepository)..load(),
      ),
      ChangeNotifierProvider(
        create: (_) => AuthProvider(authService)..init(),
      ),
      ChangeNotifierProvider(
        create: (_) => NutritionProvider(userDataRepository),
      ),
    ],
    child: const FitApp(),
  );
}
