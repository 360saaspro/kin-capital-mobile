import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'screens/auth/onboarding_screen.dart';


void main() {
  runApp(const KinApp());
}

class KinApp extends StatelessWidget {
  const KinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const OnboardingScreen(),
    );
  }
}

