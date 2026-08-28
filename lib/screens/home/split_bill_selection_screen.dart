import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'split_request_sent_screen.dart';

class SplitBillSelectionScreen extends StatefulWidget {
  const SplitBillSelectionScreen({super.key});

  @override
  State<SplitBillSelectionScreen> createState() => _SplitBillSelectionScreenState();
}

class _SplitBillSelectionScreenState extends State<SplitBillSelectionScreen> {
  final List<Map<String, dynamic>> friends = [
    {'name': 'Felix Vane', 'avatar': 'https://i.pravatar.cc/150?u=felix', 'selected': true},
    {'name': 'Anya Richards', 'avatar': 'https://i.pravatar.cc/150?u=anya', 'selected': true},
    {'name': 'Marcus Hill', 'avatar': 'https://i.pravatar.cc/150?u=marcus', 'selected': true},
    {'name': 'Junior Bev', 'avatar': 'https://i.pravatar.cc/150?u=junior', 'selected': false},
    {'name': 'Elena G', 'avatar': 'https://i.pravatar.cc/150?u=elena', 'selected': false},
  ];

  double totalAmount = 42.50;

  @override
  Widget build(BuildContext context) {
    int selectedCount = friends.where((f) => f['selected']).length + 1; // +1 for "You"
    double shareAmount = totalAmount / selectedCount;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.kinInk),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Split Bill', style: AppTheme.headingStyle(fontSize: 20)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMerchantHeader(),
                  const SizedBox(height: 32),
                  Text('Select friends', style: AppTheme.headingStyle(fontSize: 18)),
                  const SizedBox(height: 16),
                  _buildFriendsList(),
                  const SizedBox(height: 32),
                  Text('Split details', style: AppTheme.headingStyle(fontSize: 18)),
                  const SizedBox(height: 16),
                  _buildSplitDetails(shareAmount),
                ],
              ),
            ),
          ),
          _buildActionFooter(selectedCount),
        ],
      ),
    );
  }

  Widget _buildMerchantHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.kinMistLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.shopping_bag_outlined, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Waitrose & Partners', style: AppTheme.headingStyle(fontSize: 16)),
                Text('24 October 2023 • 18:42', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              ],
            ),
          ),
          Text(
            'J\$${totalAmount.toStringAsFixed(2)}',
            style: AppTheme.dataStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendsList() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: friends.length,
        itemBuilder: (context, index) {
          final friend = friends[index];
          return GestureDetector(
            onTap: () {
              setState(() {
                friend['selected'] = !friend['selected'];
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 20),
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(friend['avatar']),
                        backgroundColor: Colors.grey[200],
                      ),
                      if (friend['selected'])
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppColors.primaryTeal,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.check, color: Colors.white, size: 12),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    friend['name'].split(' ')[0],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: friend['selected'] ? FontWeight.bold : FontWeight.normal,
                      color: friend['selected'] ? AppColors.kinInk : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSplitDetails(double share) {
    return Column(
      children: [
        _buildSplitRow('You', 'Your share', share, true),
        ...friends.where((f) => f['selected']).map((f) => _buildSplitRow(f['name'], 'Pending split', share, false)),
      ],
    );
  }

  Widget _buildSplitRow(String name, String status, double amount, bool isYou) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isYou ? AppColors.primaryTeal.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isYou ? Border.all(color: AppColors.primaryTeal.withValues(alpha: 0.1)) : null,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundImage: NetworkImage(isYou ? 'https://i.pravatar.cc/150?u=maya' : 'https://i.pravatar.cc/150?u=${name.toLowerCase().split(' ')[0]}'),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTheme.headingStyle(fontSize: 14)),
                Text(status, style: TextStyle(color: isYou ? AppColors.primaryTeal : Colors.grey[400], fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Text(
            'J\$${amount.toStringAsFixed(2)}',
            style: AppTheme.dataStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildActionFooter(int count) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, -5))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total split with $count people', style: TextStyle(color: Colors.grey[600])),
              Text('J\$${totalAmount.toStringAsFixed(2)}', style: AppTheme.headingStyle(fontSize: 16)),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SplitRequestSentScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: const Text('Send Split Request', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}
