import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

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
        title: Text('Notifications', style: AppTheme.headingStyle(fontSize: 20)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRewardCard(),
            const SizedBox(height: 32),
            _buildSectionHeader('Today'),
            const SizedBox(height: 16),
            _buildNotificationItem(
              icon: Icons.call_received,
              iconColor: Colors.teal,
              title: 'Money received',
              subtitle: 'Mom sent you £50.00 • 2h ago',
            ),
            _buildNotificationItem(
              icon: Icons.security,
              iconColor: Colors.orange,
              title: 'Security alert',
              subtitle: 'New login detected near Kingston • 5h ago',
            ),
            const SizedBox(height: 32),
            _buildSectionHeader('Yesterday'),
            const SizedBox(height: 16),
            _buildNotificationItem(
              icon: Icons.error_outline,
              iconColor: Colors.red,
              title: 'Payment failed',
              subtitle: 'Starlink Subscription • £89.00 • Yesterday',
            ),
            _buildNotificationItem(
              icon: Icons.fingerprint,
              iconColor: Colors.blue,
              title: 'New card feature',
              subtitle: 'You can now lock your card with biometric ID • Yesterday',
            ),
            _buildNotificationItem(
              icon: Icons.trending_up,
              iconColor: Colors.purple,
              title: 'Interest paid',
              subtitle: 'Your Kin Vault earned £12.45 • Yesterday',
            ),
            const SizedBox(height: 40),
            Center(
              child: Text(
                'You\'ve caught up with all your updates. Notifications older than 30 days are automatically archived.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[500], fontSize: 12, height: 1.5),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryTeal,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryTeal.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.beach_access, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Island Rewards', style: AppTheme.headingStyle(color: Colors.white, fontSize: 16)),
                const SizedBox(height: 4),
                Text(
                  'You\'ve earned 5% cashback on your recent trip to Montego Bay.',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppTheme.headingStyle(fontSize: 18, color: Colors.grey[800]),
    );
  }

  Widget _buildNotificationItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTheme.headingStyle(fontSize: 15)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
