import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

class BankHandoffScreen extends StatefulWidget {
  final String bankName;
  const BankHandoffScreen({super.key, this.bankName = 'Lloyds Bank'});

  @override
  State<BankHandoffScreen> createState() => _BankHandoffScreenState();
}

class _BankHandoffScreenState extends State<BankHandoffScreen> {
  @override
  void initState() {
    super.initState();
    // Simulate a redirect after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _showRedirectSuccess();
      }
    });
  }

  void _showRedirectSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Redirecting...'),
        content: Text('We are taking you to ${widget.bankName} to authorize the transfer.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to top-up
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Camille', style: AppTheme.headingStyle(fontSize: 18, color: AppColors.primaryTeal)),
              ),
              const Spacer(),
              _buildLoadingAnimation(),
              const SizedBox(height: 40),
              Text(
                'Connecting to bank',
                style: AppTheme.headingStyle(fontSize: 28),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Connecting to your bank...',
                style: TextStyle(color: Colors.grey[500], fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.security, color: AppColors.primaryTeal, size: 20),
                        const SizedBox(width: 12),
                        Text('Secure Connection', style: TextStyle(color: AppColors.kinInk, fontWeight: FontWeight.bold, fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Easy Bank Transfer uses Open Banking to fund your account securely. You will be redirected to ${widget.bankName} to authorize the transfer.',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14, height: 1.5),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.kinInk,
                    side: const BorderSide(color: Color(0xFFE0E0E0)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingAnimation() {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 100,
          height: 100,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryTeal.withValues(alpha: 0.2)),
            strokeWidth: 8,
            value: 1.0,
          ),
        ),
        const SizedBox(
          width: 100,
          height: 100,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryTeal),
            strokeWidth: 8,
          ),
        ),
        Icon(Icons.account_balance, color: AppColors.primaryTeal, size: 40),
      ],
    );
  }
}
