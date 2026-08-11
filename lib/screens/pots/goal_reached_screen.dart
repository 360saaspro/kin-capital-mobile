import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

class GoalReachedScreen extends StatelessWidget {
  const GoalReachedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const Icon(Icons.account_balance_wallet_outlined, color: AppColors.primaryTeal),
        title: Text('KIN', style: AppTheme.headingStyle(fontSize: 16, color: AppColors.primaryTeal, letterSpacing: 2)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.kinInk),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildCelebrationIllustration(),
            const SizedBox(height: 40),
            Text(
              'Goal Reached!',
              style: AppTheme.headingStyle(fontSize: 32),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: AppTheme.bodyStyle(color: Colors.grey[600], fontSize: 14),
                  children: [
                    const TextSpan(text: "You've saved "),
                    TextSpan(text: '£500', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.kinInk)),
                    const TextSpan(text: " for your "),
                    TextSpan(text: 'Vacation Fund', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryTeal)),
                    const TextSpan(text: " purely through round-ups."),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            _buildFinalBalanceCard(),
            const SizedBox(height: 32),
            _buildBrandedCard(),
            const SizedBox(height: 40),
            _buildActionButtons(context),
            const SizedBox(height: 40),
            _buildFooterLeaf(),
          ],
        ),
      ),
    );
  }

  Widget _buildCelebrationIllustration() {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              color: AppColors.primaryCoral.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
          ),
          Container(
            width: 140,
            height: 160,
            decoration: BoxDecoration(
              color: AppColors.primaryCoral,
              borderRadius: BorderRadius.circular(40),
              boxShadow: [BoxShadow(color: AppColors.primaryCoral.withValues(alpha: 0.3), blurRadius: 20, offset: Offset(0, 10))],
            ),
          ),
          // Coins and stars
          Positioned(top: 0, child: _buildCoin(40, Colors.amber[400]!)),
          Positioned(top: 20, left: 30, child: _buildCoin(30, Colors.amber[500]!)),
          Positioned(top: 20, right: 30, child: _buildCoin(35, Colors.amber[600]!)),
          Positioned(top: 60, child: _buildCoin(30, Colors.amber[300]!)),
          Positioned(top: 10, left: 10, child: Icon(Icons.star_border, color: AppColors.primaryTeal, size: 32)),
          Positioned(top: 40, right: 10, child: Icon(Icons.star_border, color: AppColors.primaryCoral, size: 24)),
        ],
      ),
    );
  }

  Widget _buildCoin(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4)],
      ),
    );
  }

  Widget _buildFinalBalanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: AppColors.kinMistLight.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(color: AppColors.primaryTeal, borderRadius: BorderRadius.circular(20)),
            child: const Text('Final Balance', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 16),
          Text('£500.00', style: AppTheme.headingStyle(fontSize: 40, color: AppColors.primaryTeal)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle_outline, color: Colors.grey[500], size: 16),
              const SizedBox(width: 8),
              Text('TARGET FULLY MET', style: TextStyle(color: Colors.grey[500], fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBrandedCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.kinMistLight.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.kinMist, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.account_balance_wallet, size: 40, color: AppColors.kinInk),
          const SizedBox(width: 12),
          Text('kin', style: AppTheme.headingStyle(fontSize: 40)),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryTeal,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
          child: Text('Spend from Yard Pot'),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.kinMist,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
          child: Text('Keep saving', style: TextStyle(color: AppColors.kinInk, fontWeight: FontWeight.bold, fontSize: 16)),
        ),
      ],
    );
  }

  Widget _buildFooterLeaf() {
    return Opacity(
      opacity: 0.2,
      child: Icon(Icons.eco, color: AppColors.primaryTeal, size: 80),
    );
  }
}
