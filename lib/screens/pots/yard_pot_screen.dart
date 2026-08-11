import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'set_goal_identity_screen.dart';
import 'round_up_history_screen.dart';

class YardPotScreen extends StatelessWidget {
  const YardPotScreen({super.key});

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
        title: Text(
          'Family Pot',
          style: AppTheme.headingStyle(fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: AppColors.kinInk),
            onPressed: () {},
          ),
          const Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=maya'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMainGoalCard(context),
            const SizedBox(height: 32),
            Text(
              'Contributors',
              style: AppTheme.headingStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            _buildContributorsGrid(),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Activity',
                  style: AppTheme.headingStyle(fontSize: 18),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RoundUpHistoryScreen()),
                    );
                  },
                  child: Text('View All', style: TextStyle(color: AppColors.primaryTeal, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildActivityList(),
            const SizedBox(height: 24),
            _buildPromoCard(),
            const SizedBox(height: 40),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SetGoalIdentityScreen()),
          );
        },
        backgroundColor: AppColors.primaryTeal,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildMainGoalCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.kinMistLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'ACTIVE POT',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryTeal,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Family\nVacation Pot',
                    style: AppTheme.headingStyle(fontSize: 24),
                  ),
                ],
              ),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primaryCoral,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.beach_access, color: Colors.white, size: 32),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '£450.00',
                style: AppTheme.dataStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Text(
                '/ £1,200',
                style: AppTheme.bodyStyle(color: Colors.grey, fontSize: 16),
              ),
              const Spacer(),
              Text(
                '37% Saved',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryTeal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: 0.37,
              minHeight: 8,
              backgroundColor: AppColors.kinMistLight,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryTeal),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add_circle_outline, size: 20),
                  label: const Text('Add funds'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryTeal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.person_add_outlined, size: 20),
                  label: const Text('Invite'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryTeal,
                    side: const BorderSide(color: AppColors.primaryTeal),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContributorsGrid() {
    final contributors = [
      {'name': 'Sarah (You)', 'amount': '£210.00', 'avatar': 'https://i.pravatar.cc/150?u=sarah'},
      {'name': 'Marcus', 'amount': '£145.50', 'avatar': 'https://i.pravatar.cc/150?u=marcus'},
      {'name': 'Elena', 'amount': '£94.50', 'avatar': 'https://i.pravatar.cc/150?u=elena'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.3,
      ),
      itemCount: contributors.length + 1,
      itemBuilder: (context, index) {
        if (index == contributors.length) {
          return Container(
            decoration: BoxDecoration(
              color: AppColors.kinMistLight.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.1), style: BorderStyle.solid),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: const Icon(Icons.add, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text('Add Member', style: AppTheme.bodyStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          );
        }

        final c = contributors[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(c['avatar']!),
              ),
              const SizedBox(height: 8),
              Text(c['name']!, style: AppTheme.bodyStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              Text(c['amount']!, style: AppTheme.dataStyle(color: AppColors.primaryTeal, fontSize: 12)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActivityList() {
    final activities = [
      {'name': 'Marcus', 'type': 'Round-up', 'amount': '+£0.85', 'time': 'Today, 10:24 AM', 'icon': Icons.sync},
      {'name': 'Sarah', 'type': 'Weekly Top-up', 'amount': '+£25.00', 'time': 'Yesterday, 6:00 PM', 'icon': Icons.event_repeat},
      {'name': 'Elena', 'type': 'Contribution', 'amount': '+£15.00', 'time': '2 days ago', 'icon': Icons.payments_outlined},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: activities.length,
        separatorBuilder: (context, index) => const Divider(height: 1, indent: 64),
        itemBuilder: (context, index) {
          final a = activities[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primaryCoral.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(a['icon'] as IconData, color: AppColors.primaryCoral, size: 20),
            ),
            title: Text(
              '${a['name']} • ${a['type']}',
              style: AppTheme.bodyStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            subtitle: Text(a['time'] as String, style: AppTheme.bodyStyle(color: Colors.grey, fontSize: 12)),
            trailing: Text(
              a['amount'] as String,
              style: AppTheme.dataStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryTeal,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPromoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primaryCoral.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Save together, fly\ntogether.',
                style: AppTheme.headingStyle(fontSize: 20),
              ),
              const SizedBox(height: 12),
              Text(
                'You\'re just 4 months\naway from the tropical\nsun based on current\ntrends!',
                style: AppTheme.bodyStyle(fontSize: 14, color: AppColors.kinInk.withValues(alpha: 0.7)),
              ),
            ],
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Opacity(
              opacity: 0.2,
              child: Image.network(
                'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d7/Leaf_icon_1.svg/1024px-Leaf_icon_1.svg.png',
                width: 80,
                color: AppColors.kinInk,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
