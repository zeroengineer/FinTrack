import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/onboarding/onboarding_flow.dart';
import 'features/pin/pin_unlock_screen.dart';
import 'features/shell/app_shell.dart';
import 'providers/app_state.dart';
import 'providers/settings_provider.dart';
import 'theme/app_theme.dart';

class FinanceTrackerApp extends ConsumerWidget {
  const FinanceTrackerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final sessionUnlocked = ref.watch(sessionUnlockedProvider);

    Widget home;
    if (!settings.onboardingComplete) {
      home = const OnboardingFlow();
    } else if (settings.pinLockEnabled && !sessionUnlocked) {
      home = const PinUnlockScreen();
    } else {
      home = const AppShell();
    }

    return MaterialApp(
      title: 'FinTrack',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(Brightness.light),
      darkTheme: buildAppTheme(Brightness.dark),
      themeMode: settings.darkMode ? ThemeMode.dark : ThemeMode.light,
      home: home,
    );
  }
}
