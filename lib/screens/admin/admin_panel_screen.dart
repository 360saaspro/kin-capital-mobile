import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/auth_service.dart';
import '../auth/onboarding_screen.dart';
import 'admin_dashboard_screen.dart';
import 'admin_users_screen.dart';
import 'admin_kyc_review_screen.dart';
import 'admin_transactions_screen.dart';
import 'admin_analytics_screen.dart';
import 'admin_support_chats_screen.dart';
import 'admin_settings_screen.dart';
import 'admin_credit_screen.dart';

class AdminPanelScreen extends StatefulWidget {
  final String? entityId;
  const AdminPanelScreen({super.key, this.entityId});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;

  final List<_AdminNavItem> _navItems = const [
    _AdminNavItem(Icons.dashboard_outlined, Icons.dashboard_rounded, 'Dashboard'),
    _AdminNavItem(Icons.people_outline, Icons.people_rounded, 'Users'),
    _AdminNavItem(Icons.verified_user_outlined, Icons.verified_user_rounded, 'KYC Review'),
    _AdminNavItem(Icons.credit_score_outlined, Icons.credit_score_rounded, 'Agentic Credit'),
    _AdminNavItem(Icons.receipt_long_outlined, Icons.receipt_long_rounded, 'Transactions'),
    _AdminNavItem(Icons.bar_chart_outlined, Icons.bar_chart_rounded, 'Analytics'),
    _AdminNavItem(Icons.support_agent_outlined, Icons.support_agent_rounded, 'Support'),
    _AdminNavItem(Icons.settings_outlined, Icons.settings_rounded, 'Settings'),
  ];

  Widget _buildScreen() {
    switch (_selectedIndex) {
      case 0: return AdminDashboardScreen(entityId: widget.entityId);
      case 1: return const AdminUsersScreen();
      case 2: return const AdminKycReviewScreen();
      case 3: return const AdminCreditScreen();
      case 4: return const AdminTransactionsScreen();
      case 5: return const AdminAnalyticsScreen();
      case 6: return const AdminSupportChatsScreen();
      case 7: return AdminSettingsScreen(entityId: widget.entityId);
      default: return AdminDashboardScreen(entityId: widget.entityId);
    }
  }

  void _onNavTap(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);
  }

  Future<void> _handleLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Log Out', style: AppTheme.headingStyle(fontSize: 18)),
        content: const Text('Are you sure you want to log out of the admin panel?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.kinCoral,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );

    if (shouldLogout != true) return;

    await AuthService.instance.signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 700;
        final isExtended = constraints.maxWidth >= 1100;
        if (isWide) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: Row(
              children: [
                _buildRail(extended: isExtended),
                const VerticalDivider(thickness: 1, width: 1, color: Color(0xFFE0ECEA)),
                Expanded(child: _buildScreen()),
              ],
            ),
          );
        }
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.kinTeal,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(10),
              child: Image.asset('assets/images/kin_logo.png', fit: BoxFit.contain),
            ),
            title: Text(
              _navItems[_selectedIndex].label,
              style: AppTheme.headingStyle(fontSize: 18, color: Colors.white),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.logout_rounded, color: Colors.white),
                tooltip: 'Log Out',
                onPressed: _handleLogout,
              ),
            ],
          ),
          body: _buildScreen(),
          bottomNavigationBar: _buildMobileNav(),
        );
      },
    );
  }

  Widget _buildRail({required bool extended}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: extended ? 220 : 80,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF004D46), AppColors.kinTeal],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRailHeader(extended: extended),
              const SizedBox(height: 8),
              _buildRailLogoutButton(extended: extended),
              const SizedBox(height: 8),
              const Divider(color: Colors.white24, height: 1),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  itemCount: _navItems.length,
                  itemBuilder: (context, index) => _buildRailItem(index, extended: extended),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRailHeader({required bool extended}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(4),
            child: Image.asset('assets/images/kin_logo.png', fit: BoxFit.contain),
          ),
          if (extended) ...[
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Kin Admin', style: AppTheme.headingStyle(fontSize: 15, color: Colors.white)),
                Text('Control Centre', style: AppTheme.bodyStyle(fontSize: 11, color: Colors.white60)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRailLogoutButton({required bool extended}) {
    return GestureDetector(
      onTap: _handleLogout,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        padding: EdgeInsets.symmetric(horizontal: extended ? 14 : 0, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        ),
        child: Row(
          mainAxisAlignment: extended ? MainAxisAlignment.start : MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout_rounded, size: 18, color: Colors.white),
            if (extended) ...[
              const SizedBox(width: 10),
              Text('Log Out', style: AppTheme.bodyStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRailItem(int index, {required bool extended}) {
    final item = _navItems[index];
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onNavTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 4),
        padding: EdgeInsets.symmetric(horizontal: extended ? 14 : 0, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withValues(alpha: 0.18) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: isSelected ? Border.all(color: Colors.white.withValues(alpha: 0.25)) : null,
        ),
        child: Row(
          mainAxisAlignment: extended ? MainAxisAlignment.start : MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isSelected ? item.filledIcon : item.outlineIcon,
                key: ValueKey(isSelected),
                color: isSelected ? Colors.white : Colors.white54,
                size: 22,
              ),
            ),
            if (extended) ...[
              const SizedBox(width: 12),
              Text(
                item.label,
                style: AppTheme.bodyStyle(
                  fontSize: 14,
                  color: isSelected ? Colors.white : Colors.white60,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              if (isSelected) ...[
                const Spacer(),
                Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.kinCoralLight, shape: BoxShape.circle)),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMobileNav() {
    return SafeArea(
      child: Container(
        height: 68,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF004D46), AppColors.kinTeal],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(36),
          boxShadow: [BoxShadow(color: AppColors.kinTeal.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_navItems.length, (index) {
            final item = _navItems[index];
            final isSelected = _selectedIndex == index;
            return GestureDetector(
              onTap: () => _onNavTap(index),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding: EdgeInsets.symmetric(horizontal: isSelected ? 14 : 10, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white.withValues(alpha: 0.22) : Colors.transparent,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Icon(isSelected ? item.filledIcon : item.outlineIcon,
                    color: isSelected ? Colors.white : Colors.white54, size: 22),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _AdminNavItem {
  final IconData outlineIcon;
  final IconData filledIcon;
  final String label;
  const _AdminNavItem(this.outlineIcon, this.filledIcon, this.label);
}
