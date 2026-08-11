import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../premium/kin_plus_screen.dart';
import 'spending_analytics_screen.dart';
import '../home/notifications_screen.dart';
import 'card_management_screen.dart';

import '../../core/widgets/branded_background.dart';

class CardsScreen extends StatefulWidget {
  const CardsScreen({super.key});

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  bool isFrozen = false;

  void _showCardDetails() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 32),
            Text('Card Details', style: AppTheme.headingStyle(fontSize: 24)),
            const SizedBox(height: 32),
            _buildDetailRow('Card Number', '5540 8840 1234 5678', isCopyable: true),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _buildDetailRow('Expiry', '12/28')),
                const SizedBox(width: 24),
                Expanded(child: _buildDetailRow('CVV', '•••', isSecure: true)),
              ],
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: AppTheme.buttonStyle(backgroundColor: AppColors.primaryTeal),
                child: const Text('Close'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isCopyable = false, bool isSecure = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTheme.bodyStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              value,
              style: AppTheme.dataStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: isSecure ? 4 : 0.5),
            ),
            const Spacer(),
            if (isCopyable)
              Icon(Icons.copy, color: AppColors.primaryTeal, size: 20),
            if (isSecure)
              Icon(Icons.visibility_outlined, color: AppColors.primaryTeal, size: 20),
          ],
        ),
        const SizedBox(height: 8),
        Divider(color: Colors.grey[200]),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BrandedBackground(
        opacity: 0.04,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 20,
                          backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=maya'),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Good morning',
                          style: AppTheme.headingStyle(
                            fontSize: 18,
                            color: AppColors.primaryTeal,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.analytics_outlined, color: AppColors.primaryTeal),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const SpendingAnalyticsScreen()),
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.notifications_outlined, color: AppColors.primaryTeal),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                
                // 3D Styled Card
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CardManagementScreen()),
                    );
                  },
                  child: Container(
                    height: 220,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isFrozen 
                          ? [Colors.grey[700]!, Colors.grey[800]!]
                          : [
                            const Color(0xFF1B4D4B), // Dark Teal
                            const Color(0xFF2D5A58), // Medium Teal
                            const Color(0xFF8B4513), // Subtle Brownish/Red transition
                            const Color(0xFFD35400), // Burnt Orange
                          ],
                        stops: isFrozen ? null : [0.0, 0.4, 0.8, 1.0],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        if (isFrozen)
                           const Center(
                            child: Icon(Icons.ac_unit, color: Colors.white, size: 60),
                          ),
                        // Glassmorphism effect overlay
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              color: Colors.white.withValues(alpha: 0.05),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Kin Leaf Logo
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
                                    ),
                                    child: const Icon(Icons.eco, color: Colors.amber, size: 20),
                                  ),
                                  // Chip
                                  Container(
                                    height: 35,
                                    width: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Text(
                                'CARDHOLDER',
                                style: AppTheme.bodyStyle(
                                  fontSize: 10,
                                  color: Colors.white.withValues(alpha: 0.6),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'MAYA STEPHENSON',
                                style: AppTheme.headingStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '•••• 8840',
                                    style: AppTheme.dataStyle(
                                      color: Colors.white.withValues(alpha: 0.8),
                                      fontSize: 18,
                                    ),
                                  ),
                                  // Mastercard Logo Placeholder
                                  Row(
                                    children: [
                                      Container(
                                        width: 30,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          color: Colors.red.withValues(alpha: 0.8),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      Transform.translate(
                                        offset: const Offset(-12, 0),
                                        child: Container(
                                          width: 30,
                                          height: 30,
                                          decoration: BoxDecoration(
                                            color: Colors.amber.withValues(alpha: 0.8),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Monthly Spending Section
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Monthly',
                                style: AppTheme.headingStyle(fontSize: 20),
                              ),
                              Text(
                                'Spending',
                                style: AppTheme.headingStyle(fontSize: 20),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF80F0E6).withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'July\n2026',
                              textAlign: TextAlign.center,
                              style: AppTheme.bodyStyle(
                                fontSize: 12,
                                color: AppColors.primaryTeal,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      // Donut Chart
                      Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              height: 180,
                              width: 180,
                              child: CircularProgressIndicator(
                                value: 0.75,
                                strokeWidth: 20,
                                backgroundColor: Colors.grey[200],
                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryTeal),
                              ),
                            ),
                            // Overlay segments (simplified)
                            SizedBox(
                              height: 180,
                              width: 180,
                              child: CircularProgressIndicator(
                                value: 0.4,
                                strokeWidth: 20,
                                backgroundColor: Colors.transparent,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.brown[700]!),
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Total',
                                  style: AppTheme.bodyStyle(fontSize: 14, color: Colors.grey),
                                ),
                                Text(
                                  '\$2,840',
                                  style: AppTheme.dataStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      // Spending Categories
                      Row(
                        children: [
                          _buildCategoryItem('Groceries', '\$1,136', '40%', AppColors.primaryTeal),
                          const Spacer(),
                          _buildCategoryItem('Fuel', '\$710', '25%', Colors.red[800]!),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          _buildCategoryItem('Bills', '\$568', '20%', Colors.brown[800]!),
                          const Spacer(),
                          _buildCategoryItem('Online', '\$426', '15%', const Color(0xFF1ABC9C)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const SpendingAnalyticsScreen()),
                            );
                          },
                          child: Text(
                            'View full analysis',
                            style: TextStyle(color: AppColors.primaryTeal, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Action Buttons
                _buildActionButton(
                  isFrozen ? Icons.lock_open : Icons.ac_unit,
                  isFrozen ? 'Unfreeze card' : 'Freeze card',
                  onTap: () => setState(() => isFrozen = !isFrozen),
                ),
                const SizedBox(height: 12),
                _buildActionButton(
                  Icons.visibility_outlined,
                  'Card details',
                  onTap: _showCardDetails,
                ),
                
                const SizedBox(height: 32),
                _buildKinPlusBanner(context),
                
                const SizedBox(height: 32),
                
                // Apple Pay Button
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Add to Apple Pay',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.apple, color: Colors.white, size: 24),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryItem(String title, String amount, String percent, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTheme.bodyStyle(fontSize: 12, color: Colors.grey)),
            Text(
              '\$amount (\$percent)',
              style: AppTheme.dataStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String title, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)],
          border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primaryTeal, size: 24),
            const SizedBox(width: 16),
            Text(
              title,
              style: AppTheme.bodyStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.primaryTeal,
              ),
            ),
            const Spacer(),
            Icon(Icons.chevron_right, color: Colors.grey.withValues(alpha: 0.3)),
          ],
        ),
      ),
    );
  }

  Widget _buildKinPlusBanner(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const KinPlusScreen()),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryTeal,
              const Color(0xFF0D6B60),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryTeal.withValues(alpha: 0.2),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Get Kin+',
                    style: AppTheme.headingStyle(color: Colors.white, fontSize: 18),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Unlock free transfers and\npremium FX rates.',
                    style: AppTheme.bodyStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_forward, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
