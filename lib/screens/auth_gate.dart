import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'auth_screen.dart';
import 'main_navigation_screen.dart';

/// Routes to login or main app based on Firebase Auth session.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.isInitializing) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!auth.isAuthenticated) {
      return const AuthScreen();
    }

    return const MainNavigationScreen();
  }
}
