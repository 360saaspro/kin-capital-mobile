import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/branded_background.dart';
import '../activity/activity_screen.dart';
import '../activity/transaction_detail_screen.dart';
import '../pots/yard_pot_screen.dart';
import '../pots/round_up_config_screen.dart';
import '../send/recipients_screen.dart';
import 'add_money_methods_screen.dart';
import 'notifications_screen.dart';
import 'split_bill_selection_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kinMistLight,
      body: BrandedBackground(
        opacity: 0.08,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                _buildHeader(context),
                const SizedBox(height: 40),
                _buildBalance(context),
                _buildLowBalanceAlert(context),
                const SizedBox(height: 32),
                _buildMainCTA(context),
                const SizedBox(height: 32),
                _buildPotsSection(context),
                const SizedBox(height: 32),
                _buildSendAgain(context),
                const SizedBox(height: 32),
                _buildRoundUpCard(context),
                const SizedBox(height: 32),
                _buildRecentTransfersHeader(context),
                const SizedBox(height: 16),
                _buildRecentTransferItem(
                  context,
                  name: 'Waitrose & Partners',
                  time: 'Today, 10:45 AM',
                  amount: '£42.50',
                  status: 'Success',
                  avatarUrl: 'https://upload.wikimedia.org/wikipedia/en/thumb/9/93/Waitrose_Logo.svg/1200px-Waitrose_Logo.svg.png',
                  showSplit: true,
                ),
                const SizedBox(height: 12),
                _buildRecentTransferItem(
                  context,
                  name: 'Mom',
                  time: 'Sent 2 days ago',
                  amount: '£45.00',
                  status: 'Success',
                  avatarUrl: 'https://i.pravatar.cc/150?u=mom',
                  flagEmoji: '🇯🇲',
                  conversionText: '\$8,820 → JMD',
                ),
                const SizedBox(height: 12),
                _buildRecentTransferItem(
                  context,
                  name: 'Sis',
                  time: 'Sent 3 days ago',
                  amount: '£20.00',
                  status: 'Success',
                  avatarUrl: 'https://i.pravatar.cc/150?u=sis',
                  flagEmoji: '🇯🇲',
                  conversionText: '\$3,920 → JMD',
                ),
                const SizedBox(height: 40),
                Center(
                  child: Image.asset(
                    'assets/images/kin_logo.png',
                    width: 60,
                    color: AppColors.kinCoral.withValues(alpha: 0.3),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    'Your support makes home feel closer today.',
                    style: AppTheme.bodyStyle(
                      color: AppColors.kinInk.withValues(alpha: 0.5),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        mini: true,
        backgroundColor: Colors.white,
        child: const Icon(Icons.add, color: AppColors.kinInk),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=maya'),
            ),
            IconButton(
              icon: const Icon(Icons.notifications_none_outlined, color: AppColors.primary, size: 28),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Prominent Centered Logo & Name as in the "Stitch" design example
        Image.asset(
          'assets/images/kin_logo.png',
          width: 140,
          // Removed color filter to show original brand colors
        ),
        const SizedBox(height: 12),
        Text(
          'Good morning, Maya',
          style: AppTheme.bodyStyle(
            color: AppColors.kinInk.withValues(alpha: 0.6),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildBalance(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text(
            'Available to send',
            style: AppTheme.bodyStyle(
                  color: AppColors.kinInk.withValues(alpha: 0.6),
                  fontSize: 14,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '£2,450.50',
            style: AppTheme.headingStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.kinInk,
                  fontSize: 36,
                ),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddMoneyMethodsScreen()),
              );
            },
            icon: Icon(Icons.add_circle_outline, color: AppColors.primaryTeal, size: 18),
            label: Text(
              'Add money',
              style: TextStyle(color: AppColors.primaryTeal, fontWeight: FontWeight.bold),
            ),
            style: TextButton.styleFrom(
              backgroundColor: AppColors.primaryTeal.withValues(alpha: 0.05),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLowBalanceAlert(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.kinCoral.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.kinCoral.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppColors.kinCoral, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Balance is low',
                  style: TextStyle(color: AppColors.kinCoral, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  'Top up now to ensure your scheduled transfers go through.',
                  style: TextStyle(color: AppColors.kinCoral.withValues(alpha: 0.8), fontSize: 11, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right, color: AppColors.kinCoral.withValues(alpha: 0.5)),
        ],
      ),
    );
  }

  Widget _buildMainCTA(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 64,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RecipientsScreen()),
            );
          },
          borderRadius: BorderRadius.circular(20),
          splashColor: Colors.white.withValues(alpha: 0.2),
          highlightColor: Colors.white.withValues(alpha: 0.1),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.send_outlined, color: Colors.white),
              const SizedBox(width: 12),
              Text(
                'Send money home',
                style: AppTheme.headingStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPotsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Yard Pots',
          style: AppTheme.headingStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildPotCard(
                context,
                title: 'Family Vacation',
                amount: '£450.00',
                progress: 0.37,
                color: AppColors.primaryCoral,
                icon: Icons.beach_access,
              ),
              const SizedBox(width: 16),
              _buildPotCard(
                context,
                title: 'School Fees',
                amount: '£1,200.00',
                progress: 0.85,
                color: AppColors.primaryTeal,
                icon: Icons.school,
              ),
              const SizedBox(width: 16),
              _buildPotCard(
                context,
                title: 'Emergency',
                amount: '£800.00',
                progress: 0.60,
                color: Colors.orange,
                icon: Icons.emergency,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPotCard(
    BuildContext context, {
    required String title,
    required String amount,
    required double progress,
    required Color color,
    required IconData icon,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const YardPotScreen()),
        );
      },
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: AppTheme.bodyStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              amount,
              style: AppTheme.dataStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: color.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoundUpCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const RoundUpConfigScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.primaryTeal.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primaryTeal.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.sync, color: AppColors.primaryTeal, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Round-ups Active',
                    style: TextStyle(
                      color: AppColors.primaryTeal,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    'Grow your wealth with every spend.',
                    style: TextStyle(
                      color: AppColors.primaryTeal.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.primaryTeal, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSendAgain(BuildContext context) {
    final recent = [
      {'name': 'Mom', 'avatar': 'https://i.pravatar.cc/150?u=mom', 'amount': '£45.00'},
      {'name': 'Felix', 'avatar': 'https://i.pravatar.cc/150?u=felix', 'amount': '£105.00'},
      {'name': 'Elena', 'avatar': 'https://i.pravatar.cc/150?u=elena', 'amount': '£25.00'},
      {'name': 'Marcus', 'avatar': 'https://i.pravatar.cc/150?u=marcus', 'amount': '£50.00'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Send again',
              style: AppTheme.headingStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.kinInk,
                    fontSize: 18,
                  ),
            ),
            const Icon(Icons.search, color: Colors.grey, size: 20),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: recent.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.kinMistLight, width: 2),
                        ),
                        child: const Icon(Icons.add, color: AppColors.primary),
                      ),
                      const SizedBox(height: 8),
                      const Text('New', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                    ],
                  ),
                );
              }
              final r = recent[index - 1];
              return Padding(
                padding: const EdgeInsets.only(right: 20),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(r['avatar']!),
                    ),
                    const SizedBox(height: 8),
                    Text(r['name']!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    Text(r['amount']!, style: TextStyle(fontSize: 10, color: Colors.grey[500])),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecentTransfersHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Recent Activity',
          style: AppTheme.headingStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.kinInk,
                fontSize: 18,
              ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ActivityScreen()),
            );
          },
          child: Text(
            'View all',
            style: AppTheme.bodyStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentTransferItem(
    BuildContext context, {
    required String name,
    required String time,
    required String amount,
    required String status,
    required String avatarUrl,
    String? flagEmoji,
    String? conversionText,
    bool showSplit = false,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TransactionDetailScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundImage: NetworkImage(avatarUrl),
                    ),
                    if (flagEmoji != null)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Text(flagEmoji, style: const TextStyle(fontSize: 12)),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: AppTheme.bodyStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                      ),
                      Text(
                        time,
                        style: AppTheme.bodyStyle(
                              color: AppColors.kinInk.withValues(alpha: 0.5),
                              fontSize: 12,
                            ),
                      ),
                      if (conversionText != null)
                        Text(
                          conversionText,
                          style: TextStyle(
                            color: AppColors.primaryTeal,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      amount,
                      style: AppTheme.dataStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      status,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (showSplit) ...[
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Split this bill with friends',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SplitBillSelectionScreen()),
                      );
                    },
                    icon: const Icon(Icons.call_split, size: 16, color: AppColors.primaryTeal),
                    label: const Text(
                      'Split',
                      style: TextStyle(color: AppColors.primaryTeal, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
