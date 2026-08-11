import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors (Caribbean Modernist)
  static const Color kinTeal = Color(0xFF006A61);
  static const Color kinTealLight = Color(0xFF0FA89A);
  static const Color kinCoral = Color(0xFFAE3025);
  static const Color kinCoralLight = Color(0xFFFC6958);
  static const Color kinCream = Color(0xFFF5FBF8);
  static const Color kinInk = Color(0xFF171D1C);
  
  // Material 3 Color Scheme Mappings
  static const Color primary = kinTeal;
  static const Color onPrimary = Colors.white;
  static const Color primaryContainer = kinTealLight;
  static const Color onPrimaryContainer = Color(0xFF003530);

  static const Color secondary = kinCoral;
  static const Color onSecondary = Colors.white;
  static const Color secondaryContainer = kinCoralLight;
  static const Color onSecondaryContainer = Color(0xFF690002);

  static const Color tertiary = Color(0xFF984725);
  static const Color onTertiary = Colors.white;
  static const Color tertiaryContainer = Color(0xFFDD7C56);
  static const Color onTertiaryContainer = Color(0xFF571A00);

  // Background & Surface
  static const Color background = kinCream;
  static const Color onBackground = kinInk;
  static const Color surface = kinCream;
  static const Color onSurface = kinInk;
  static const Color surfaceVariant = Color(0xFFDEE4E1);
  static const Color onSurfaceVariant = Color(0xFF3D4947);
  
  // Functional Colors
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Colors.white;
  static const Color outline = Color(0xFF6C7A77);
  
  // Tonal Layers (Mist/Deep)
  static const Color kinMist = Color(0xFFEFF5F2);
  static const Color kinDeep = Color(0xFF2B3230);

  // High-fidelity design tokens
  static const Color glassWhite = Color(0x1AFFFFFF);
  static const Color glassOutline = Color(0x33FFFFFF);
  static const Color kinMistLight = Color(0xFFF1F7F5);
  
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, kinCoral],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF7A8E88), Color(0xFFD9E2E0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Gradients
  static const LinearGradient premiumGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFC247),
      Color(0xFFFF6B5A),
    ],
  );

  static const LinearGradient actionGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      kinTeal,
      kinTealLight,
    ],
  );

  // High-fidelity aliases
  static const Color primaryTeal = kinTeal;
  static const Color primaryCoral = kinCoral;
}
