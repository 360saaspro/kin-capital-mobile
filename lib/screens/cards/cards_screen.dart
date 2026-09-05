import 'package:flutter/material.dart';
import 'dart:convert';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../premium/kin_plus_screen.dart';
import 'spending_analytics_screen.dart';
import '../home/notifications_screen.dart';
import 'card_management_screen.dart';
import '../../core/services/firestore_service.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/currency_service.dart';
import '../profile/profile_screen.dart';
import '../../core/widgets/branded_background.dart';
class CardsScreen extends StatefulWidget {
  const CardsScreen({super.key});

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  bool isFrozen = false;

  @override
  void initState() {
    super.initState();
    AuthService.instance.ensureAccountDetailsGenerated();
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'morning';
    if (hour < 17) return 'afternoon';
    return 'evening';
  }

  String _monthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    if (month >= 1 && month <= 12) return months[month - 1];
    return '';
  }

  void _showCardDetails(String cardNumber, String expiry, String cvv) {
    bool isCvvVisible = false;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: const EdgeInsets.all(32),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 32),
                Text('Card Details', style: AppTheme.headingStyle(fontSize: 24)),
                const SizedBox(height: 32),
                _buildDetailRow('Card Number', cardNumber, isCopyable: true),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(child: _buildDetailRow('Expiry', expiry)),
                    const SizedBox(width: 24),
                    Expanded(child: _buildDetailRow(
                      'CVV', 
                      isCvvVisible ? cvv : '•••', 
                      isSecure: true,
                      onSecureTap: () {
                        setModalState(() {
                          isCvvVisible = !isCvvVisible;
                        });
                      },
                      isCvvVisible: isCvvVisible,
                    )),
                  ],
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: AppTheme.buttonStyle(backgroundColor: AppColors.primaryTeal),
                    child: const Text('Close'),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isCopyable = false, bool isSecure = false, VoidCallback? onSecureTap, bool? isCvvVisible}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTheme.bodyStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              value,
              style: AppTheme.dataStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: isSecure ? 4 : 0.5),
            ),
            const Spacer(),
            if (isCopyable)
              Icon(Icons.copy, color: AppColors.primaryTeal, size: 20),
            if (isSecure)
              GestureDetector(
                onTap: onSecureTap,
                child: Icon(
                  isCvvVisible == true ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: AppColors.primaryTeal, 
                  size: 20,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Divider(color: Colors.grey[200]),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BrandedBackground(
        opacity: 0.04,
        child: SafeArea(
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: FirestoreService.instance.streamUserCards(AuthService.instance.currentUid),
            builder: (context, snapshot) {
              final cards = snapshot.data ?? [];
              final card = cards.isNotEmpty ? cards.first : null;
              final cardNumber = card?['cardNumber'] as String? ?? '5540 8840 1234 5678';
              final cardExpiry = card?['expiry'] as String? ?? '12/28';
              final cardCvv = card?['cvv'] as String? ?? '123';
              final last4 = cardNumber.length >= 4 ? cardNumber.substring(cardNumber.length - 4) : '8840';

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                const SizedBox(height: 16),
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        StreamBuilder<Map<String, dynamic>?>(
                          stream: FirestoreService.instance.streamUserProfile(AuthService.instance.currentUid),
                          builder: (context, snapshot) {
                            final profile = snapshot.data ?? FirestoreService.instance.getCachedUser(AuthService.instance.currentUid);
                            final rawPhotoUrl = AuthService.instance.fallbackPhotoUrl ?? profile?['photoURL'] ?? AuthService.instance.currentUser?.photoURL;
                            
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                                );
                              },
                              child: CircleAvatar(
                                radius: 20,
                                backgroundColor: AppColors.primaryTeal,
                                backgroundImage: rawPhotoUrl != null 
                                    ? (rawPhotoUrl.toString().startsWith('data:image')
                                        ? MemoryImage(base64Decode(rawPhotoUrl.toString().split(',').last)) as ImageProvider
                                        : NetworkImage(rawPhotoUrl))
                                    : null,
                                child: rawPhotoUrl == null ? const Icon(Icons.person, color: Colors.white, size: 20) : null,
                              ),
                            );
                          }
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Good ${_greeting()}',
                          style: AppTheme.headingStyle(
                            fontSize: 18,
                            color: AppColors.primaryTeal,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
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
                  ],
                ),
                const SizedBox(height: 32),
                
                // 3D Styled Card
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CardManagementScreen()),
                    );
                  },
                  child: Container(
                    height: 220,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isFrozen 
                          ? [Colors.grey[700]!, Colors.grey[800]!]
                          : [
                            const Color(0xFF1B4D4B), // Dark Teal
                            const Color(0xFF2D5A58), // Medium Teal
                            const Color(0xFF8B4513), // Subtle Brownish/Red transition
                            const Color(0xFFD35400), // Burnt Orange
                          ],
                        stops: isFrozen ? null : [0.0, 0.4, 0.8, 1.0],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        if (isFrozen)
                           const Center(
                            child: Icon(Icons.ac_unit, color: Colors.white, size: 60),
                          ),
                        // Glassmorphism effect overlay with realistic shine
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white.withValues(alpha: 0.25),
                                  Colors.white.withValues(alpha: 0.0),
                                  Colors.white.withValues(alpha: 0.05),
                                ],
                                stops: const [0.0, 0.4, 1.0],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Kin Logo
                                    Image.asset(
                                      'assets/images/kin_logo.png',
                                      width: 60,
                                      height: 60,
                                      color: Colors.white, // assuming the logo works well as a white overlay
                                    ),
                                    Row(
                                      children: [
                                        // Contactless Icon
                                        const RotatedBox(
                                          quarterTurns: 1,
                                          child: Icon(Icons.wifi, color: Colors.white70, size: 28),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              const Spacer(),
                              Text(
                                'CARDHOLDER',
                                style: AppTheme.bodyStyle(
                                  fontSize: 10,
                                  color: Colors.white.withValues(alpha: 0.6),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                (AuthService.instance.currentUser?.displayName ?? 'CARDHOLDER').toUpperCase(),
                                style: AppTheme.headingStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '•••• $last4',
                                    style: AppTheme.dataStyle(
                                      color: Colors.white.withValues(alpha: 0.8),
                                      fontSize: 18,
                                    ),
                                  ),
                                  // Mastercard Logo Placeholder
                                  Row(
                                    children: [
                                      Container(
                                        width: 30,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          color: Colors.red.withValues(alpha: 0.8),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      Transform.translate(
                                        offset: const Offset(-12, 0),
                                        child: Container(
                                          width: 30,
                                          height: 30,
                                          decoration: BoxDecoration(
                                            color: Colors.amber.withValues(alpha: 0.8),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Action Buttons
                _buildActionButton(
                  isFrozen ? Icons.lock_open : Icons.ac_unit,
                  isFrozen ? 'Unfreeze card' : 'Freeze card',
                  onTap: () => setState(() => isFrozen = !isFrozen),
                ),
                const SizedBox(height: 12),
                _buildActionButton(
                  Icons.visibility_outlined,
                  'Card details',
                  onTap: () => _showCardDetails(cardNumber, cardExpiry, cardCvv),
                ),
                
                const SizedBox(height: 32),

                // Account Information Section
                StreamBuilder<Map<String, dynamic>?>(
                  stream: FirestoreService.instance.streamUserProfile(AuthService.instance.currentUid),
                  builder: (context, profileSnapshot) {
                    final profile = profileSnapshot.data ?? FirestoreService.instance.getCachedUser(AuthService.instance.currentUid);
                    final accountNumber = profile?['accountNumber'] as String? ?? 'Pending...';
                    final transitBankCode = profile?['transitBankCode'] as String? ?? 'Pending...';
                    return Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.account_balance, color: AppColors.primaryTeal),
                              const SizedBox(width: 12),
                              Text('Account Details', style: AppTheme.headingStyle(fontSize: 18)),
                            ],
                          ),
                          const SizedBox(height: 24),
                          _buildAccountDetailRow('Account Number', accountNumber),
                          const SizedBox(height: 16),
                          _buildAccountDetailRow('Transit/Bank Code', transitBankCode),
                        ],
                      ),
                    );
                  }
                ),

                const SizedBox(height: 32),
                
                // Apple Pay / Google Wallet Button
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        Theme.of(context).platform == TargetPlatform.iOS ? 'Add to Apple Pay' : 'Add to Google Wallet',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Theme.of(context).platform == TargetPlatform.iOS ? Icons.apple : Icons.wallet_outlined, color: Colors.white, size: 24),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Monthly Spending Section
                StreamBuilder<List<Map<String, dynamic>>>(
                  stream: FirestoreService.instance.streamUserTransactions(AuthService.instance.currentUid),
                  builder: (context, snapshot) {
                    final allTransactions = snapshot.data ?? FirestoreService.instance.getCachedTransactions(AuthService.instance.currentUid);
                    final now = DateTime.now();
                    
                    final monthlyTransactions = allTransactions.where((t) {
                      final createdAtStr = t['createdAt'] as String?;
                      if (createdAtStr == null) return false;
                      try {
                        final date = DateTime.parse(createdAtStr);
                        return date.month == now.month && date.year == now.year;
                      } catch (_) {
                        return false;
                      }
                    }).toList();

                    double totalSpent = 0;
                    Map<String, double> categorySums = {};
                    for (var t in monthlyTransactions) {
                      if (t['type'] == 'withdrawal' || t['type'] == 'payment' || t['type'] == 'expense' || t['type'] == 'transfer') {
                        final amount = (t['amount'] as num?)?.toDouble() ?? 0.0;
                        final cat = (t['title'] as String?) ?? 'Other';
                        totalSpent += amount;
                        categorySums[cat] = (categorySums[cat] ?? 0.0) + amount;
                      }
                    }
                    
                    final sortedCategories = categorySums.entries.toList()
                      ..sort((a, b) => b.value.compareTo(a.value));
                      
                    final top2 = sortedCategories.take(2).toList();
                    final next2 = sortedCategories.skip(2).take(2).toList();
                    
                    return Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
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
                                  Text(
                                    'Monthly',
                                    style: AppTheme.headingStyle(fontSize: 20),
                                  ),
                                  Text(
                                    'Spending',
                                    style: AppTheme.headingStyle(fontSize: 20),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF80F0E6).withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${_monthName(now.month)}\n${now.year}',
                                  textAlign: TextAlign.center,
                                  style: AppTheme.bodyStyle(
                                    fontSize: 12,
                                    color: AppColors.primaryTeal,
                                    fontWeight: FontWeight.bold,
                                    height: 1.2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          // Donut Chart
                          Center(
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  height: 180,
                                  width: 180,
                                  child: CircularProgressIndicator(
                                    value: 1.0,
                                    strokeWidth: 20,
                                    backgroundColor: Colors.grey[200],
                                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryTeal),
                                  ),
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Total',
                                      style: AppTheme.bodyStyle(fontSize: 14, color: Colors.grey),
                                    ),
                                    Text(
                                      CurrencyService.instance.format(totalSpent),
                                      style: AppTheme.dataStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 40),
                          // Spending Categories
                          if (top2.isNotEmpty)
                            Row(
                              children: [
                                Expanded(child: _buildCategoryItem(top2[0].key, CurrencyService.instance.format(top2[0].value), '${totalSpent > 0 ? (top2[0].value/totalSpent*100).toStringAsFixed(0) : 0}%', AppColors.primaryTeal)),
                                const SizedBox(width: 16),
                                if (top2.length > 1)
                                  Expanded(child: _buildCategoryItem(top2[1].key, CurrencyService.instance.format(top2[1].value), '${totalSpent > 0 ? (top2[1].value/totalSpent*100).toStringAsFixed(0) : 0}%', Colors.red[800]!))
                                else
                                  const Spacer(),
                              ],
                            ),
                          if (next2.isNotEmpty) ...[
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                Expanded(child: _buildCategoryItem(next2[0].key, CurrencyService.instance.format(next2[0].value), '${totalSpent > 0 ? (next2[0].value/totalSpent*100).toStringAsFixed(0) : 0}%', Colors.brown[800]!)),
                                const SizedBox(width: 16),
                                if (next2.length > 1)
                                  Expanded(child: _buildCategoryItem(next2[1].key, CurrencyService.instance.format(next2[1].value), '${totalSpent > 0 ? (next2[1].value/totalSpent*100).toStringAsFixed(0) : 0}%', const Color(0xFF1ABC9C)))
                                else
                                  const Spacer(),
                              ],
                            ),
                          ],
                          const SizedBox(height: 24),
                          Center(
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const SpendingAnalyticsScreen()),
                                );
                              },
                              child: Text(
                                'View full analysis',
                                style: TextStyle(color: AppColors.primaryTeal, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                ),
                
                const SizedBox(height: 32),
                Visibility(
                  visible: false,
                  child: _buildKinPlusBanner(context),
                ),
                
                const SizedBox(height: 40),
              ],
            ),
          );
        }),
      ),
    ));
  }

  Widget _buildAccountDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTheme.bodyStyle(color: Colors.grey, fontSize: 14)),
        Row(
          children: [
            Text(value, style: AppTheme.dataStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                // Future: Add copy to clipboard
              },
              child: Icon(Icons.copy, color: AppColors.primaryTeal, size: 16),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryItem(String title, String amount, String percent, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTheme.bodyStyle(fontSize: 12, color: Colors.grey)),
            Text(
              '$amount ($percent)',
              style: AppTheme.dataStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String title, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)],
          border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primaryTeal, size: 24),
            const SizedBox(width: 16),
            Text(
              title,
              style: AppTheme.bodyStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.primaryTeal,
              ),
            ),
            const Spacer(),
            Icon(Icons.chevron_right, color: Colors.grey.withValues(alpha: 0.3)),
          ],
        ),
      ),
    );
  }

  Widget _buildKinPlusBanner(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const KinPlusScreen()),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryTeal,
              const Color(0xFF0D6B60),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryTeal.withValues(alpha: 0.2),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Get Kin+',
                    style: AppTheme.headingStyle(color: Colors.white, fontSize: 18),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Unlock free transfers and\npremium FX rates.',
                    style: AppTheme.bodyStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_forward, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
