import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'set_goal_details_screen.dart';

class SetGoalIdentityScreen extends StatefulWidget {
  const SetGoalIdentityScreen({super.key});

  @override
  State<SetGoalIdentityScreen> createState() => _SetGoalIdentityScreenState();
}

class _SetGoalIdentityScreenState extends State<SetGoalIdentityScreen> {
  String? _selectedCategory;
  final TextEditingController _nameController = TextEditingController();

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Vacation', 'icon': Icons.airplanemode_active, 'color': Color(0xFFFFE0D8)},
    {'name': 'New Phone', 'icon': Icons.smartphone, 'color': Color(0xFFD0FFFA)},
    {'name': 'Rainy Day', 'icon': Icons.umbrella_outlined, 'color': Color(0xFFFFD8D8)},
    {'name': 'Custom', 'icon': Icons.add_circle_outline, 'color': Color(0xFFF0F0F0)},
  ];

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
          'Create Yard Pot',
          style: AppTheme.headingStyle(fontSize: 20),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              radius: 18,
              backgroundImage: const NetworkImage('https://i.pravatar.cc/150?u=camille'),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildProgressBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'What are you saving for?',
                    style: AppTheme.headingStyle(fontSize: 28),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Select a category to help us tailor your Yard Pot.',
                    style: AppTheme.bodyStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 32),
                  _buildCategoryGrid(),
                  const SizedBox(height: 40),
                  Text(
                    'Goal Name',
                    style: AppTheme.bodyStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  _buildNameInput(),
                  const SizedBox(height: 40),
                  _buildBrandedQuoteCard(),
                ],
              ),
            ),
          ),
          _buildFooterActions(),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 4,
          width: MediaQuery.of(context).size.width,
          color: Colors.grey[200],
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              height: 4,
              width: MediaQuery.of(context).size.width * 0.5,
              color: AppColors.primaryTeal,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Text(
            'Step 1 of 2: Goal Identity',
            style: TextStyle(fontSize: 10, color: Colors.grey[500], fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final cat = _categories[index];
        final isSelected = _selectedCategory == cat['name'];
        return GestureDetector(
          onTap: () => setState(() => _selectedCategory = cat['name']),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : AppColors.kinMistLight.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? AppColors.primaryTeal : Colors.transparent,
                width: 2,
              ),
              boxShadow: isSelected ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)] : null,
            ),
            child: Stack(
              children: [
                if (isSelected)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Icon(Icons.check_circle, color: AppColors.primaryTeal, size: 20),
                  ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: cat['color'],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(cat['icon'], color: AppColors.kinInk, size: 24),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        cat['name'],
                        style: AppTheme.bodyStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNameInput() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.kinMistLight.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: _nameController,
        decoration: InputDecoration(
          hintText: 'e.g. My Next Upgrade',
          hintStyle: TextStyle(color: Colors.grey[400]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildBrandedQuoteCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey[400]!, Colors.grey[600]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Opacity(
            opacity: 0.1,
            child: Text(
              'kin',
              style: TextStyle(fontSize: 80, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Text(
                '"Every mickle makes a muckle. Start small, grow big."',
                style: AppTheme.bodyStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooterActions() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SetGoalDetailsScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryTeal,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Next Step'),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, color: Colors.white),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {},
            child: Text(
              'Save as Draft',
              style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
