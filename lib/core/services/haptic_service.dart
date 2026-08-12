import 'package:flutter/services.dart';

/// Centralized Haptic Feedback wrapper for the "Kin Twist" interaction model.
class KinHaptics {
  /// Standard Tap (TextButton / IconButton / Cards): Light haptic impact
  static Future<void> lightTap() async {
    try {
      await HapticFeedback.lightImpact();
    } catch (_) {}
  }

  /// State Change (Toggle / Checkbox / Dropdown Selection): Medium haptic impact
  static Future<void> stateChange() async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (_) {}
  }

  /// Success (KYC Passed / Step Complete): Heavy, satisfying haptic click
  static Future<void> successClick() async {
    try {
      await HapticFeedback.heavyImpact();
    } catch (_) {}
  }

  /// Warning / Error (Validation Fail / OCR Error): Distinct double warning haptic sequence
  static Future<void> errorSequence() async {
    try {
      await HapticFeedback.vibrate();
      await Future.delayed(const Duration(milliseconds: 100));
      await HapticFeedback.vibrate();
    } catch (_) {}
  }
}
