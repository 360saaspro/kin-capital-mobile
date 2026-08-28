import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

class RoundUpHistoryScreen extends StatelessWidget {
  const RoundUpHistoryScreen({super.key});

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
        title: Text('Round-up History', style: AppTheme.headingStyle(fontSize: 20)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWeeklySummary(),
            const SizedBox(height: 32),
            _buildSectionHeader('Today'),
            const SizedBox(height: 16),
            _buildHistoryItem(
              merchant: 'Island Groceries',
              total: 'J\$42.50',
              roundUp: 'J\$0.50',
              icon: Icons.shopping_cart_outlined,
            ),
            _buildHistoryItem(
              merchant: 'Blue Mountain Brew',
              total: 'J\$3.20',
              roundUp: 'J\$0.80',
              icon: Icons.coffee_outlined,
            ),
            const SizedBox(height: 32),
            _buildSectionHeader('Yesterday'),
            const SizedBox(height: 16),
            _buildHistoryItem(
              merchant: 'Kingston Taxi Service',
              total: 'J\$18.05',
              roundUp: 'J\$0.95',
              icon: Icons.local_taxi_outlined,
            ),
            _buildHistoryItem(
              merchant: 'Jerky\'s Grill',
              total: 'J\$27.40',
              roundUp: 'J\$0.60',
              icon: Icons.restaurant_outlined,
            ),
            _buildHistoryItem(
              merchant: 'Utility Bill Pay',
              total: 'J\$105.15',
              roundUp: 'J\$0.85',
              icon: Icons.receipt_long_outlined,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklySummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryTeal, const Color(0xFF0D6B60)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryTeal.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Saved this week',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            'J\$12.40',
            style: AppTheme.headingStyle(color: Colors.white, fontSize: 36),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.trending_up, color: Colors.white, size: 16),
                const SizedBox(width: 4),
                Text(
                  '15% more than last week',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12, fontWeight: FontWeight.bold),
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

  Widget _buildHistoryItem({
    required String merchant,
    required String total,
    required String roundUp,
    required IconData icon,
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
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.kinInk, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(merchant, style: AppTheme.headingStyle(fontSize: 15)),
                Text('Transaction: $total', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '+$roundUp',
                style: AppTheme.dataStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal[600],
                ),
              ),
              Text(
                'Round-up',
                style: TextStyle(color: Colors.grey[400], fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
