import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kinMistLight,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.kinMistLight,
            elevation: 0,
            pinned: true,
            leading: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: const CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=maya'),
              ),
            ),
            title: Text(
              'Good morning',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            actions: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_none_outlined, color: AppColors.primary),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    'Activity',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip(context, 'All', true),
                        const SizedBox(width: 8),
                        _buildFilterChip(context, 'Sent', false),
                        const SizedBox(width: 8),
                        _buildFilterChip(context, 'Received', false),
                        const SizedBox(width: 8),
                        _buildFilterChip(context, 'Spent', false),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Promo Card
                  Container(
                    height: 160,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: AppColors.cardGradient,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text(
                          'kin',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w900,
                            color: AppColors.kinDeep,
                            letterSpacing: -2,
                          ),
                        ),
                        Text(
                          'Earn 4.5% APY',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.kinDeep,
                              ),
                        ),
                        Text(
                          'On your Kin savings vault',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.kinDeep.withValues(alpha: 0.7),
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  Text(
                    'Today',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.kinInk.withValues(alpha: 0.5),
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  _buildTransactionItem(
                    context,
                    title: 'Starbucks Coffee',
                    time: '08:45 AM • Spent',
                    amount: '- \$6.50',
                    icon: Icons.coffee_outlined,
                  ),
                  const SizedBox(height: 12),
                  _buildTransactionItem(
                    context,
                    title: 'Salary Deposit',
                    time: '09:00 AM • Received',
                    amount: '+ \$4,250.00',
                    icon: Icons.account_balance_wallet_outlined,
                  ),
                  const SizedBox(height: 32),
                  
                  Text(
                    'Yesterday',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.kinInk.withValues(alpha: 0.5),
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  _buildTransactionItem(
                    context,
                    title: 'Amazon.com',
                    time: '04:20 PM • Spent',
                    amount: '- \$142.99',
                    icon: Icons.shopping_bag_outlined,
                  ),
                  const SizedBox(height: 12),
                  _buildTransactionItem(
                    context,
                    title: 'Monthly Rent',
                    time: '01:00 PM • Sent',
                    amount: '- \$2,100.00',
                    icon: Icons.home_outlined,
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : AppColors.kinMist,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : AppColors.kinInk.withValues(alpha: 0.6),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTransactionItem(
    BuildContext context, {
    required String title,
    required String time,
    required String amount,
    required IconData icon,
  }) {
    final isNegative = amount.contains('-');
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.kinMistLight,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.kinInk.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: AppTheme.dataStyle(
              color: isNegative ? AppColors.kinCoral : AppColors.primary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
