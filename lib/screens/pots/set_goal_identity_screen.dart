import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/branded_background.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/firestore_service.dart';
import 'set_goal_details_screen.dart';

class SetGoalIdentityScreen extends StatefulWidget {
  const SetGoalIdentityScreen({super.key});

  @override
  State<SetGoalIdentityScreen> createState() => _SetGoalIdentityScreenState();
}

class _SetGoalIdentityScreenState extends State<SetGoalIdentityScreen> {
  int _selectedCategoryIndex = 0;
  final TextEditingController _nameController = TextEditingController();
  bool _hasUserEditedName = false;

  final List<Map<String, dynamic>> _categories = [
    {
      'name': 'Family Support',
      'subtitle': 'Remittance & care',
      'icon': Icons.favorite_rounded,
      'color': AppColors.kinCoral,
      'defaultTitle': 'Family Support',
    },
    {
      'name': 'Island Vacation',
      'subtitle': 'Flights, hotel & fun',
      'icon': Icons.beach_access_rounded,
      'color': AppColors.primaryTeal,
      'defaultTitle': 'Jamaica Holiday',
    },
    {
      'name': 'Emergency Buffer',
      'subtitle': 'Peace of mind cushion',
      'icon': Icons.shield_outlined,
      'color': const Color(0xFF2563EB),
      'defaultTitle': 'Emergency Cushion',
    },
    {
      'name': 'School & Growth',
      'subtitle': 'Tuition & education',
      'icon': Icons.school_rounded,
      'color': const Color(0xFF7C3AED),
      'defaultTitle': 'Tuition Fund',
    },
    {
      'name': 'Home & Tech',
      'subtitle': 'Repairs & upgrades',
      'icon': Icons.home_work_outlined,
      'color': const Color(0xFFD97706),
      'defaultTitle': 'Home Upgrade',
    },
    {
      'name': 'Custom Dream',
      'subtitle': 'Any personal goal',
      'icon': Icons.stars_rounded,
      'color': const Color(0xFF059669),
      'defaultTitle': 'My Yard Pot',
    },
  ];

  final List<String> _quickSuggestions = [
    'Family Support',
    'Emergency Cushion',
    'Flight Home',
    'School Tuition',
    'New Laptop',
    'House Deposit',
  ];

