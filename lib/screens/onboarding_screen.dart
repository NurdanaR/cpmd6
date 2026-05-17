import 'package:flutter/material.dart';

/// First-launch walkthrough: workouts, nutrition, cloud sync.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onComplete});

  final Future<void> Function() onComplete;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _pageIndex = 0;
  bool _finishing = false;

  static const _pages = [
    _OnboardingPageData(
      icon: Icons.fitness_center_rounded,
      title: 'Добро пожаловать в Fit Diary',
      body:
          'Ваш дневник тренировок и питания в одном приложении. '
          'Отслеживайте прогресс каждый день.',
    ),
    _OnboardingPageData(
      icon: Icons.sports_gymnastics_rounded,
      title: 'Тренировки и избранное',
      body:
          'Каталог упражнений, режим подходов с весом и повторениями, '
          'избранные блоки и учёт сожжённых калорий.',
    ),
    _OnboardingPageData(
      icon: Icons.restaurant_menu_rounded,
      title: 'Питание с ИИ',
      body:
          'Добавляйте продукт и граммы — OpenAI посчитает калории и БЖУ. '
          'Дневная норма строится по росту и весу из профиля.',
    ),
    _OnboardingPageData(
      icon: Icons.cloud_sync_rounded,
      title: 'Облако и профиль',
      body:
          'Войдите по email, чтобы синхронизировать избранное, '
          'дневник питания и историю тренировок между устройствами.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Advances to next page or completes onboarding on the last page.
  Future<void> _onPrimaryPressed() async {
    if (_pageIndex < _pages.length - 1) {
      await _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
      return;
    }
    await _complete();
  }

  /// Skips remaining slides and opens the app.
  Future<void> _complete() async {
    if (_finishing) return;
    setState(() => _finishing = true);
    await widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isLast = _pageIndex == _pages.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _finishing ? null : _complete,
                child: const Text('Пропустить'),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _pageIndex = i),
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(page.icon, size: 56, color: colorScheme.primary),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          page.title,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          page.body,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pages.length, (i) {
                      final active = i == _pageIndex;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: active ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: active ? colorScheme.primary : colorScheme.outlineVariant,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _finishing ? null : _onPrimaryPressed,
                      child: _finishing
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(isLast ? 'Начать' : 'Далее'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPageData {
  const _OnboardingPageData({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;
}
