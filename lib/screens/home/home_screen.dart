import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/branded_background.dart';
import '../../models/api_models.dart';
import '../../services/api_service.dart';
import '../../services/app_config.dart';
import '../activity/activity_screen.dart';
import '../activity/transaction_detail_screen.dart';
import '../capital_rails/kin_capital_rails_screen.dart';
import '../pots/yard_pot_screen.dart';
import '../pots/set_goal_identity_screen.dart';
import 'add_money_methods_screen.dart';
import 'notifications_screen.dart';
import '../profile/profile_screen.dart';
import '../main_screen.dart';
import '../../core/services/firestore_service.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/currency_service.dart';

class HomeScreen extends StatefulWidget {
  final String? entityId;
  final void Function(int tabIndex)? onSwitchTab;
  const HomeScreen({super.key, this.entityId, this.onSwitchTab});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _api = ApiService();
  late final String _entityId;
  CreditOffer? _credit;
  bool _hasApplied = false;

  double _toDouble(dynamic val, [double fallback = 0.0]) {
    if (val == null) return fallback;
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val) ?? fallback;
    return fallback;
  }

  IconData _resolvePotIcon(dynamic iconCode, dynamic category) {
    if (iconCode != null) {
      final code = int.tryParse(iconCode.toString());
      if (code == Icons.favorite_rounded.codePoint) return Icons.favorite_rounded;
      if (code == Icons.beach_access_rounded.codePoint || code == Icons.beach_access.codePoint) return Icons.beach_access_rounded;
      if (code == Icons.shield_outlined.codePoint) return Icons.shield_outlined;
      if (code == Icons.school_rounded.codePoint) return Icons.school_rounded;
      if (code == Icons.home_work_outlined.codePoint) return Icons.home_work_outlined;
      if (code == Icons.stars_rounded.codePoint) return Icons.stars_rounded;
      if (code == Icons.savings_outlined.codePoint) return Icons.savings_outlined;
    }
    final cat = category?.toString().toLowerCase() ?? '';
    if (cat.contains('family')) return Icons.favorite_rounded;
    if (cat.contains('vacation') || cat.contains('trip') || cat.contains('holiday')) return Icons.beach_access_rounded;
    if (cat.contains('emergency') || cat.contains('buffer') || cat.contains('rainy')) return Icons.shield_outlined;
    if (cat.contains('school') || cat.contains('tuition') || cat.contains('growth')) return Icons.school_rounded;
    if (cat.contains('home') || cat.contains('tech') || cat.contains('upgrade')) return Icons.home_work_outlined;
    return Icons.savings_outlined;
  }

  @override
  void initState() {
    super.initState();
    _entityId = widget.entityId ?? AppConfig().entityId;
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final uid = AuthService.instance.currentUid;
      final profile = await FirestoreService.instance.getUserProfile(uid);
      final creditProfile = profile?['creditProfile'] as Map<String, dynamic>?;
      final savedModel = creditProfile?['modelVersion'] as String?;
      final hasValidModel = savedModel != null && savedModel.isNotEmpty;
      final hasApplied = creditProfile != null && creditProfile['status'] == 'approved' && hasValidModel;

      final results = await Future.wait([
        _api.ledger(_entityId),
        _api.creditOffer(_entityId),
      ]);
      if (mounted) {
        setState(() {
          _credit = results[1] as CreditOffer;
          _hasApplied = hasApplied;
        });
      }
    } catch (_) {}
  }

  void _showQuickActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Quick Actions', style: AppTheme.headingStyle(fontSize: 20)),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.add_circle_outline, color: AppColors.primaryTeal),
              title: const Text('Add Money / Top Up'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AddMoneyMethodsScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.send_outlined, color: AppColors.primaryTeal),
              title: const Text('Send Money Home'),
              onTap: () {
                Navigator.pop(context);
                if (widget.onSwitchTab != null) {
                  widget.onSwitchTab!(1);
                } else {
                  MainScreen.switchToTab(context, 1);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.savings_outlined, color: AppColors.primaryTeal),
              title: const Text('Create New Yard Pot'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SetGoalIdentityScreen()));
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = AuthService.instance.currentUid;

    return Scaffold(
      backgroundColor: AppColors.kinMistLight,
      body: ValueListenableBuilder<AppCurrency>(
        valueListenable: CurrencyService.instance.currency,
        builder: (context, currency, _) {
          return BrandedBackground(
            opacity: 0.02,
            child: SafeArea(
              child: RefreshIndicator(
                onRefresh: _loadData,
                child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  _buildHeader(context, uid),
                  const SizedBox(height: 36),
                  _buildBalanceSection(context, uid),
                  const SizedBox(height: 32),
                  _buildMainCTA(context),
                  const SizedBox(height: 32),
                  _buildCreditCallout(context),
                  const SizedBox(height: 32),
                  _buildPotsSection(context, uid),
                  const SizedBox(height: 32),
                  _buildRecentTransfersHeader(context),
                  const SizedBox(height: 16),
                  _buildRealtimeTransfers(uid),
                  const SizedBox(height: 40),
                  Center(
                    child: Image.asset(
                      'assets/images/kin_logo.png',
                      width: 60,
                      color: AppColors.kinCoral.withValues(alpha: 0.1),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      _hasApplied && _credit != null
                          ? 'Credit score: ${_credit!.creditScore.toStringAsFixed(0)}/850  •  Limit: ${currency.symbol}${_credit!.recommendedLimit.toStringAsFixed(0)}'
                          : 'Your support makes home feel closer today.',
                      style: AppTheme.bodyStyle(
                        color: AppColors.kinInk.withValues(alpha: 0.5),
                        fontStyle: FontStyle.italic,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
      );
    }),
    floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 110.0),
        child: FloatingActionButton(
          onPressed: () => _showQuickActionSheet(context),
          mini: true,
          backgroundColor: AppColors.primaryTeal,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  /// 1. Dynamic User Name Header connected to Firestore users/{uid} document
  Widget _buildHeader(BuildContext context, String uid) {
    return StreamBuilder<Map<String, dynamic>?>(
      stream: FirestoreService.instance.streamUserProfile(uid),
      builder: (context, snapshot) {
        final profile = snapshot.data ?? FirestoreService.instance.getCachedUser(uid);
        final rawName = (profile?['fullName'] as String?)?.isNotEmpty == true
            ? profile!['fullName'] as String
            : (AuthService.instance.currentUser?.displayName?.isNotEmpty == true
                ? AuthService.instance.currentUser!.displayName!
                : '');

        final nameParts = rawName.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
        final firstName = nameParts.isNotEmpty ? nameParts.first : '';
        
        final rawPhotoUrl = AuthService.instance.fallbackPhotoUrl ?? profile?['photoURL'] ?? AuthService.instance.currentUser?.photoURL;

        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
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
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () {
                        if (_credit != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => KinCapitalRailsScreen(entityId: _entityId),
                            ),
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.bolt, size: 16, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(
                              _hasApplied && _credit != null
                                  ? '${_credit!.creditScore.toStringAsFixed(0)}/850'
                                  : 'Credit',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                StreamBuilder<List<Map<String, dynamic>>>(
                  stream: FirestoreService.instance.streamUserNotifications(uid),
                  builder: (context, snapshot) {
                    final notifications = snapshot.data ?? FirestoreService.instance.getCachedNotifications(uid);
                    final activeNotifications = notifications.where((n) {
                      final type = n['type']?.toString().toLowerCase();
                      final isRead = n['isRead'] == true;
                      return !isRead && (type == 'notification' || type == 'offer');
                    }).toList();

                    if (activeNotifications.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return IconButton(
                      icon: const Icon(Icons.notifications_active, color: AppColors.primary, size: 28),
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
                    );
                  }
                ),
              ],
            ),
            const SizedBox(height: 12),
            Image.asset('assets/images/kin_logo.png', width: 140),
            const SizedBox(height: 12),
            Text(
              firstName.isNotEmpty ? 'Good ${_greeting()}, $firstName' : 'Good ${_greeting()}',
              style: AppTheme.bodyStyle(
                color: AppColors.kinInk.withValues(alpha: 0.6),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      },
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'morning';
    if (hour < 17) return 'afternoon';
    return 'evening';
  }

  /// 2. Live Balance connected to Firestore users/{uid} document
  Widget _buildBalanceSection(BuildContext context, String uid) {
    return StreamBuilder<Map<String, dynamic>?>(
      stream: FirestoreService.instance.streamUserProfile(uid),
      builder: (context, snapshot) {
        final profile = snapshot.data ?? FirestoreService.instance.getCachedUser(uid);
        final balance = _toDouble(profile?['balance']);

        return Column(
          children: [
            Center(
              child: Column(
                children: [
                  Text(
                    'Available balance',
                    style: AppTheme.bodyStyle(color: AppColors.kinInk.withValues(alpha: 0.6), fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${CurrencyService.instance.symbol}${balance.toStringAsFixed(2)}',
                    style: AppTheme.headingStyle(fontWeight: FontWeight.bold, color: AppColors.kinInk, fontSize: 36),
                  ),
                  if (_hasApplied && _credit != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryTeal.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Capital Limit: ${CurrencyService.instance.symbol}${_credit!.recommendedLimit.toStringAsFixed(0)}',
                        style: AppTheme.bodyStyle(
                          color: AppColors.primaryTeal, 
                          fontWeight: FontWeight.bold, 
                          fontSize: 12
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddMoneyMethodsScreen())),
                    icon: const Icon(Icons.add_circle_outline, color: AppColors.kinInk, size: 18),
                    label: const Text('Add money', style: TextStyle(color: AppColors.kinInk, fontWeight: FontWeight.bold)),
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.kinInk.withValues(alpha: 0.05),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
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
          BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (widget.onSwitchTab != null) {
              widget.onSwitchTab!(1);
            } else {
              MainScreen.switchToTab(context, 1);
            }
          },
          borderRadius: BorderRadius.circular(20),
          splashColor: Colors.white.withValues(alpha: 0.2),
          highlightColor: Colors.white.withValues(alpha: 0.1),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.send_outlined, color: Colors.white),
              const SizedBox(width: 12),
              Text('Send money home',
                  style: AppTheme.headingStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreditCallout(BuildContext context) {
    if (_credit == null) return const SizedBox.shrink();
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => KinCapitalRailsScreen(entityId: _entityId)),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primaryTeal.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(color: AppColors.primaryTeal.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primaryTeal.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.psychology, color: AppColors.primaryTeal, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Agentic Credit Available', style: TextStyle(color: AppColors.kinInk, fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(
                    _hasApplied
                        ? '${CurrencyService.instance.symbol}${_credit!.recommendedLimit.toStringAsFixed(0)} working capital  •  Score ${_credit!.creditScore.toStringAsFixed(0)}/850'
                        : 'Apply to unlock working capital tailored for you.',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
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

  /// 3. Dynamic Yard Pots connected to Firestore users/{uid}/pots subcollection
  Widget _buildPotsSection(BuildContext context, String uid) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Your Yard Pots', style: AppTheme.headingStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SetGoalIdentityScreen())),
              style: TextButton.styleFrom(
                minimumSize: const Size(60, 48), // Ensures a standard touch target size
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: Text('+ Create Pot', style: AppTheme.bodyStyle(color: AppColors.primaryTeal, fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        StreamBuilder<List<Map<String, dynamic>>>(
          stream: FirestoreService.instance.streamUserPots(uid),
          builder: (context, snapshot) {
            final pots = (snapshot.data?.isNotEmpty == true)
                ? snapshot.data!
                : FirestoreService.instance.getCachedPots(uid);
            if (pots.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primaryTeal.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.primaryTeal.withValues(alpha: 0.1),
                      child: const Icon(Icons.savings_outlined, color: AppColors.primaryTeal),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('No Yard Pots Yet', style: AppTheme.bodyStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          const SizedBox(height: 4),
                          Text('Save towards family goals & emergencies.', style: AppTheme.bodyStyle(color: Colors.grey[600], fontSize: 12)),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SetGoalIdentityScreen())),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryTeal,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(80, 48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        elevation: 0,
                      ),
                      child: const Text('Create', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  ],
                ),
              );
            }

            return SizedBox(
              height: 140,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: pots.length,
                separatorBuilder: (context, index) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  final pot = pots[index];
                  final title = pot['title'] ?? 'Yard Pot';
                  final target = _toDouble(pot['targetAmount'], 500.0);
                  final saved = _toDouble(pot['savedAmount'], 0.0);
                  final progress = target > 0 ? (saved / target).clamp(0.0, 1.0) : 0.0;

                  final icon = _resolvePotIcon(pot['icon'], pot['category']);
                  final colorHex = pot['color']?.toString();
                  final color = colorHex != null
                      ? Color(int.tryParse(colorHex, radix: 16) ?? AppColors.primaryTeal.toARGB32())
                      : AppColors.primaryTeal;

                  return _buildPotCard(
                    pot: pot,
                    title: title,
                    amount: '${CurrencyService.instance.symbol}${saved.toStringAsFixed(2)} / ${CurrencyService.instance.symbol}${target.toStringAsFixed(0)}',
                    progress: progress,
                    color: color,
                    icon: icon,
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPotCard({
    required Map<String, dynamic> pot,
    required String title, required String amount, required double progress,
    required Color color, required IconData icon,
  }) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => YardPotScreen(pot: pot))),
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(title, style: AppTheme.bodyStyle(fontWeight: FontWeight.bold, fontSize: 14), overflow: TextOverflow.ellipsis)),
            ]),
            const Spacer(),
            Text(amount, style: AppTheme.dataStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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

  Widget _buildRecentTransfersHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Recent Activity', style: AppTheme.headingStyle(fontWeight: FontWeight.bold, color: AppColors.kinInk, fontSize: 18)),
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ActivityScreen())),
          child: Text('View all', style: AppTheme.bodyStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  String _formatDate(String isoString) {
    try {
      final dt = DateTime.parse(isoString);
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      final month = months[dt.month - 1];
      final day = dt.day;
      final year = dt.year;
      
      int hour = dt.hour;
      final amPm = hour >= 12 ? 'PM' : 'AM';
      if (hour > 12) hour -= 12;
      if (hour == 0) hour = 12;
      final minute = dt.minute.toString().padLeft(2, '0');
      
      return '$month $day, $year • ${hour.toString().padLeft(2, '0')}:$minute $amPm';
    } catch (_) {
      return '';
    }
  }

  /// 4. Recent Activity connected to Firestore transactions collection
  Widget _buildRealtimeTransfers(String uid) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: FirestoreService.instance.streamUserTransactions(uid),
      builder: (context, snapshot) {
        final transactions = (snapshot.data?.isNotEmpty == true)
            ? snapshot.data!
            : FirestoreService.instance.getCachedTransactions(uid);
        if (transactions.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: Column(
              children: [
                Icon(Icons.history_outlined, size: 36, color: Colors.grey[400]),
                const SizedBox(height: 8),
                Text('No Recent Activity', style: AppTheme.bodyStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Text('Top up or send money home to see activity here.', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              ],
            ),
          );
        }

        final recent = transactions.take(5).toList();
        return Column(
          children: recent.map((tx) {
            final title = tx['title'] ?? 'Transaction';
            final amt = _toDouble(tx['amount']);
            final type = tx['type'] ?? 'payment';
            final isNegative = amt < 0;
            final c = tx['currency'] as String? ?? (tx['metadata'] as Map<String, dynamic>?)?['currency'] as String?;
            final sym = _getCurrencySymbol(c);
            final amtStr = isNegative ? '- $sym${amt.abs().toStringAsFixed(2)}' : '+ $sym${amt.toStringAsFixed(2)}';

            final createdAt = tx['createdAt'] as String?;
            final dateStr = createdAt != null ? _formatDate(createdAt) : '';
            
            final metadata = tx['metadata'] as Map<String, dynamic>?;
            final recipientGets = metadata?['recipientGets'];
            final exchangeRate = metadata?['exchangeRate'];
            final fee = metadata?['fee'];

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildTransactionItem(
                name: title,
                time: '$type • Processed',
                amount: amtStr,
                date: dateStr,
                recipientGets: recipientGets,
                exchangeRate: exchangeRate,
                fee: fee,
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildTransactionItem({
    required String name, required String time, required String amount,
    String? date, String? recipientGets, String? exchangeRate, String? fee,
  }) {
    final isNegative = amount.contains('-');
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TransactionDetailScreen(
        title: name,
        amount: amount,
        time: date != null && date.isNotEmpty ? date : time,
        isNegative: isNegative,
        recipientGets: recipientGets?.toString(),
        exchangeRate: exchangeRate?.toString(),
        fee: fee?.toString(),
      ))),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: isNegative ? AppColors.kinCoral.withValues(alpha: 0.1) : AppColors.primaryTeal.withValues(alpha: 0.1),
              child: Icon(isNegative ? Icons.send_outlined : Icons.add_circle_outline,
                  color: isNegative ? AppColors.kinCoral : AppColors.primaryTeal, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: AppTheme.bodyStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  if (time.isNotEmpty) Text(time, style: AppTheme.bodyStyle(color: AppColors.kinInk.withValues(alpha: 0.5), fontSize: 12)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(amount, style: AppTheme.dataStyle(fontWeight: FontWeight.bold, color: isNegative ? AppColors.kinCoral : AppColors.primaryTeal)),
                const Text('Success', style: TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getCurrencySymbol(String? c) {
    switch ((c ?? 'JMD').toUpperCase()) {
      case 'JMD': return 'J\$';
      case 'USD': return 'US\$';
      case 'GBP': return '£';
      case 'CAD': return 'CA\$';
      default: return 'J\$';
    }
  }
}