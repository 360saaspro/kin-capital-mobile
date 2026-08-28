import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/firestore_service.dart';
import '../../core/services/auth_service.dart';
import '../auth/onboarding_screen.dart';
import 'security_center_screen.dart';
import 'personal_details_screen.dart';
import 'bank_accounts_screen.dart';
import '../home/receiver_home_screen.dart';
import '../../core/services/currency_service.dart';
import '../admin/admin_panel_screen.dart';
import '../home/notifications_screen.dart';
import '../cards/cards_screen.dart';
import '../auth/forgot_password_screen.dart';
import 'support_chat_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isUploadingImage = false;

  Future<void> _handleLogout(BuildContext context) async {
    await AuthService.instance.signOut();
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
        (route) => false,
      );
    }
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery, maxWidth: 800);
      
      if (image == null) return;
      
      setState(() => _isUploadingImage = true);

      final uid = AuthService.instance.currentUid;
      final ext = image.name.split('.').last;
      final ref = FirebaseStorage.instance.ref().child('profile_pictures/$uid.$ext');
      
      await ref.putFile(File(image.path));
      final downloadUrl = await ref.getDownloadURL();
      
      await AuthService.instance.currentUser?.updatePhotoURL(downloadUrl);
      await FirestoreService.instance.updateUserProfile(uid, {'photoURL': downloadUrl});
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to upload image: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isUploadingImage = false);
      }
    }
  }

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
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: FirestoreService.instance.streamUserNotifications(AuthService.instance.currentUid),
            builder: (context, snapshot) {
              final notifications = snapshot.data ?? FirestoreService.instance.getCachedNotifications(AuthService.instance.currentUid);
              final activeNotifications = notifications.where((n) {
                final type = n['type']?.toString().toLowerCase();
                final isRead = n['isRead'] == true;
                return !isRead && (type == 'notification' || type == 'offer');
              }).toList();

              if (activeNotifications.isEmpty) {
                return const SizedBox.shrink();
              }

              return IconButton(
                icon: const Icon(Icons.notifications_active, color: AppColors.primaryTeal, size: 28),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
              );
            }
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
            
            _buildSectionHeader('PREFERENCES'),
            ValueListenableBuilder<AppCurrency>(
              valueListenable: CurrencyService.instance.currency,
              builder: (context, currency, _) {
                return _buildSettingsItem(
                  Icons.currency_exchange,
                  'Display currency',
                  trailingText: currency.code,
                  onTap: () => _showCurrencyPicker(context),
                );
              },
            ),

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

            
            _buildSectionHeader('IDENTITY & LIMITS'),
            _buildSettingsItem(Icons.verified_user_outlined, 'KYC status', trailingText: 'Verified'),

            
            _buildSectionHeader('CARDS'),
            _buildSettingsItem(
              Icons.credit_card, 
              'Manage physical and virtual cards',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CardsScreen()),
                );
              },
            ),
            
            _buildSectionHeader('SECURITY'),
            _buildSettingsItem(Icons.security, 'Security center', onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SecurityCenterScreen()),
              );
            }),
            _buildSettingsItem(
              Icons.lock_outline, 
              'Change Password',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
                );
              },
            ),
            
            _buildSectionHeader('NOTIFICATIONS'),
            _buildSettingsItem(Icons.notifications_none, 'Push and email preferences'),
            
            _buildSectionHeader('HELP & SUPPORT'),
            _buildSettingsItem(
              Icons.help_outline, 
              'Help center',
              onTap: () async {
                final Uri emailLaunchUri = Uri(
                  scheme: 'mailto',
                  path: 'support@kin-banking.com',
                );
                try {
                  await launchUrl(emailLaunchUri);
                } catch (e) {
                  // Ignore if can't launch
                }
              },
            ),
            _buildSettingsItem(
              Icons.chat_bubble_outline, 
              'Chat with us',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SupportChatScreen()),
                );
              },
            ),
            
            _buildSectionHeader('LEGAL'),
            _buildSettingsItem(Icons.description_outlined, 'Terms of service'),
            _buildSettingsItem(Icons.privacy_tip_outlined, 'Privacy policy'),
            
            const SizedBox(height: 40),
            _buildLogoutButton(context),
            const SizedBox(height: 32),
            _buildLegalDisclaimer(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _showCurrencyPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Display Currency', style: AppTheme.headingStyle(fontSize: 20)),
              const SizedBox(height: 8),
              Text('Choose how your balances are displayed', style: AppTheme.bodyStyle(color: Colors.grey)),
              const SizedBox(height: 20),
              ...AppCurrency.values.map((currency) {
                return ListTile(
                  title: Text(currency.label),
                  trailing: CurrencyService.instance.currency.value == currency
                      ? const Icon(Icons.check, color: AppColors.primaryTeal)
                      : null,
                  onTap: () {
                    CurrencyService.instance.setCurrency(currency);
                    Navigator.pop(context);
                  },
                );
              }),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader() {
    return StreamBuilder<Map<String, dynamic>?>(
      stream: FirestoreService.instance.streamUserProfile(AuthService.instance.currentUid),
      builder: (context, snapshot) {
        final profile = snapshot.data;
        final name = profile?['fullName'] ?? AuthService.instance.currentUser?.displayName ?? 'Camille Stevenson';
        final email = profile?['email'] ?? AuthService.instance.currentUser?.email ?? 'camille@kin.app';

        return Column(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                GestureDetector(
                  onTap: _pickAndUploadImage,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.orange, Colors.red],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white,
                          backgroundImage: profile?['photoURL'] != null 
                              ? NetworkImage(profile!['photoURL']) 
                              : (AuthService.instance.currentUser?.photoURL != null 
                                  ? NetworkImage(AuthService.instance.currentUser!.photoURL!) 
                                  : null),
                          child: (profile?['photoURL'] == null && AuthService.instance.currentUser?.photoURL == null) 
                            ? const Text(
                                'kin',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.kinInk,
                                ),
                              ) 
                            : null,
                        ),
                        if (_isUploadingImage)
                          const CircularProgressIndicator(color: Colors.white),
                      ],
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
              name,
              style: AppTheme.headingStyle(fontSize: 24),
            ),
            const SizedBox(height: 4),
            Text(
              email,
              style: AppTheme.bodyStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        );
      },
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
      child: Material(
        color: AppColors.kinMistLight.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
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
              if (trailingText != null) ...[
                Text(
                  trailingText,
                  style: const TextStyle(color: AppColors.primaryTeal, fontWeight: FontWeight.bold, fontSize: 12),
                ),
                const SizedBox(width: 8),
              ],
              const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
            ],
          ),
          onTap: onTap ?? () {},
        ),
      ),
    );
  }

  Widget _buildSettingsToggleItem(IconData icon, String title, bool value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: AppColors.kinMistLight.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
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
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return TextButton.icon(
      onPressed: () => _handleLogout(context),
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
