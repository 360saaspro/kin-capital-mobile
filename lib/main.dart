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
import 'core/services/firestore_service.dart';
import 'screens/main_screen.dart';
import 'screens/auth/onboarding_screen.dart';
import 'screens/admin/admin_panel_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization notice: $e');
  }

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
        // Still connecting — show splash spinner
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _SplashLoader();
        }

        final isLoggedIn = snapshot.hasData ||
            AuthService.instance.currentUser != null ||
            AuthService.instance.isLoggedIn;

        if (!isLoggedIn) {
          return const OnboardingScreen();
        }

        // Logged in — check role from Firestore before routing
        return _RoleRouter(uid: AuthService.instance.currentUid);
      },
    );
  }
}

/// Fetches the user's Firestore role and routes accordingly.
/// Shows a spinner while the Firestore call is in flight.
class _RoleRouter extends StatefulWidget {
  final String uid;
  const _RoleRouter({required this.uid});

  @override
  State<_RoleRouter> createState() => _RoleRouterState();
}

class _RoleRouterState extends State<_RoleRouter> {
  bool _checking = true;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkRole();
  }

  Future<void> _checkRole() async {
    try {
      final profile = await FirestoreService.instance.getUserProfile(widget.uid);
      final role = profile?['role'] as String? ?? 'user';
      if (mounted) {
        setState(() {
          _isAdmin = role == 'admin';
          _checking = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _checking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) return const _SplashLoader();
    if (_isAdmin) return const AdminRouterShell();
    return const MainScreen();
  }
}

/// Thin wrapper that launches AdminPanelScreen as the root widget.
/// Removes the back arrow so admin can't navigate "back" to nothing.
class AdminRouterShell extends StatelessWidget {
  const AdminRouterShell({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: AdminPanelScreen(entityId: AuthService.instance.currentUid),
    );
  }
}

class _SplashLoader extends StatelessWidget {
  const _SplashLoader();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: CircularProgressIndicator(color: AppColors.primaryTeal),
      ),
    );
  }
}