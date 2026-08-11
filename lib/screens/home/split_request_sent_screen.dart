import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'share_request_link_screen.dart';

class SplitRequestSentScreen extends StatelessWidget {
  const SplitRequestSentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              _buildCelebratoryIcon(),
              const SizedBox(height: 40),
              Text(
                'Requests sent!',
                style: AppTheme.headingStyle(fontSize: 28),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'We\'ve asked Felix, Anya, and Marcus for their shares of the Waitrose bill.',
                style: TextStyle(color: Colors.grey[600], fontSize: 16, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primaryTeal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Split equally among 3 people',
                  style: TextStyle(color: AppColors.primaryTeal, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
              const Spacer(),
              _buildActionButton(
                context,
                title: 'Share Request Link',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ShareRequestLinkScreen()),
                  );
                },
                isPrimary: true,
              ),
              const SizedBox(height: 16),
              _buildActionButton(
                context,
                title: 'Back to Home',
                onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                isPrimary: false,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCelebratoryIcon() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.primaryTeal.withValues(alpha: 0.05),
            shape: BoxShape.circle,
          ),
        ),
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            color: AppColors.primaryTeal.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
        ),
        Container(
          width: 60,
          height: 60,
          decoration: const BoxDecoration(
            color: AppColors.primaryTeal,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, color: Colors.white, size: 32),
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, {required String title, required VoidCallback onPressed, required bool isPrimary}) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? AppColors.primary : Colors.transparent,
          foregroundColor: isPrimary ? Colors.white : AppColors.kinInk,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: isPrimary ? BorderSide.none : const BorderSide(color: Color(0xFFE0E0E0)),
          ),
        ),
        child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }
}
