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
import '../pots/round_up_config_screen.dart';
import '../send/recipients_screen.dart';
import 'add_money_methods_screen.dart';
import 'notifications_screen.dart';
import 'split_bill_selection_screen.dart';

class HomeScreen extends StatefulWidget {
  final String? entityId;
  const HomeScreen({super.key, this.entityId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _api = ApiService();
  late final String _entityId;

  bool _loading = true;
  String? _error;
  LedgerResponse? _ledger;
  CreditOffer? _credit;
  double _balance = 0;

  @override
  void initState() {
    super.initState();
    _entityId = widget.entityId ?? AppConfig().entityId;
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final results = await Future.wait([
        _api.ledger(_entityId),
        _api.creditOffer(_entityId),
      ]);
      final ledger = results[0] as LedgerResponse;
      final credit = results[1] as CreditOffer;
      // Calculate balance: sum of all amounts (positive = inflows, negative = outflows)
      double bal = 0;
      for (final e in ledger.entries) {
        bal += e.amount;
      }
      setState(() {
        _ledger = ledger;
        _credit = credit;
        _balance = bal;
        _loading = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kinMistLight,
      body: BrandedBackground(
        opacity: 0.08,
        child: SafeArea(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? _buildOfflineMode()
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 12),
                            _buildHeader(context),
                            const SizedBox(height: 40),
                            _buildBalance(context),
                            if (_balance < 50) _buildLowBalanceAlert(context),
                            const SizedBox(height: 32),
                            _buildMainCTA(context),
                            const SizedBox(height: 32),
                            _buildCreditCallout(context),
                            const SizedBox(height: 32),
                            _buildPotsSection(context),
                            const SizedBox(height: 32),
                            _buildRecentTransfersHeader(context),
                            const SizedBox(height: 16),
                            ..._buildRecentTransfers(),
                            const SizedBox(height: 40),
                            Center(
                              child: Image.asset(
                                'assets/images/kin_logo.png',
                                width: 60,
                                color: AppColors.kinCoral.withValues(alpha: 0.3),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        mini: true,
        backgroundColor: Colors.white,
        child: const Icon(Icons.add, color: AppColors.kinInk),
      ),
    );
  }

  Widget _buildOfflineMode() {
    // Fallback: show the original static UI when the API is unreachable
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          _buildHeader(context),
          const SizedBox(height: 40),
          Text(
            'Available to send',
            style: AppTheme.bodyStyle(color: AppColors.kinInk.withValues(alpha: 0.6), fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            '£2,450.50',
            style: AppTheme.headingStyle(fontWeight: FontWeight.bold, color: AppColors.kinInk, fontSize: 36),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddMoneyMethodsScreen())),
            icon: Icon(Icons.add_circle_outline, color: AppColors.primaryTeal, size: 18),
            label: Text('Add money', style: TextStyle(color: AppColors.primaryTeal, fontWeight: FontWeight.bold)),
            style: TextButton.styleFrom(
              backgroundColor: AppColors.primaryTeal.withValues(alpha: 0.05),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 32),
          _buildMainCTA(context),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.orange.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.cloud_off, color: Colors.orange, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('API Offline', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 14)),
                      Text('Kin Capital Rails backend unreachable. Showing cached data.',
                          style: TextStyle(color: Colors.orange.withValues(alpha: 0.8), fontSize: 11)),
                    ],
                  ),
                ),
                IconButton(onPressed: _load, icon: const Icon(Icons.refresh, color: Colors.orange)),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _buildPotsSection(context),
          const SizedBox(height: 32),
          _buildRecentTransfersHeader(context),
          const SizedBox(height: 16),
          _buildStaticTransferItem(
            name: 'Waitrose & Partners',
            time: 'Today, 10:45 AM',
            amount: '£42.50',
            status: 'Success',
          ),
          const SizedBox(height: 12),
          _buildStaticTransferItem(
            name: 'Mom',
            time: 'Sent 2 days ago',
            amount: '£45.00',
            status: 'Success',
          ),
          const SizedBox(height: 40),
          Center(
            child: Image.asset('assets/images/kin_logo.png', width: 60,
                color: AppColors.kinCoral.withValues(alpha: 0.3)),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
          'Good ${_greeting()}, ${_entityId.split('_').first[0].toUpperCase()}${_entityId.split('_').first.substring(1)}',
          style: AppTheme.bodyStyle(
            color: AppColors.kinInk.withValues(alpha: 0.6),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'morning';
    if (hour < 17) return 'afternoon';
    return 'evening';
  }

  Widget _buildBalance(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text(
            'Available balance',
            style: AppTheme.bodyStyle(color: AppColors.kinInk.withValues(alpha: 0.6), fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            '\$${_balance.toStringAsFixed(0)}',
            style: AppTheme.headingStyle(fontWeight: FontWeight.bold, color: AppColors.kinInk, fontSize: 36),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddMoneyMethodsScreen())),
            icon: Icon(Icons.add_circle_outline, color: AppColors.primaryTeal, size: 18),
            label: Text('Add money', style: TextStyle(color: AppColors.primaryTeal, fontWeight: FontWeight.bold)),
            style: TextButton.styleFrom(
              backgroundColor: AppColors.primaryTeal.withValues(alpha: 0.05),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
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
                Text('Balance is low',
                    style: TextStyle(color: AppColors.kinCoral, fontWeight: FontWeight.bold, fontSize: 14)),
                Text('Top up now to ensure your scheduled transfers go through.',
                    style: TextStyle(color: AppColors.kinCoral.withValues(alpha: 0.8), fontSize: 11, height: 1.4)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.kinCoral.withValues(alpha: 0.5)),
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
                  Text('Agentic Credit Available', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
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

  Widget _buildPotsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Your Yard Pots', style: AppTheme.headingStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildPotCard(title: 'Family Vacation', amount: '\$450.00', progress: 0.37,
                  color: AppColors.primaryCoral, icon: Icons.beach_access),
              const SizedBox(width: 16),
              _buildPotCard(title: 'School Fees', amount: '\$1,200.00', progress: 0.85,
                  color: AppColors.primaryTeal, icon: Icons.school),
              const SizedBox(width: 16),
              _buildPotCard(title: 'Emergency', amount: '\$800.00', progress: 0.60,
                  color: Colors.orange, icon: Icons.emergency),
            ],
          ),
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

  List<Widget> _buildRecentTransfers() {
    if (_ledger == null || _ledger!.entries.isEmpty) {
      return [_buildStaticTransferItem(name: 'No recent activity', time: '', amount: '', status: '')];
    }
    final recent = _ledger!.entries.take(5).toList();
    return recent.map((e) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _buildStaticTransferItem(
        name: e.counterparty.isNotEmpty ? e.counterparty : _eventTypeLabel(e.eventType),
        time: _formatTime(e.timestamp),
        amount: '\$${e.amount.toStringAsFixed(0)}',
        status: 'Processed',
      ),
    )).toList();
  }

  String _eventTypeLabel(String type) {
    const labels = {
      'remittance': 'Remittance Received',
      'wallet_transfer': 'Wallet Transfer',
      'pos_sale': 'POS Sale',
      'airtime_payment': 'Airtime Payment',
      'utility_payment': 'Utility Payment',
    };
    return labels[type] ?? type;
  }

  String _formatTime(String ts) {
    try {
      final dt = DateTime.parse(ts);
      return '${dt.month}/${dt.day} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return ts;
    }
  }

  Widget _buildStaticTransferItem({
    required String name, required String time, required String amount, required String status,
  }) {
    if (name == 'No recent activity') {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Center(child: Text('No recent activity', style: TextStyle(color: Colors.grey[400]))),
      );
    }
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TransactionDetailScreen())),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.primaryTeal.withValues(alpha: 0.1),
              child: Icon(Icons.swap_horiz, color: AppColors.primaryTeal, size: 20),
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
                Text(amount, style: AppTheme.dataStyle(fontWeight: FontWeight.bold)),
                if (status.isNotEmpty)
                  Text(status, style: const TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}