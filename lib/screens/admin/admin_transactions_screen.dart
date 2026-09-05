import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/firestore_service.dart';
import 'admin_transaction_detail_screen.dart';

class AdminTransactionsScreen extends StatefulWidget {
  const AdminTransactionsScreen({super.key});

  @override
  State<AdminTransactionsScreen> createState() => _AdminTransactionsScreenState();
}

class _AdminTransactionsScreenState extends State<AdminTransactionsScreen> {
  StreamSubscription? _sub;
  List<Map<String, dynamic>> _all = [];
  List<Map<String, dynamic>> _filtered = [];
  String _activeFilter = 'All';
  bool _loading = true;

  final _filters = ['All', 'deposit', 'transfer', 'withdrawal', 'received'];

  @override
  void initState() {
    super.initState();
    _sub = FirestoreService.instance.streamAllTransactions(limit: 100).listen((txs) {
      if (!mounted) return;
      setState(() { _all = txs; _loading = false; _applyFilter(); });
    });
  }

  void _applyFilter() {
    setState(() {
      _filtered = _activeFilter == 'All'
          ? _all
          : _all.where((t) => (t['type'] as String? ?? '').toLowerCase() == _activeFilter).toList();
    });
  }

  @override
  void dispose() { _sub?.cancel(); super.dispose(); }

  String _getCurrencySymbol(String? c) {
    switch ((c ?? 'JMD').toUpperCase()) {
      case 'JMD': return 'J\$';
      case 'USD': return 'US\$';
      case 'GBP': return '£';
      case 'CAD': return 'CA\$';
      default: return 'J\$';
    }
  }

  Color _amtColor(Map<String, dynamic> tx) {
    final type = (tx['type'] as String? ?? '').toLowerCase();
    return (type == 'deposit' || type == 'received') ? AppColors.kinTeal : AppColors.kinCoral;
  }

  String _amtStr(Map<String, dynamic> tx) {
    final amt = (tx['amount'] as num?)?.toDouble().abs() ?? 0;
    final type = (tx['type'] as String? ?? '').toLowerCase();
    final c = tx['currency'] as String?;
    final prefix = (type == 'deposit' || type == 'received') ? '+' : '-';
    return '$prefix${_getCurrencySymbol(c)}${amt.toStringAsFixed(2)}';
  }

  String _timeAgo(String? iso) {
    if (iso == null) return '';
    try {
      final dt = DateTime.parse(iso);
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return '${diff.inDays}d ago';
    } catch (_) { return ''; }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: AppColors.kinTeal))
              : _filtered.isEmpty
                  ? _buildEmpty()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                      itemCount: _filtered.length,
                      itemBuilder: (ctx, i) => _buildTxCard(_filtered[i]),
                    ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text('Transactions', style: AppTheme.headingStyle(fontSize: 22)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(color: AppColors.kinMist, borderRadius: BorderRadius.circular(14)),
              child: Text('${_filtered.length} records',
                  style: AppTheme.bodyStyle(fontSize: 13, color: AppColors.kinTeal, fontWeight: FontWeight.bold)),
            ),
          ]),
          const SizedBox(height: 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _filters.map((f) {
                final isActive = _activeFilter == f;
                return GestureDetector(
                  onTap: () { setState(() => _activeFilter = f); _applyFilter(); },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.kinTeal : AppColors.kinMist,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      f == 'All' ? 'All' : '${f[0].toUpperCase()}${f.substring(1)}',
                      style: AppTheme.bodyStyle(fontSize: 13,
                          color: isActive ? Colors.white : Colors.grey[600]!,
                          fontWeight: isActive ? FontWeight.bold : FontWeight.normal),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTxCard(Map<String, dynamic> tx) {
    final title = tx['title'] as String? ?? tx['type'] as String? ?? 'Transaction';
    final type = (tx['type'] as String? ?? 'transfer');
    final color = _amtColor(tx);
    final amtStr = _amtStr(tx);
    final time = _timeAgo(tx['createdAt'] as String?);
    final userId = tx['userId'] as String? ?? '';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AdminTransactionDetailScreen(transaction: tx),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0,3))],
        ),
        child: Row(
          children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(12)),
              child: Icon(
                color == AppColors.kinTeal ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                color: color, size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTheme.bodyStyle(fontSize: 13, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Row(children: [
                  _typeBadge(type),
                  const SizedBox(width: 6),
                  if (userId.isNotEmpty)
                    Text('·  ${userId.length > 10 ? userId.substring(0, 10) : userId}…',
                        style: AppTheme.bodyStyle(fontSize: 11, color: Colors.grey[400]!)),
                ]),
              ],
            )),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(amtStr, style: GoogleFonts.jetBrainsMono(
                fontSize: 14, 
                fontWeight: FontWeight.bold, 
                color: color,
                decoration: tx['isReversed'] == true ? TextDecoration.lineThrough : null,
              )),
              const SizedBox(height: 3),
              Text(time, style: AppTheme.bodyStyle(fontSize: 11, color: Colors.grey[400]!)),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _typeBadge(String type) {
    final t = type.toLowerCase();
    Color bg = AppColors.kinMist; Color text = Colors.grey[600]!;
    if (t == 'deposit' || t == 'received') { bg = const Color(0xFFE6F7F5); text = AppColors.kinTeal; }
    if (t == 'withdrawal') { bg = const Color(0xFFFFEDEC); text = AppColors.kinCoral; }
    if (t == 'transfer') { bg = const Color(0xFFEEF2FF); text = const Color(0xFF4F46E5); }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text('${t[0].toUpperCase()}${t.substring(1)}',
          style: AppTheme.bodyStyle(fontSize: 10, color: text, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildEmpty() {
    return Center(child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey[300]),
        const SizedBox(height: 16),
        Text('No transactions found', style: AppTheme.headingStyle(fontSize: 18, color: Colors.grey[400]!)),
      ],
    ));
  }
}
