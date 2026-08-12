import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/services/haptic_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';

/// Screen 4: Biometric Liveness (Face ID)
/// Circular camera cutout centered on #F5FBF8 background.
/// Copy: "Look straight ahead and blink."
/// Border fills up dynamically with a #10B981 (Neo-Green) gradient as liveness succeeds.
class BiometricLivenessScreen extends StatefulWidget {
  final VoidCallback onLivenessSuccess;

  const BiometricLivenessScreen({
    super.key,
    required this.onLivenessSuccess,
  });

  @override
  State<BiometricLivenessScreen> createState() => _BiometricLivenessScreenState();
}

class _BiometricLivenessScreenState extends State<BiometricLivenessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  String _promptCopy = 'Look straight ahead and blink.';
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    _startLivenessVerification();
  }

  void _startLivenessVerification() {
    KinHaptics.lightTap();
    _progressController.forward();

    Timer(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() {
          _promptCopy = 'Blink slowly...';
        });
        KinHaptics.stateChange();
      }
    });

    Timer(const Duration(milliseconds: 2400), () {
      if (mounted) {
        setState(() {
          _promptCopy = 'Face match verified!';
          _isSuccess = true;
        });
        KinHaptics.successClick();

        Timer(const Duration(milliseconds: 600), () {
          if (mounted) {
            widget.onLivenessSuccess();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kinCream, // #F5FBF8 background
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 30),
            // Header tag
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryTeal.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'STEP 2 OF 3',
                style: AppTheme.labelStyle(
                  color: AppColors.primaryTeal,
                  letterSpacing: 1.2,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              'Biometric Liveness',
              style: AppTheme.headingStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Prompt Copy: "Look straight ahead and blink."
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                _promptCopy,
                key: ValueKey(_promptCopy),
                style: AppTheme.bodyStyle(
                  fontSize: 16,
                  color: _isSuccess ? const Color(0xFF10B981) : AppColors.kinInk.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const Spacer(),

            // Circular Camera Cutout Centered with #10B981 (Neo-Green) progress border
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer Neo-Green Dynamic Progress Border Arc
                  AnimatedBuilder(
                    animation: _progressAnimation,
                    builder: (context, child) {
                      return SizedBox(
                        width: 260,
                        height: 260,
                        child: CircularProgressIndicator(
                          value: _progressAnimation.value,
                          strokeWidth: 8,
                          backgroundColor: Colors.grey[200],
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF10B981), // #10B981 (Neo-Green)
                          ),
                        ),
                      );
                    },
                  ),

                  // Circular Cutout Frame Container
                  Container(
                    width: 240,
                    height: 240,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF171D1C),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF10B981).withValues(alpha: 0.25),
                          blurRadius: 24,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Simulated camera face preview
                          Icon(
                            _isSuccess ? Icons.face_retouching_natural : Icons.face,
                            size: 140,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                          if (_isSuccess)
                            Container(
                              color: const Color(0xFF10B981).withValues(alpha: 0.2),
                              child: const Center(
                                child: Icon(
                                  Icons.check_circle_rounded,
                                  color: Color(0xFF10B981),
                                  size: 72,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Footer note
            Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.security, size: 16, color: AppColors.primaryTeal),
                  const SizedBox(width: 8),
                  Text(
                    'Bank-grade encrypted face matching',
                    style: AppTheme.labelStyle(
                      color: AppColors.kinInk.withValues(alpha: 0.5),
                      fontSize: 12,
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
