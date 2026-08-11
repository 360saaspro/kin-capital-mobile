// Kin Banking — powered by Kin Capital Rails
// Entity ID: set via --dart-define=ENTITY_ID, or defaults to the demo trader.
// API base URL: set via --dart-define=API_BASE_URL, or auto-detects.

import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'services/app_config.dart';
import 'screens/auth/onboarding_screen.dart';

void main() {
  // Set the entity ID from compile-time define or default
  AppConfig().entityId = const String.fromEnvironment(
    'ENTITY_ID',
    defaultValue: 'maria_trader_sps_001',
  );

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
      home: OnboardingScreen(),
    );
  }
}