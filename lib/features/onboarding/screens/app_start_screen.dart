import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../home/screens/main_navigation_screen.dart';
import 'onboarding_screen.dart';

class AppStartScreen extends StatefulWidget {
  const AppStartScreen({super.key});

  @override
  State<AppStartScreen> createState() => _AppStartScreenState();
}

class _AppStartScreenState extends State<AppStartScreen> {
  static const String settingsBoxName = 'app_settings';
  static const String onboardingKey = 'onboarding_completed';

  bool get isCompleted {
    final box = Hive.box(settingsBoxName);
    return box.get(onboardingKey, defaultValue: false) == true;
  }

  Future<void> completeOnboarding() async {
    final box = Hive.box(settingsBoxName);
    await box.put(onboardingKey, true);

    if (!mounted) return;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (isCompleted) {
      return const MainNavigationScreen();
    }

    return OnboardingScreen(
      onCompleted: completeOnboarding,
    );
  }
}