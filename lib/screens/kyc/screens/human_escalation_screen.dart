import 'package:flutter/material.dart';
import '../../../core/services/haptic_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/kin_bounceable.dart';
import '../../../services/api_service.dart';

/// Error & Edge Case 2: Sanctions / AML Flag (Human Escalation)
/// Graceful fallback screen when compliance agent flags an application.
/// Copy: "Your application is under review. Our team is verifying your details to keep the network secure."
/// Logs audit trail entry via ApiService.audit.
class HumanEscalationScreen extends StatefulWidget {
  final String entityId;
  final VoidCallback onReturnHome;

  const HumanEscalationScreen({
    super.key,
    required this.entityId,
    required this.onReturnHome,
  });

  @override
  State<HumanEscalationScreen> createState() => _HumanEscalationScreenState();
}

class _HumanEscalationScreenState extends State<HumanEscalationScreen> {
  final _api = ApiService();

  @override
  void initState() {
    super.initState();
    _logAuditTrail();
  }

  Future<void> _logAuditTrail() async {
    try {
      await _api.audit(widget.entityId);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kinCream,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),

              // Neutral Shield Icon
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: AppColors.primaryTeal.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  color: AppColors.primaryTeal,
                  size: 48,
                ),
              ),
              const SizedBox(height: 28),

              // Graceful Copy
              Text(
                'Application Under Review',
                style: AppTheme.headingStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.kinInk,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),
              Text(
                'Your application is under review. Our team is verifying your details to keep the network secure.',
                style: AppTheme.bodyStyle(
                  fontSize: 16,
                  color: AppColors.kinInk.withValues(alpha: 0.7),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Status Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.primaryTeal, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Most reviews are completed within 24 hours. We will notify you by SMS & email.',
                        style: AppTheme.bodyStyle(fontSize: 13, color: Colors.grey[700]),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Return Button
              KinBounceable(
                onTap: () {
                  KinHaptics.lightTap();
                  widget.onReturnHome();
                },
                child: Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primaryTeal,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text(
                      'Back to Home',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
