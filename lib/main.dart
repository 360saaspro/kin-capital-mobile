// Kin Banking — powered by Kin Capital Rails
// Entity ID: set via --dart-define=ENTITY_ID, or defaults to the demo trader.
// API base URL: set via --dart-define=API_BASE_URL, or auto-detects.

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'services/app_config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'core/theme/app_colors.dart';
import 'core/services/auth_service.dart';
import 'screens/main_screen.dart';
import 'screens/auth/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService.instance.authStateChanges,
      builder: (context, snapshot) {
        if (!AuthService.instance.isLoggedIn) {
          return const OnboardingScreen();
        }
        if (snapshot.hasData || AuthService.instance.currentUser != null) {
          return const MainScreen();
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primaryTeal),
            ),
          );
        }
        return const OnboardingScreen();
      },
    );
  }
}