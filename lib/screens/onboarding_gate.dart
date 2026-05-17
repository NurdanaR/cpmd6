import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/storage_service.dart';
import 'onboarding_screen.dart';

/// Shows onboarding on first launch, then [child] (typically [AuthGate]).
class OnboardingGate extends StatefulWidget {
  const OnboardingGate({super.key, required this.child});

  final Widget child;

  @override
  State<OnboardingGate> createState() => _OnboardingGateState();
}

class _OnboardingGateState extends State<OnboardingGate> {
  bool? _onboardingComplete;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadFlag());
  }

  /// Reads whether onboarding was already completed.
  Future<void> _loadFlag() async {
    if (!mounted) return;
    final storage = context.read<StorageService>();
    final done = await storage.isOnboardingComplete();
    if (mounted) setState(() => _onboardingComplete = done);
  }

  /// Persists completion and opens the main app flow.
  Future<void> _finishOnboarding() async {
    final storage = context.read<StorageService>();
    await storage.setOnboardingComplete();
    if (mounted) setState(() => _onboardingComplete = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_onboardingComplete == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_onboardingComplete == false) {
      return OnboardingScreen(onComplete: _finishOnboarding);
    }

    return widget.child;
  }
}
