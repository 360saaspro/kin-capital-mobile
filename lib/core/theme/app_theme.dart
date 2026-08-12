import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get light {
    final baseTheme = ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: AppColors.onPrimaryContainer,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        secondaryContainer: AppColors.secondaryContainer,
        onSecondaryContainer: AppColors.onSecondaryContainer,
        tertiary: AppColors.tertiary,
        onTertiary: AppColors.onTertiary,
        tertiaryContainer: AppColors.tertiaryContainer,
        onTertiaryContainer: AppColors.onTertiaryContainer,
        error: AppColors.error,
        onError: AppColors.onError,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        surfaceContainerHighest: AppColors.surfaceVariant,
        onSurfaceVariant: AppColors.onSurfaceVariant,
        outline: AppColors.outline,
      ),
      scaffoldBackgroundColor: AppColors.background,
    );

    return baseTheme.copyWith(
      textTheme: GoogleFonts.manropeTextTheme(baseTheme.textTheme).copyWith(
        bodyLarge: GoogleFonts.inter(
          textStyle: baseTheme.textTheme.bodyLarge,
          fontWeight: FontWeight.w500,
          fontSize: 18,
        ),
        bodyMedium: GoogleFonts.inter(
          textStyle: baseTheme.textTheme.bodyMedium,
          fontWeight: FontWeight.w400,
          fontSize: 16,
        ),
        labelSmall: GoogleFonts.inter(
          textStyle: baseTheme.textTheme.labelSmall,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      cardTheme: CardThemeData(
        color: AppColors.kinMist,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      buttonTheme: const ButtonThemeData(
        height: 56,
        padding: EdgeInsets.symmetric(horizontal: 24),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  // Helper for monospaced data (Amounts, Account Numbers)
  static TextStyle dataStyle({Color? color, double? fontSize, FontWeight? fontWeight, double? letterSpacing}) {
    return GoogleFonts.jetBrainsMono(
      color: color,
      fontSize: fontSize ?? 16,
      fontWeight: fontWeight ?? FontWeight.w500,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle headingStyle({Color? color, double? fontSize, FontWeight? fontWeight, double? letterSpacing, double? height, FontStyle? fontStyle}) {
    return GoogleFonts.manrope(
      color: color ?? AppColors.kinInk,
      fontSize: fontSize ?? 24,
      fontWeight: fontWeight ?? FontWeight.bold,
      letterSpacing: letterSpacing,
      height: height,
      fontStyle: fontStyle,
    );
  }

  static TextStyle bodyStyle({Color? color, double? fontSize, FontWeight? fontWeight, double? height, double? letterSpacing, FontStyle? fontStyle}) {
    return GoogleFonts.inter(
      color: color ?? AppColors.kinInk,
      fontSize: fontSize ?? 14,
      fontWeight: fontWeight ?? FontWeight.normal,
      height: height,
      letterSpacing: letterSpacing,
      fontStyle: fontStyle,
    );
  }

  static TextStyle labelStyle({Color? color, double? fontSize, FontWeight? fontWeight, double? letterSpacing}) {
    return GoogleFonts.inter(
      color: color ?? AppColors.kinInk,
      fontSize: fontSize ?? 12,
      fontWeight: fontWeight ?? FontWeight.w600,
      letterSpacing: letterSpacing,
    );
  }

  static ButtonStyle buttonStyle({Color? backgroundColor, Color? foregroundColor}) {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor ?? AppColors.primary,
      foregroundColor: foregroundColor ?? Colors.white,
      minimumSize: const Size.fromHeight(56),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
    );
  }
}
