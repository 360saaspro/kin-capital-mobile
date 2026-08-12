import 'package:flutter/material.dart';
import '../../../core/services/haptic_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/kin_bounceable.dart';

/// Error & Edge Case 1: OCR Failure (Blurry ID)
/// Soft amber warning bottom sheet with massive, one-tap "Retake Photo" button.
class OcrRetrySheet extends StatelessWidget {
  final VoidCallback onRetake;

  const OcrRetrySheet({
    super.key,
    required this.onRetake,
  });

  static Future<void> show(BuildContext context, {required VoidCallback onRetake}) {
    KinHaptics.errorSequence();
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => OcrRetrySheet(
        onRetake: () {
          Navigator.pop(context);
          onRetake();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.all(28),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Soft Amber Warning Icon (#F59E0B)
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFF59E0B),
                size: 40,
              ),
            ),
            const SizedBox(height: 20),

            // Amber Warning Copy
            Text(
              "We couldn't quite read that",
              style: AppTheme.headingStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              "Make sure the room is bright and there's no glare on the card. Keep your document flat inside the frame.",
              style: AppTheme.bodyStyle(
                color: AppColors.kinInk.withValues(alpha: 0.7),
                fontSize: 15,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),

            // Massive One-Tap "Retake Photo" Button
            KinBounceable(
              onTap: () {
                KinHaptics.lightTap();
                onRetake();
              },
              child: Container(
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primaryTeal,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryTeal.withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt_outlined, color: Colors.white),
                    SizedBox(width: 10),
                    Text(
                      'Retake Photo',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
