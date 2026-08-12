import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';

/// Animated top progress bar for the 5-step KYC onboarding flow.
/// Smoothly animates filling up from Step 1 (20%) to Step 5 (100%).
class KycProgressBar extends StatelessWidget {
  final int currentStep; // 1 to 5
  final int totalSteps;  // default 5

  const KycProgressBar({
    super.key,
    required this.currentStep,
    this.totalSteps = 5,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (currentStep / totalSteps).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'STEP $currentStep OF $totalSteps',
                style: AppTheme.labelStyle(
                  color: AppColors.primaryTeal,
                  letterSpacing: 1.2,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}% COMPLETED',
                style: AppTheme.labelStyle(
                  color: AppColors.kinInk.withValues(alpha: 0.5),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              tween: Tween<double>(begin: 0.0, end: progress),
              builder: (context, value, child) {
                return LinearProgressIndicator(
                  value: value,
                  minHeight: 6,
                  backgroundColor: AppColors.primaryTeal.withValues(alpha: 0.12),
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryTeal),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
