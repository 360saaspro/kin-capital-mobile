import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

class TransactionDetailScreen extends StatelessWidget {
  final String title;
  final String amount;
  final String time;
  final bool isNegative;

  final String? recipientGets;
  final String? exchangeRate;
  final String? fee;

  const TransactionDetailScreen({
    super.key,
    required this.title,
    required this.amount,
    required this.time,
    this.isNegative = false,
    this.recipientGets,
    this.exchangeRate,
    this.fee,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.kinInk),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text(isNegative ? 'Transfer to' : 'Transfer from', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            Text(title, style: AppTheme.headingStyle(fontSize: 18)),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.account_balance_wallet_outlined, size: 16, color: AppColors.kinInk),
                const SizedBox(width: 4),
                Text('kin', style: AppTheme.headingStyle(fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildSuccessIndicator(),
            const SizedBox(height: 32),
            Text(
              isNegative ? 'Sent! $title has\nher money.' : 'Received! $title sent\nyou money.',
              textAlign: TextAlign.center,
              style: AppTheme.headingStyle(fontSize: 26),
            ),
            const SizedBox(height: 12),
            Text(
              '"Send love, not paperwork."',
              style: TextStyle(color: Colors.grey[500], fontStyle: FontStyle.italic, fontSize: 14),
            ),
            const SizedBox(height: 40),
            _buildReceiptCard(),
            const SizedBox(height: 16),
            _buildInfoCard(Icons.calendar_today_outlined, 'DATE', time),
            const SizedBox(height: 16),
            _buildInfoCard(Icons.account_balance_wallet_outlined, isNegative ? 'FROM ACCOUNT' : 'TO ACCOUNT', 'Kin Current Account (...8821)'),
            const SizedBox(height: 40),
            _buildActionButtons(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessIndicator() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.orange, AppColors.primaryCoral],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: AppColors.primaryCoral.withValues(alpha: 0.3), blurRadius: 20, offset: Offset(0, 10))],
      ),
      child: const Icon(Icons.check, color: Colors.white, size: 50),
    );
  }

  Widget _buildReceiptCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.kinMistLight.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Text(isNegative ? 'AMOUNT SENT' : 'AMOUNT RECEIVED', style: TextStyle(fontSize: 10, color: Colors.grey[500], fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          const SizedBox(height: 12),
          Text(amount, style: AppTheme.headingStyle(fontSize: 40, color: AppColors.primaryTeal)),
          const SizedBox(height: 24),
          const Divider(height: 1, color: AppColors.kinMist),
          if (recipientGets != null) ...[
            const SizedBox(height: 24),
            _buildReceiptRow('Recipient gets', recipientGets!, isBold: true),
            const SizedBox(height: 16),
            if (exchangeRate != null) _buildReceiptRow('Exchange rate', exchangeRate!),
            if (exchangeRate != null) const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text('Kin Transfer fee', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: AppColors.primaryTeal.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4)),
                      child: Text(fee == '0' || fee == 'ZERO' || fee == null ? 'ZERO' : fee!, style: TextStyle(color: AppColors.primaryTeal, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                Text(fee == '0' || fee == 'ZERO' || fee == null ? '0.00' : fee!, style: TextStyle(color: AppColors.primaryTeal, fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        Text(value, style: TextStyle(color: AppColors.kinInk, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: 14)),
      ],
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.kinMistLight.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primaryTeal, size: 24),
          const SizedBox(height: 16),
          Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[500], fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          const SizedBox(height: 4),
          Text(value, style: AppTheme.bodyStyle(fontWeight: FontWeight.w500, fontSize: 15)),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        OutlinedButton(
          onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 56),
            side: BorderSide(color: AppColors.primaryTeal.withValues(alpha: 0.5)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: Text('Back to Dashboard', style: TextStyle(color: AppColors.primaryTeal, fontWeight: FontWeight.bold, fontSize: 16)),
        ),
      ],
    );
  }
}