  @override
  void initState() {
    super.initState();
    _nameController.text = _categories[_selectedCategoryIndex]['defaultTitle'];
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _onCategorySelected(int index) {
    setState(() {
      _selectedCategoryIndex = index;
      if (!_hasUserEditedName) {
        _nameController.text = _categories[index]['defaultTitle'];
      }
    });
  }

  void _onSuggestionTapped(String suggestion) {
    setState(() {
      _hasUserEditedName = true;
      _nameController.text = suggestion;
    });
  }

  void _proceedToStep2() {
    final title = _nameController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a name for your Yard Pot.'),
          backgroundColor: AppColors.kinCoral,
        ),
      );
      return;
    }

    final selected = _categories[_selectedCategoryIndex];
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SetGoalDetailsScreen(
          category: selected['name'] as String,
          potTitle: title,
          iconData: selected['icon'] as IconData,
          accentColor: selected['color'] as Color,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = AuthService.instance.currentUid;

    return Scaffold(
      backgroundColor: AppColors.kinMistLight,
      body: BrandedBackground(
        opacity: 0.02,
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context, uid),
              _buildProgressBar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'What are you saving for?',
                        style: AppTheme.headingStyle(fontSize: 26, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Choose a category and give your Yard Pot a name to start building.',
                        style: AppTheme.bodyStyle(
                          color: AppColors.kinInk.withValues(alpha: 0.6),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'SELECT CATEGORY',
                        style: AppTheme.labelStyle(
                          color: AppColors.kinInk.withValues(alpha: 0.5),
                          fontSize: 11,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildCategoryGrid(),
                      const SizedBox(height: 28),
                      Text(
                        'POT NAME',
                        style: AppTheme.labelStyle(
                          color: AppColors.kinInk.withValues(alpha: 0.5),
                          fontSize: 11,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildNameInput(),
                      const SizedBox(height: 12),
                      _buildSuggestionChips(),
                      const SizedBox(height: 28),
                      _buildBrandedQuoteCard(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              _buildBottomAction(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, String uid) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.kinInk),
            onPressed: () => Navigator.pop(context),
          ),
          Text(
            'Create Yard Pot',
            style: AppTheme.headingStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          StreamBuilder<Map<String, dynamic>?>(
            stream: FirestoreService.instance.streamUserProfile(uid),
            builder: (context, snapshot) {
              final profile = snapshot.data ?? FirestoreService.instance.getCachedUser(uid);
              final rawName = (profile?['fullName'] as String?)?.isNotEmpty == true
                  ? profile!['fullName'] as String
                  : (AuthService.instance.currentUser?.displayName?.isNotEmpty == true
                      ? AuthService.instance.currentUser!.displayName!
                      : '');
              final initial = rawName.trim().isNotEmpty ? rawName.trim()[0].toUpperCase() : 'K';

              return CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primaryTeal.withValues(alpha: 0.15),
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: AppColors.primaryTeal,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppColors.primaryTeal,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppColors.kinInk.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Step 1: Goal Identity',
                style: AppTheme.bodyStyle(
                  color: AppColors.primaryTeal,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              Text(
                'Step 2: Target & Boosters',
                style: AppTheme.bodyStyle(
                  color: AppColors.kinInk.withValues(alpha: 0.4),
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 1.25,
      ),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final cat = _categories[index];
        final isSelected = _selectedCategoryIndex == index;
        final Color catColor = cat['color'] as Color;

        return GestureDetector(
          onTap: () => _onCategorySelected(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? AppColors.primaryTeal : AppColors.kinInk.withValues(alpha: 0.08),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? AppColors.primaryTeal.withValues(alpha: 0.12)
                      : Colors.black.withValues(alpha: 0.02),
                  blurRadius: isSelected ? 12 : 6,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                if (isSelected)
                  const Positioned(
                    top: 0,
                    right: 0,
                    child: Icon(Icons.check_circle_rounded, color: AppColors.primaryTeal, size: 20),
                  ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: catColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(cat['icon'] as IconData, color: catColor, size: 22),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      cat['name'] as String,
                      style: AppTheme.headingStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? AppColors.kinInk : AppColors.kinInk.withValues(alpha: 0.85),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      cat['subtitle'] as String,
                      style: AppTheme.bodyStyle(
                        fontSize: 11,
                        color: AppColors.kinInk.withValues(alpha: 0.5),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryTeal.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryTeal.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _nameController,
        onChanged: (_) => setState(() => _hasUserEditedName = true),
        style: AppTheme.headingStyle(fontSize: 16, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          hintText: 'e.g. Family Vacation or Emergency Pot',
          hintStyle: TextStyle(color: AppColors.kinInk.withValues(alpha: 0.35), fontSize: 14),
          prefixIcon: const Icon(Icons.edit_outlined, color: AppColors.primaryTeal, size: 20),
          suffixIcon: _nameController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: AppColors.kinInk.withValues(alpha: 0.4), size: 18),
                  onPressed: () {
                    setState(() {
                      _nameController.clear();
                      _hasUserEditedName = true;
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildSuggestionChips() {
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _quickSuggestions.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final s = _quickSuggestions[index];
          final isCurrent = _nameController.text == s;

          return GestureDetector(
            onTap: () => _onSuggestionTapped(s),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isCurrent ? AppColors.primaryTeal.withValues(alpha: 0.12) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isCurrent ? AppColors.primaryTeal : AppColors.kinInk.withValues(alpha: 0.08),
                ),
              ),
              child: Text(
                s,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                  color: isCurrent ? AppColors.primaryTeal : AppColors.kinInk.withValues(alpha: 0.7),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBrandedQuoteCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryTeal,
            AppColors.primaryTeal.withValues(alpha: 0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryTeal.withValues(alpha: 0.25),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            bottom: -15,
            child: Opacity(
              opacity: 0.12,
              child: Image.asset(
                'assets/images/kin_logo.png',
                width: 100,
                color: Colors.white,
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.format_quote_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '"Every mickle makes a muckle. Start small, grow big."',
                      style: AppTheme.bodyStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '— Jamaican Proverb',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _proceedToStep2,
                borderRadius: BorderRadius.circular(18),
                splashColor: Colors.white.withValues(alpha: 0.2),
                highlightColor: Colors.white.withValues(alpha: 0.1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Continue to Step 2',
                      style: AppTheme.headingStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
