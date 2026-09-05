import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/firestore_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  final String? entityId;
  const AdminDashboardScreen({super.key, this.entityId});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with TickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnim;

  StreamSubscription? _usersSub;
  StreamSubscription? _txSub;
  StreamSubscription? _chatsSub;

  int _totalUsers = 0;
  int _verifiedKyc = 0;
  int _pendingKyc = 0;
  double _txVolumeToday = 0;
  int _openChats = 0;
  List<Map<String, dynamic>> _recentTx = [];
  List<Map<String, dynamic>> _recentUsers = [];

  // Counters driven by Firestore streams
  AnimationController? _kpiController;
  Animation<double>? _kpiAnim;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _kpiController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _kpiAnim = CurvedAnimation(parent: _kpiController!, curve: Curves.easeOutCubic);
    _listenData();
    _fadeController.forward();
  }

  void _listenData() {
    final fs = FirestoreService.instance;
    _usersSub = fs.streamAllUsers().listen((users) {
      if (!mounted) return;
      final verified = users.where((u) => u['kycStatus'] == 'verified').length;
      final pending = users.where((u) =>
          u['kycStatus'] == 'pending' || u['kycStatus'] == 'submitted' || u['kycStatus'] == 'flagged').length;
      final recent = users.take(5).toList();
      setState(() {
        _totalUsers = users.length;
        _verifiedKyc = verified;
        _pendingKyc = pending;
        _recentUsers = recent;
      });
      _kpiController?.forward(from: 0);
    });

    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month.toString().padLeft(2,'0')}-${today.day.toString().padLeft(2,'0')}';

    _txSub = fs.streamAllTransactions(limit: 50).listen((txs) {
      if (!mounted) return;
      final vol = txs
          .where((t) => (t['createdAt'] as String? ?? '').startsWith(todayStr))
          .fold<double>(0, (sum, t) {
            final amt = (t['amount'] as num?)?.toDouble().abs() ?? 0;
            final currency = t['currency'] as String?;
            return sum + _normalizeToJmd(amt, currency);
          });
      setState(() {
        _txVolumeToday = vol;
        _recentTx = txs.take(10).toList();
      });
    });

    _chatsSub = fs.streamSupportChats().listen((chats) {
      if (!mounted) return;
      setState(() => _openChats = chats.length);
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _kpiController?.dispose();
    _usersSub?.cancel();
    _txSub?.cancel();
    _chatsSub?.cancel();
    super.dispose();
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

  double _normalizeToJmd(double amount, String? currency) {
    if (currency == null) return amount;
    switch (currency.toUpperCase()) {
      case 'USD': return amount * 155.0;
      case 'GBP': return amount * 195.0;
      case 'CAD': return amount * 115.0;
      case 'JMD':
      default:
        return amount;
    }
  }

  String _fmtAmount(double v) {
    if (v >= 1000000) return 'J\$${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return 'J\$${(v / 1000).toStringAsFixed(1)}k';
    return 'J\$${v.toStringAsFixed(0)}';
  }

  String _initials(String? name) {
    if (name == null || name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return parts[0][0].toUpperCase();
  }

  Color _txAmountColor(Map<String, dynamic> tx) {
    final type = (tx['type'] as String? ?? '').toLowerCase();
    if (type == 'deposit' || type == 'received') return const Color(0xFF006A61);
    return AppColors.kinCoral;
  }

  String _txAmountStr(Map<String, dynamic> tx) {
    final amt = (tx['amount'] as num?)?.toDouble() ?? 0;
    final type = (tx['type'] as String? ?? '').toLowerCase();
    final c = tx['currency'] as String?;
    final prefix = (type == 'deposit' || type == 'received') ? '+' : '-';
    return '$prefix${_getCurrencySymbol(c)}${amt.abs().toStringAsFixed(2)}';
  }

  String _timeAgo(String? iso) {
    if (iso == null) return '';
    try {
      final dt = DateTime.parse(iso);
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return '${diff.inDays}d ago';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGreeting(),
            const SizedBox(height: 24),
            _buildKpiRow(),
            const SizedBox(height: 28),
            _buildTwoColumnRow(),
            const SizedBox(height: 28),
            _buildRecentUsers(),
          ],
        ),
      ),
    );
  }

  Widget _buildGreeting() {
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Good morning' : hour < 17 ? 'Good afternoon' : 'Good evening';
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(greeting, style: AppTheme.bodyStyle(fontSize: 14, color: Colors.grey[500])),
              const SizedBox(height: 2),
              Text('Banking Operations', style: AppTheme.headingStyle(fontSize: 26)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            gradient: AppColors.actionGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: AppColors.kinTeal.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0,4))],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.circle, color: Color(0xFF4AFF9E), size: 8),
              const SizedBox(width: 6),
              Text('Live', style: AppTheme.bodyStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKpiRow() {
    final kpis = [
      _KpiData('Total Users', _totalUsers.toString(), Icons.people_rounded, AppColors.kinTeal, 'All registered'),
      _KpiData('KYC Verified', _verifiedKyc.toString(), Icons.verified_rounded, const Color(0xFF009688), 'Approved accounts'),
      _KpiData('Pending Review', _pendingKyc.toString(), Icons.pending_rounded, const Color(0xFFF59E0B), 'Needs action'),
      _KpiData('Active Chats', _openChats.toString(), Icons.support_agent_rounded, AppColors.kinCoral, 'Open support'),
    ];

    return LayoutBuilder(builder: (ctx, box) {
      final isWide = box.maxWidth > 600;
      if (isWide) {
        return Row(
          children: kpis.asMap().entries.map((entry) {
            final isLast = entry.key == kpis.length - 1;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: isLast ? 0 : 16),
                child: _buildKpiCard(entry.value),
              ),
            );
          }).toList(),
        );
      }
      return Column(
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _buildKpiCard(kpis[0])),
                const SizedBox(width: 16),
                Expanded(child: _buildKpiCard(kpis[1])),
              ],
            ),
          ),
          const SizedBox(height: 16),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _buildKpiCard(kpis[2])),
                const SizedBox(width: 16),
                Expanded(child: _buildKpiCard(kpis[3])),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _buildKpiCard(_KpiData data) {
    return AnimatedBuilder(
      animation: _kpiAnim ?? const AlwaysStoppedAnimation(1.0),
      builder: (ctx, _) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 20, offset: const Offset(0, 6)),
              BoxShadow(color: data.color.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: data.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(data.icon, color: data.color, size: 20),
                  ),
                  const Spacer(),
                  Container(width: 8, height: 8,
                      decoration: BoxDecoration(color: data.color.withValues(alpha: 0.5), shape: BoxShape.circle)),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                data.value,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.kinInk,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                data.label,
                style: AppTheme.bodyStyle(fontSize: 13, color: Colors.grey[600]!, fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                data.subtitle,
                style: AppTheme.bodyStyle(fontSize: 11, color: Colors.grey[400]!),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTwoColumnRow() {
    return LayoutBuilder(builder: (ctx, box) {
      final isWide = box.maxWidth > 700;
      if (isWide) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 3, child: _buildRecentTransactions()),
            const SizedBox(width: 20),
            Expanded(flex: 2, child: _buildKycSummaryCard()),
          ],
        );
      }
      return Column(
        children: [
          _buildRecentTransactions(),
          const SizedBox(height: 20),
          _buildKycSummaryCard(),
        ],
      );
    });
  }

  Widget _buildRecentTransactions() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 20, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Row(
              children: [
                Text('Recent Transactions', style: AppTheme.headingStyle(fontSize: 16)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.kinMist, borderRadius: BorderRadius.circular(12)),
                  child: Text('Live', style: AppTheme.bodyStyle(fontSize: 11, color: AppColors.kinTeal, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF0F4F3)),
          if (_recentTx.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator(color: AppColors.kinTeal, strokeWidth: 2)),
            )
          else
            ...List.generate(_recentTx.length, (i) {
              final tx = _recentTx[i];
              final name = tx['title'] as String? ?? tx['type'] as String? ?? 'Transaction';
              final color = _txAmountColor(tx);
              return _buildTxRow(name, _txAmountStr(tx), _timeAgo(tx['createdAt'] as String?), color);
            }),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildTxRow(String name, String amount, String time, Color amtColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: amtColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              amtColor == AppColors.kinCoral ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
              color: amtColor, size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: AppTheme.bodyStyle(fontSize: 13, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
              Text(time, style: AppTheme.bodyStyle(fontSize: 11, color: Colors.grey[400]!)),
            ],
          )),
          Text(amount, style: GoogleFonts.jetBrainsMono(fontSize: 13, fontWeight: FontWeight.bold, color: amtColor)),
        ],
      ),
    );
  }

  Widget _buildKycSummaryCard() {
    final total = (_verifiedKyc + _pendingKyc).toDouble();
    final verifiedPct = total > 0 ? _verifiedKyc / total : 0.0;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF004D46), AppColors.kinTeal],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppColors.kinTeal.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('KYC Overview', style: AppTheme.headingStyle(fontSize: 16, color: Colors.white)),
          const SizedBox(height: 20),
          _buildKycStat('Verified', _verifiedKyc, Colors.white, const Color(0xFF4AFF9E)),
          const SizedBox(height: 12),
          _buildKycStat('Pending Review', _pendingKyc, Colors.white70, const Color(0xFFFFC947)),
          const SizedBox(height: 20),
          Text('Verification Rate', style: AppTheme.bodyStyle(fontSize: 12, color: Colors.white60)),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: verifiedPct,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4AFF9E)),
            ),
          ),
          const SizedBox(height: 6),
          Text('${(verifiedPct * 100).toStringAsFixed(0)}% of users verified',
              style: AppTheme.bodyStyle(fontSize: 11, color: Colors.white60)),
          const SizedBox(height: 16),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 16),
          Row(children: [
            const Icon(Icons.trending_up_rounded, color: Colors.white60, size: 16),
            const SizedBox(width: 6),
            Text("Today's Volume", style: AppTheme.bodyStyle(fontSize: 12, color: Colors.white60)),
            const Spacer(),
            Text(_fmtAmount(_txVolumeToday),
                style: GoogleFonts.jetBrainsMono(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          ]),
        ],
      ),
    );
  }


  Widget _buildKycStat(String label, int count, Color textColor, Color dotColor) {
    return Row(
      children: [
        Container(width: 10, height: 10,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
        const SizedBox(width: 10),
        Expanded(child: Text(label, style: AppTheme.bodyStyle(fontSize: 13, color: textColor))),
        Text(count.toString(), style: GoogleFonts.jetBrainsMono(
            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
      ],
    );
  }

  Widget _buildRecentUsers() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 20, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Text('Recent Sign-ups', style: AppTheme.headingStyle(fontSize: 16)),
          ),
          const Divider(height: 1, color: Color(0xFFF0F4F3)),
          if (_recentUsers.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Center(child: Text('No users yet', style: AppTheme.bodyStyle(color: Colors.grey[400]!))),
            )
          else
            ...List.generate(_recentUsers.length, (i) {
              final u = _recentUsers[i];
              final name = u['fullName'] as String? ?? u['email'] as String? ?? 'Unknown';
              final email = u['email'] as String? ?? '';
              final kyc = u['kycStatus'] as String? ?? 'pending';
              return _buildUserRow(name, email, kyc, i);
            }),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildUserRow(String name, String email, String kycStatus, int idx) {
    final colors = [AppColors.kinTeal, AppColors.kinCoral, const Color(0xFF7C3AED),
        const Color(0xFF0EA5E9), const Color(0xFFF59E0B)];
    final avatarColor = colors[idx % colors.length];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: avatarColor.withValues(alpha: 0.15), shape: BoxShape.circle),
            child: Center(child: Text(_initials(name),
                style: AppTheme.bodyStyle(fontSize: 14, fontWeight: FontWeight.bold, color: avatarColor))),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: AppTheme.bodyStyle(fontSize: 13, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
              Text(email, style: AppTheme.bodyStyle(fontSize: 11, color: Colors.grey[400]!), maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          )),
          _buildKycBadge(kycStatus),
        ],
      ),
    );
  }

  Widget _buildKycBadge(String status) {
    Color bg; Color text; String label;
    switch (status.toLowerCase()) {
      case 'verified': bg = const Color(0xFFE6F7F5); text = AppColors.kinTeal; label = 'Verified'; break;
      case 'flagged': bg = const Color(0xFFFFEDEC); text = AppColors.kinCoral; label = 'Flagged'; break;
      case 'pending': case 'submitted': bg = const Color(0xFFFFF7E6); text = const Color(0xFFB45309); label = 'Pending'; break;
      default: bg = const Color(0xFFF3F4F6); text = Colors.grey; label = status;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: AppTheme.bodyStyle(fontSize: 11, color: text, fontWeight: FontWeight.bold)),
    );
  }
}

class _KpiData {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String subtitle;
  const _KpiData(this.label, this.value, this.icon, this.color, this.subtitle);
}
