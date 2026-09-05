import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/firestore_service.dart';
import '../../core/services/auth_service.dart';
import 'transaction_detail_screen.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  String _selectedFilter = 'All';

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
            leading: const Padding(
              padding: EdgeInsets.only(left: 16),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primaryTeal,
                child: Icon(Icons.person, color: Colors.white, size: 20),
              ),
            ),
            title: Text(
              'Activity',
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
                    'Activity History',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          fontSize: 28,
                        ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('All'),
                        const SizedBox(width: 8),
                        _buildFilterChip('deposit'),
                        const SizedBox(width: 8),
                        _buildFilterChip('transfer'),
                        const SizedBox(width: 8),
                        _buildFilterChip('card'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Promo Card
                  Container(
                    height: 140,
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
                            fontSize: 36,
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
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  Text(
                    'Recent Transactions',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.kinInk.withValues(alpha: 0.5),
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),

                  StreamBuilder<List<Map<String, dynamic>>>(
                    stream: FirestoreService.instance.streamUserTransactions(AuthService.instance.currentUid),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return _buildMockTransactions();
                      }

                      final items = snapshot.data ?? [];
                      final filteredItems = items.where((item) {
                        if (_selectedFilter == 'All') return true;
                        final type = (item['type'] ?? '').toString().toLowerCase();
                        return type == _selectedFilter.toLowerCase();
                      }).toList();

                      if (filteredItems.isEmpty) {
                        return _buildMockTransactions();
                      }

                      return Column(
                        children: filteredItems.map((tx) {
                          final title = tx['title'] ?? 'Transaction';
                          final amt = (tx['amount'] as num?)?.toDouble() ?? 0.0;
                          final type = tx['type'] ?? 'payment';
                          final isNegative = amt < 0;
                          final c = tx['currency'] as String? ?? (tx['metadata'] as Map<String, dynamic>?)?['currency'] as String?;
                          final sym = _getCurrencySymbol(c);
                          final amountText = isNegative ? '- $sym${amt.abs().toStringAsFixed(2)}' : '+ $sym${amt.toStringAsFixed(2)}';

                          final createdAt = tx['createdAt'] as String?;
                          final dateStr = createdAt != null ? _formatDate(createdAt) : '';
                          
                          final metadata = tx['metadata'] as Map<String, dynamic>?;
                          final recipientGets = metadata?['recipientGets'];
                          final exchangeRate = metadata?['exchangeRate'];
                          final fee = metadata?['fee'];

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildTransactionItem(
                              context,
                              title: title,
                              time: '$type • Processed',
                              amount: amountText,
                              date: dateStr,
                              recipientGets: recipientGets,
                              exchangeRate: exchangeRate,
                              fee: fee,
                              icon: isNegative ? Icons.send_outlined : Icons.add_circle_outline,
                            ),
                          );
                        }).toList(),
                      );
                    },
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

  Widget _buildMockTransactions() {
    return Column(
      children: [
        _buildTransactionItem(
          context,
          title: 'Top Up Deposit',
          time: 'Today 10:45 AM • Received',
          amount: '+ J\$250.00',
          icon: Icons.add_circle_outline,
        ),
        const SizedBox(height: 12),
        _buildTransactionItem(
          context,
          title: 'Camille Stevenson',
          time: 'Yesterday 04:20 PM • Sent',
          amount: '- J\$100.00',
          icon: Icons.swap_horiz,
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter.toLowerCase() == label.toLowerCase();
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.kinMist,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label.toUpperCase(),
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.kinInk.withValues(alpha: 0.6),
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  String _formatDate(String isoString) {
    try {
      final dt = DateTime.parse(isoString);
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      final month = months[dt.month - 1];
      final day = dt.day;
      final year = dt.year;
      
      int hour = dt.hour;
      final amPm = hour >= 12 ? 'PM' : 'AM';
      if (hour > 12) hour -= 12;
      if (hour == 0) hour = 12;
      final minute = dt.minute.toString().padLeft(2, '0');
      
      return '$month $day, $year • ${hour.toString().padLeft(2, '0')}:$minute $amPm';
    } catch (_) {
      return '';
    }
  }

  Widget _buildTransactionItem(
    BuildContext context, {
    required String title,
    required String time,
    required String amount,
    required IconData icon,
    String? date, String? recipientGets, String? exchangeRate, String? fee,
  }) {
    final isNegative = amount.contains('-');
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => TransactionDetailScreen(
            title: title,
            amount: amount,
            time: date != null && date.isNotEmpty ? date : time,
            isNegative: isNegative,
            recipientGets: recipientGets?.toString(),
            exchangeRate: exchangeRate?.toString(),
            fee: fee?.toString(),
          )),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
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
                  if (time.isNotEmpty) Text(time, style: AppTheme.bodyStyle(color: AppColors.kinInk.withValues(alpha: 0.5), fontSize: 12)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(amount, style: AppTheme.dataStyle(fontWeight: FontWeight.bold, color: isNegative ? AppColors.kinCoral : AppColors.kinTeal)),
                const Text('Success', style: TextStyle(fontSize: 10, color: AppColors.kinTeal, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getCurrencySymbol(String? c) {
    switch ((c ?? 'JMD').toUpperCase()) {
      case 'JMD': return 'J\$';
      case 'USD': return 'US\$';
      case 'GBP': return '£';
      case 'CAD': return 'CA\$';
      default: return 'J\$';
    }
  }
}
