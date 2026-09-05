import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/firestore_service.dart';
import '../../core/services/auth_service.dart';
import '../auth/onboarding_screen.dart';

import 'personal_details_screen.dart';
import '../../core/services/currency_service.dart';
import '../home/notifications_screen.dart';
import '../auth/forgot_password_screen.dart';
import 'support_chat_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isUploadingImage = false;
  String? _localPhotoUrl;

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
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery, 
        maxWidth: 200, 
        maxHeight: 200, 
        imageQuality: 50,
      );
      
      if (image == null) return;
      
      setState(() => _isUploadingImage = true);

      final uid = AuthService.instance.currentUid;
      final bytes = await image.readAsBytes();
      
      String downloadUrl;
      try {
        final ext = image.name.split('.').last;
        final ref = FirebaseStorage.instance.ref().child('profile_pictures/$uid.$ext');
        await ref.putData(bytes);
        downloadUrl = await ref.getDownloadURL();
      } catch (e) {
        // Fallback to base64 data URI if Storage fails (e.g. auth/permission error in demo mode)
        final base64String = base64Encode(bytes);
        final ext = image.name.split('.').last.toLowerCase();
        downloadUrl = 'data:image/$ext;base64,$base64String';
      }
      
      try {
        await AuthService.instance.currentUser?.updatePhotoURL(downloadUrl);
      } catch (_) {}
      
      await FirestoreService.instance.setUserProfile(uid, {'photoURL': downloadUrl});
      
      if (mounted) {
        setState(() => _localPhotoUrl = downloadUrl);
      }
      AuthService.instance.fallbackPhotoUrl = downloadUrl;
      
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


            
            _buildSectionHeader('SECURITY'),

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
        final rawPhotoUrl = _localPhotoUrl ?? AuthService.instance.fallbackPhotoUrl ?? profile?['photoURL'] ?? AuthService.instance.currentUser?.photoURL;

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
                          backgroundImage: rawPhotoUrl != null 
                              ? (rawPhotoUrl.toString().startsWith('data:image')
                                  ? MemoryImage(base64Decode(rawPhotoUrl.toString().split(',').last)) as ImageProvider
                                  : NetworkImage(rawPhotoUrl))
                              : null,
                          child: rawPhotoUrl == null 
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
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.4),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(color: Colors.white),
                            ),
                          ),
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
