import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

class KinPlusScreen extends StatelessWidget {
  const KinPlusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Content
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 60),
                // Kin Logo Header
                Center(
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.all(48),
                    decoration: BoxDecoration(
                      color: AppColors.kinMistLight.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: Column(
                      children: [
                         Image.network(
                          'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d7/Leaf_icon_1.svg/1024px-Leaf_icon_1.svg.png',
                          width: 80,
                          color: AppColors.kinInk,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'kin',
                          style: AppTheme.headingStyle(fontSize: 48, letterSpacing: -2),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    'Send free, save more\n— with Kin+.',
                    style: AppTheme.headingStyle(fontSize: 32, height: 1.2),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                _buildFeature(
                  Icons.send_outlined,
                  'Free transfers up to J\$1,000/mo',
                  'Move money globally without the extra cost.',
                ),
                _buildFeature(
                  Icons.currency_exchange,
                  'Premium FX rate',
                  'Get the best exchange rates, anytime.',
                ),
                _buildFeature(
                  Icons.trending_up,
                  'Savings interest share',
                  'Earn more on every pound you put away.',
                ),
                _buildFeature(
                  Icons.credit_card,
                  'Bigger card limits',
                  'Enjoy higher spending and withdrawal caps.',
                ),
                
                const SizedBox(height: 40),
                
                // Pricing Card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.kinMistLight.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'J\$4.99/month',
                              style: AppTheme.dataStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'First month free',
                              style: TextStyle(color: AppColors.primaryCoral, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryTeal.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'BEST VALUE',
                            style: TextStyle(
                              color: AppColors.primaryTeal,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    'By starting your trial, you agree to the Kin+ Terms of Service. Monthly subscription automatically renews after the 1-month trial period unless cancelled.',
                    style: TextStyle(color: Colors.grey[400], fontSize: 11, height: 1.5),
                    textAlign: TextAlign.center,
                  ),
                ),
                
                const SizedBox(height: 120), // Bottom spacing for button
              ],
            ),
          ),
          
          // Sticky Bottom Button
          Positioned(
            left: 24,
            right: 24,
            bottom: 40,
            child: SizedBox(
              height: 56,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryTeal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text('Try Kin+ for Free', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ),
          
          // Close Button
          Positioned(
            top: 50,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: AppColors.kinInk),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeature(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryTeal.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primaryTeal, size: 24),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.bodyStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTheme.bodyStyle(color: Colors.grey[600], fontSize: 14, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
