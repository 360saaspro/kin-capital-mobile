import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'security_center_screen.dart';
import 'personal_details_screen.dart';
import 'bank_accounts_screen.dart';
import '../home/receiver_home_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Profile',
          style: AppTheme.headingStyle(fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: AppColors.kinInk),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildProfileHeader(),
            const SizedBox(height: 40),
            
            _buildSectionHeader('ACCOUNT'),
            _buildSettingsItem(
              Icons.person_outline,
              'Personal details',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PersonalDetailsScreen()),
                );
              },
            ),
            _buildSettingsItem(
              Icons.account_balance_outlined,
              'Bank accounts',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BankAccountsScreen()),
                );
              },
            ),
            _buildSettingsItem(
              Icons.swap_horiz,
              'Switch to Receiver Mode (Demo)',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ReceiverHomeScreen()),
                );
              },
            ),
            
            _buildSectionHeader('IDENTITY & LIMITS'),
            _buildSettingsItem(Icons.verified_user_outlined, 'KYC status', trailingText: 'Verified'),
            _buildSettingsItem(Icons.trending_up, 'Transfer limits'),
            
            _buildSectionHeader('CARDS'),
            _buildSettingsItem(Icons.credit_card, 'Manage physical and virtual cards'),
            
            _buildSectionHeader('SECURITY'),
            _buildSettingsItem(Icons.security, 'Security center', onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SecurityCenterScreen()),
              );
            }),
            _buildSettingsToggleItem(Icons.face_unlock_outlined, 'Face ID', true),
            _buildSettingsItem(Icons.lock_outline, 'Change PIN'),
            
            _buildSectionHeader('NOTIFICATIONS'),
            _buildSettingsItem(Icons.notifications_none, 'Push and email preferences'),
            
            _buildSectionHeader('HELP & SUPPORT'),
            _buildSettingsItem(Icons.help_outline, 'Help center'),
            _buildSettingsItem(Icons.chat_bubble_outline, 'Chat with us'),
            
            _buildSectionHeader('LEGAL'),
            _buildSettingsItem(Icons.description_outlined, 'Terms of service'),
            _buildSettingsItem(Icons.privacy_tip_outlined, 'Privacy policy'),
            
            const SizedBox(height: 40),
            _buildLogoutButton(),
            const SizedBox(height: 32),
            _buildLegalDisclaimer(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange, Colors.red],
                ),
                shape: BoxShape.circle,
              ),
              child: const CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                child: Text(
                  'kin',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.kinInk,
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: AppColors.primaryTeal,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.link, color: Colors.white, size: 16),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Camille Stevenson',
          style: AppTheme.headingStyle(fontSize: 24),
        ),
        const SizedBox(height: 4),
        Text(
          'Member since June 2024',
          style: AppTheme.bodyStyle(color: Colors.grey, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 32.0, bottom: 12.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.grey[500],
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsItem(IconData icon, String title, {String? trailingText, VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.kinMistLight.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryTeal,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        title: Text(
          title,
          style: AppTheme.bodyStyle(fontWeight: FontWeight.w500, fontSize: 15),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (trailingText != null)
              Text(
                trailingText,
                style: TextStyle(color: AppColors.primaryTeal, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
          ],
        ),
        onTap: onTap ?? () {},
      ),
    );
  }

  Widget _buildSettingsToggleItem(IconData icon, String title, bool value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.kinMistLight.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryTeal,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        title: Text(
          title,
          style: AppTheme.bodyStyle(fontWeight: FontWeight.w500, fontSize: 15),
        ),
        trailing: Switch.adaptive(
          value: value,
          onChanged: (v) {},
          activeThumbColor: AppColors.primaryTeal,
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return TextButton.icon(
      onPressed: () {},
      icon: const Icon(Icons.logout, color: AppColors.primaryCoral, size: 20),
      label: const Text(
        'Log out',
        style: TextStyle(
          color: AppColors.primaryCoral,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildLegalDisclaimer() {
    return Text(
      'Kin is a trading name of Kin Financial Services Co Ltd, authorised and regulated by the Financial Conduct Authority (FCA) under the Payment Services Regulations 2017 for the provision of payment services.',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 10,
        color: Colors.grey[500],
        height: 1.5,
      ),
    );
  }
}
