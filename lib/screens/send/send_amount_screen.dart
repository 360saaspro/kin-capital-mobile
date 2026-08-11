import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/swipe_to_send_button.dart';
import 'processing_transfer_screen.dart';

class SendAmountScreen extends StatefulWidget {
  final String recipientName;
  final String? avatarUrl;
  final String flagEmoji;

  const SendAmountScreen({
    super.key,
    required this.recipientName,
    this.avatarUrl,
    this.flagEmoji = '🇯🇲',
  });

  @override
  State<SendAmountScreen> createState() => _SendAmountScreenState();
}

class _SendAmountScreenState extends State<SendAmountScreen> {
  final String _amount = '100';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Send Money',
          style: AppTheme.headingStyle(fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 24),
              // Recipient Chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundImage: widget.avatarUrl != null 
                        ? NetworkImage(widget.avatarUrl!) 
                        : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.recipientName,
                      style: AppTheme.bodyStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 4),
                    Text(widget.flagEmoji),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              
              // Large Amount
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '£',
                    style: AppTheme.headingStyle(
                      fontSize: 48,
                      color: AppColors.primaryTeal,
                    ),
                  ),
                  Text(
                    _amount,
                    style: AppTheme.headingStyle(
                      fontSize: 80,
                      color: AppColors.primaryTeal,
                    ),
                  ),
                  Container(
                    width: 2,
                    height: 60,
                    color: AppColors.primaryTeal.withValues(alpha: 0.2),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              Text(
                '${widget.recipientName} gets \$19,500 JMD',
                style: AppTheme.headingStyle(fontSize: 20),
              ),
              const SizedBox(height: 8),
              Text(
                'FEE: £5.50 • RATE: 1 GBP = 195 JMD',
                style: AppTheme.bodyStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bolt, color: AppColors.primaryTeal, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'ARRIVING IN SECONDS',
                    style: AppTheme.bodyStyle(
                      fontSize: 12,
                      color: AppColors.primaryTeal,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              
              const Spacer(),
              
              // Method Selector
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.primaryTeal.withValues(alpha: 0.1)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text('Bank', style: TextStyle(fontWeight: FontWeight.bold)),
                          const Text('transfer', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text('Free of charge', style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryCoral.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'SAVES £1.75',
                              style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Text('Debit card', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700])),
                          const SizedBox(height: 4),
                          Text('£1.75 provider fee', style: TextStyle(fontSize: 10, color: Colors.grey[500])),
                          const SizedBox(height: 12),
                          const SizedBox(height: 18), // Spacer to match height
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Swipe Button
              _buildSwipeButton(),
              
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline, color: Colors.grey[400], size: 14),
                  const SizedBox(width: 4),
                  Text(
                    'SECURE END-TO-END ENCRYPTED TRANSFER',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[400],
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeButton() {
    return SwipeToSendButton(
      text: '→ Swipe to send £$_amount',
      onCompleted: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProcessingTransferScreen(
              recipientName: widget.recipientName,
              amount: _amount,
            ),
          ),
        );
      },
    );
  }
}
