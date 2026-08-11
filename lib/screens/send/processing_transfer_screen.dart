import 'package:flutter/material.dart';
import 'dart:async';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'transfer_confirmation_screen.dart';

class ProcessingTransferScreen extends StatefulWidget {
  final String recipientName;
  final String amount;

  const ProcessingTransferScreen({
    super.key,
    required this.recipientName,
    required this.amount,
  });

  @override
  State<ProcessingTransferScreen> createState() => _ProcessingTransferScreenState();
}

class _ProcessingTransferScreenState extends State<ProcessingTransferScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Auto-navigate to confirmation after 3 seconds
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TransferConfirmationScreen(
              recipientName: widget.recipientName,
              amount: widget.amount,
            ),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            // Secure Link Chip
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F7F4),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock, color: AppColors.primaryTeal, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'SECURE LINK ACTIVE',
                      style: AppTheme.bodyStyle(
                        fontSize: 12,
                        color: AppColors.primaryTeal,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            
            // Pulsing Animation
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: List.generate(3, (index) {
                  return AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      double progress = (_pulseController.value + (index * 0.33)) % 1.0;
                      return Container(
                        width: 100 + (progress * 150),
                        height: 100 + (progress * 150),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryTeal.withValues(alpha: (1.0 - progress) * 0.2),
                        ),
                      );
                    },
                  );
                })..add(
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.primaryTeal,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryTeal.withValues(alpha: 0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.sync, color: Colors.white, size: 40),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 60),
            Text(
              'Sending your money...',
              style: AppTheme.headingStyle(fontSize: 28),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: AppTheme.bodyStyle(fontSize: 16, color: Colors.grey[700]),
                  children: [
                    const TextSpan(text: "We're securing your transfer to "),
                    TextSpan(
                      text: widget.recipientName,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.kinInk),
                    ),
                    const TextSpan(text: ". This usually takes just a few seconds."),
                  ],
                ),
              ),
            ),
            
            const Spacer(),
            
            // Transaction Info Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Recipient', style: AppTheme.bodyStyle(fontSize: 12, color: Colors.grey)),
                            const SizedBox(height: 4),
                            Text(widget.recipientName, style: AppTheme.bodyStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('Amount', style: AppTheme.bodyStyle(fontSize: 12, color: Colors.grey)),
                            const SizedBox(height: 4),
                            Text(
                              '\$${widget.amount}',
                              style: AppTheme.dataStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryTeal,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Progress bar
                    Stack(
                      children: [
                        Container(
                          height: 6,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                             return FractionallySizedBox(
                              widthFactor: 0.4 + (_pulseController.value * 0.2), // Simulate progress
                              child: Container(
                                height: 6,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryTeal,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.verified_user_outlined, color: Colors.grey[400], size: 16),
                const SizedBox(width: 8),
                Text(
                  'POWERED BY KIN SECURE',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[400],
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
