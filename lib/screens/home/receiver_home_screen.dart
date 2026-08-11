import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

class ReceiverHomeScreen extends StatelessWidget {
  const ReceiverHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildHeader(),
              const SizedBox(height: 32),
              _buildBalanceCard(),
              const SizedBox(height: 32),
              _buildQuickActions(),
              const SizedBox(height: 32),
              _buildPromoCards(),
              const SizedBox(height: 32),
              _buildRecentActivity(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hi Mom', style: AppTheme.headingStyle(fontSize: 24)),
            const SizedBox(height: 4),
            Text('Good morning', style: TextStyle(color: Colors.grey[500], fontSize: 14)),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.notifications_none_outlined, color: AppColors.primaryTeal, size: 28),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF00BFA5), // Vibrant Mint
            Color(0xFF00796B), // Deep Teal
          ],
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00BFA5).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Balance',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            '\$19,500',
            style: AppTheme.headingStyle(color: Colors.white, fontSize: 40),
          ),
          const SizedBox(height: 4),
          Text(
            'JMD',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              const Icon(Icons.credit_card, color: Colors.white, size: 16),
              const SizedBox(width: 8),
              Text(
                'Mom Stephenson',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildActionItem(Icons.payments_outlined, 'Withdraw'),
        _buildActionItem(Icons.receipt_long_outlined, 'Pay Bills'),
        _buildActionItem(Icons.qr_code_scanner, 'Scan & Pay'),
        _buildActionItem(Icons.more_horiz, 'More'),
      ],
    );
  }

  Widget _buildActionItem(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
          ),
          child: Icon(icon, color: AppColors.primaryTeal, size: 28),
        ),
        const SizedBox(height: 8),
        Text(label, style: AppTheme.bodyStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildPromoCards() {
    return Column(
      children: [
        _buildPromoItem(
          icon: Icons.local_shipping_outlined,
          color: Colors.orange[50]!,
          iconColor: Colors.orange,
          title: 'Your physical card is on its way',
          subtitle: 'Track delivery in real-time',
        ),
        const SizedBox(height: 16),
        _buildPromoItem(
          icon: Icons.security_outlined,
          color: Colors.blue[50]!,
          iconColor: Colors.blue,
          title: 'Secure your future',
          subtitle: 'Set up your first Savings Pot',
        ),
      ],
    );
  }

  Widget _buildPromoItem({
    required IconData icon,
    required Color color,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTheme.headingStyle(fontSize: 14)),
                Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.grey[400]),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recent activity', style: AppTheme.headingStyle(fontSize: 18)),
            Text('See all', style: TextStyle(color: AppColors.primaryTeal, fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 16),
        _buildActivityItem(
          name: 'From John',
          amount: '+\$2,500',
          time: 'Just now • Transfer',
          isReceived: true,
        ),
        _buildActivityItem(
          name: 'Kingston Supermarket',
          amount: '-\$1,200',
          time: 'Yesterday • Groceries',
          isReceived: false,
        ),
      ],
    );
  }

  Widget _buildActivityItem({
    required String name,
    required String amount,
    required String time,
    required bool isReceived,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isReceived ? Colors.teal[50] : Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              isReceived ? Icons.call_received : Icons.shopping_bag_outlined,
              color: isReceived ? Colors.teal : Colors.grey[600],
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTheme.headingStyle(fontSize: 15)),
                Text(time, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              ],
            ),
          ),
          Text(
            amount,
            style: AppTheme.dataStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isReceived ? Colors.teal : AppColors.kinInk,
            ),
          ),
        ],
      ),
    );
  }
}
