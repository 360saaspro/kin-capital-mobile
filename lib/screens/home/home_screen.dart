import 'dart:async';
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
import '../send/recipients_screen.dart';
import 'add_money_methods_screen.dart';
import 'notifications_screen.dart';
import '../../core/services/firestore_service.dart';
import '../../core/services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  final String? entityId;
  const HomeScreen({super.key, this.entityId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _api = ApiService();
  late final String _entityId;
  CreditOffer? _credit;

  double _toDouble(dynamic val, [double fallback = 0.0]) {
    if (val == null) return fallback;
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val) ?? fallback;
    return fallback;
  }

  @override
  void initState() {
    super.initState();
    _entityId = widget.entityId ?? AppConfig().entityId;
    _loadCreditOffer();
  }

  Future<void> _loadCreditOffer() async {
    _api.creditOffer(_entityId).timeout(const Duration(seconds: 2)).then((credit) {
      if (mounted) setState(() => _credit = credit);
    }).catchError((_) {});
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
                Navigator.push(context, MaterialPageRoute(builder: (_) => const RecipientsScreen()));
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
      body: BrandedBackground(
        opacity: 0.02,
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _loadCreditOffer,
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
                      _credit != null
                          ? 'Credit score: ${_credit!.creditScore.toStringAsFixed(0)}/850  •  Limit: \$${_credit!.recommendedLimit.toStringAsFixed(0)}'
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
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 85.0),
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
                : 'Kin User');

        final nameParts = rawName.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
        final firstName = nameParts.isNotEmpty ? nameParts.first : 'User';

        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
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
                          _credit != null
                              ? '${_credit!.creditScore.toStringAsFixed(0)}/850'
                              : 'Credit',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.notifications_none_outlined, color: AppColors.primary, size: 28),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Image.asset('assets/images/kin_logo.png', width: 140),
            const SizedBox(height: 12),
            Text(
              'Good ${_greeting()}, $firstName',
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
                    '£${balance.toStringAsFixed(2)}',
                    style: AppTheme.headingStyle(fontWeight: FontWeight.bold, color: AppColors.kinInk, fontSize: 36),
                  ),
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddMoneyMethodsScreen())),
                    icon: const Icon(Icons.add_circle_outline, color: AppColors.primaryTeal, size: 18),
                    label: const Text('Add money', style: TextStyle(color: AppColors.primaryTeal, fontWeight: FontWeight.bold)),
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.primaryTeal.withValues(alpha: 0.05),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
            if (balance < 50) _buildLowBalanceAlert(context),
          ],
        );
      },
    );
  }

  Widget _buildLowBalanceAlert(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.kinCoral.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.kinCoral.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppColors.kinCoral, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Balance is low',
                    style: TextStyle(color: AppColors.kinCoral, fontWeight: FontWeight.bold, fontSize: 14)),
                Text('Top up now to ensure your scheduled transfers go through.',
                    style: TextStyle(color: AppColors.kinCoral.withValues(alpha: 0.8), fontSize: 11, height: 1.4)),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: AppColors.kinCoral.withValues(alpha: 0.5)),
        ],
      ),
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
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RecipientsScreen())),
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
          gradient: const LinearGradient(
            colors: [Color(0xFF006A61), Color(0xFF0FA89A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: AppColors.primary.withValues(alpha: 0.2), blurRadius: 12, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.psychology, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Agentic Credit Available', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(
                    '\$${_credit!.recommendedLimit.toStringAsFixed(0)} working capital  •  Score ${_credit!.creditScore.toStringAsFixed(0)}/850',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white, size: 20),
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
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SetGoalIdentityScreen())),
              child: Text('+ Create Pot', style: AppTheme.bodyStyle(color: AppColors.primaryTeal, fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        StreamBuilder<List<Map<String, dynamic>>>(
          stream: FirestoreService.instance.streamUserPots(uid),
          builder: (context, snapshot) {
            final pots = snapshot.data ?? [];
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
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        elevation: 0,
                      ),
                      child: const Text('Create', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  ],
                ),
              );
            }

            return SizedBox(
              height: 120,
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

                  return _buildPotCard(
                    title: title,
                    amount: '£${saved.toStringAsFixed(2)} / £${target.toStringAsFixed(0)}',
                    progress: progress,
                    color: AppColors.primaryTeal,
                    icon: Icons.savings_outlined,
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
    required String title, required String amount, required double progress,
    required Color color, required IconData icon,
  }) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const YardPotScreen())),
      child: Container(
        width: 200,
        height: 120,
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
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text(title, style: AppTheme.bodyStyle(fontWeight: FontWeight.bold, fontSize: 14), overflow: TextOverflow.ellipsis)),
            ]),
            const Spacer(),
            Text(amount, style: AppTheme.dataStyle(fontSize: 14, fontWeight: FontWeight.bold)),
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
            final amtStr = isNegative ? '- £${amt.abs().toStringAsFixed(2)}' : '+ £${amt.toStringAsFixed(2)}';

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildTransactionItem(
                name: title,
                time: '$type • Processed',
                amount: amtStr,
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildTransactionItem({
    required String name, required String time, required String amount,
  }) {
    final isNegative = amount.contains('-');
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TransactionDetailScreen())),
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
}