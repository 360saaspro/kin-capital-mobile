import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/firestore_service.dart';

class AdminTransactionDetailScreen extends StatefulWidget {
  final Map<String, dynamic> transaction;
  const AdminTransactionDetailScreen({super.key, required this.transaction});

  @override
  State<AdminTransactionDetailScreen> createState() => _AdminTransactionDetailScreenState();
}

class _AdminTransactionDetailScreenState extends State<AdminTransactionDetailScreen> {
  late Map<String, dynamic> _tx;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tx = Map<String, dynamic>.from(widget.transaction);
  }

  Future<void> _reverseTransaction() async {
    final txId = _tx['id'] as String?;
    if (txId == null) return;
    
    // Check if already reversed
    if (_tx['isReversed'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Transaction is already reversed'),
        backgroundColor: AppColors.kinCoral,
      ));
      return;
    }

    setState(() => _isLoading = true);
    await FirestoreService.instance.reverseTransaction(_tx);
    
    setState(() {
      _tx['isReversed'] = true;
      _isLoading = false;
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('Transaction reversed successfully'),
      backgroundColor: AppColors.kinTeal,
      behavior: SnackBarBehavior.floating,
    ));
  }

  Future<void> _flagTransaction() async {
    final txId = _tx['id'] as String?;
    if (txId == null) return;

    final isCurrentlyFlagged = _tx['isFlagged'] == true;
    final newFlagState = !isCurrentlyFlagged;

    setState(() => _isLoading = true);
    await FirestoreService.instance.flagTransaction(txId, newFlagState);

    setState(() {
      _tx['isFlagged'] = newFlagState;
      _isLoading = false;
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(newFlagState ? 'Transaction flagged for fraud' : 'Fraud flag removed'),
      backgroundColor: newFlagState ? AppColors.kinCoral : AppColors.kinTeal,
      behavior: SnackBarBehavior.floating,
    ));
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

  String _formatDate(String? iso) {
    if (iso == null) return 'Unknown Date';
    try {
      final dt = DateTime.parse(iso);
      return '${dt.day}/${dt.month}/${dt.year} at ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) { return 'Unknown Date'; }
  }

  @override
  Widget build(BuildContext context) {
    final title = _tx['title'] as String? ?? _tx['type'] as String? ?? 'Transaction';
    final type = (_tx['type'] as String? ?? 'transfer').toLowerCase();
    final amt = (_tx['amount'] as num?)?.toDouble().abs() ?? 0.0;
    final currency = _tx['currency'] as String? ?? 'JMD';
    final sym = _getCurrencySymbol(currency);
    
    final isDeposit = type == 'deposit' || type == 'received';
    final color = isDeposit ? AppColors.kinTeal : AppColors.kinCoral;
    final sign = isDeposit ? '+' : '-';
    
    final isReversed = _tx['isReversed'] == true;
    final isFlagged = _tx['isFlagged'] == true;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text('Transaction Details', style: AppTheme.headingStyle(fontSize: 18)),
        iconTheme: const IconThemeData(color: AppColors.kinInk),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: AppColors.kinTeal))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(title, '$sign$sym${amt.toStringAsFixed(2)}', color, isReversed, isFlagged),
                const SizedBox(height: 24),
                _buildActionButtons(isReversed, isFlagged),
                const SizedBox(height: 24),
                _buildSection('Transaction Information', [
                  _infoRow('Transaction ID', _tx['id'] ?? '—', isMono: true),
                  _infoRow('Date & Time', _formatDate(_tx['createdAt'] as String?)),
                  _infoRow('Type', type.toUpperCase()),
                  _infoRow('Status', isReversed ? 'Reversed' : 'Completed'),
                  _infoRow('User ID', _tx['userId'] ?? '—', isMono: true),
                ]),
                const SizedBox(height: 20),
                if (_tx['metadata'] != null || _tx['category'] != null || _tx['description'] != null)
                  _buildSection('Additional Details', [
                    if (_tx['category'] != null) _infoRow('Category', _tx['category']),
                    if (_tx['description'] != null) _infoRow('Description', _tx['description']),
                    if (_tx['metadata'] != null && _tx['metadata'] is Map)
                      ...(_tx['metadata'] as Map).entries.map((e) => _infoRow(e.key.toString(), e.value.toString())),
                  ]),
              ],
            ),
          ),
    );
  }

  Widget _buildHeader(String title, String amount, Color color, bool isReversed, bool isFlagged) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(
              color == AppColors.kinTeal ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
              size: 40, color: color
            ),
          ),
          const SizedBox(height: 16),
          Text(title, style: AppTheme.headingStyle(fontSize: 20)),
          const SizedBox(height: 8),
          Text(
            amount, 
            style: GoogleFonts.jetBrainsMono(
              fontSize: 32, 
              fontWeight: FontWeight.bold, 
              color: color,
              decoration: isReversed ? TextDecoration.lineThrough : null,
            )
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _statusBadge(isReversed ? 'REVERSED' : 'COMPLETED', isReversed ? AppColors.kinCoral : AppColors.kinTeal),
              if (isFlagged) ...[
                const SizedBox(width: 8),
                _statusBadge('FLAGGED', Colors.orange),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: AppTheme.bodyStyle(
          fontSize: 12, 
          color: color,
          fontWeight: FontWeight.bold
        )
      ),
    );
  }

  Widget _buildActionButtons(bool isReversed, bool isFlagged) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _flagTransaction,
            icon: Icon(isFlagged ? Icons.flag_rounded : Icons.outlined_flag_rounded, size: 18),
            label: Text(isFlagged ? 'Remove Flag' : 'Flag Fraud'),
            style: OutlinedButton.styleFrom(
              foregroundColor: isFlagged ? AppColors.kinInk : Colors.orange,
              side: BorderSide(color: isFlagged ? AppColors.kinInk : Colors.orange),
              padding: const EdgeInsets.symmetric(vertical: 14),
              minimumSize: const Size(0, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: isReversed ? null : _reverseTransaction,
            icon: const Icon(Icons.undo_rounded, size: 18),
            label: const Text('Reverse'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.kinCoral,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              minimumSize: const Size(0, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(title, style: AppTheme.headingStyle(fontSize: 16, color: Colors.grey[800]!)),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
        ),
      ],
    );
  }

  Widget _infoRow(String label, String value, {bool isMono = false}) {
    if (value == '—' || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: AppTheme.bodyStyle(fontSize: 13, color: Colors.grey[500]!)),
          ),
          Expanded(
            child: Text(
              value, 
              style: isMono 
                ? GoogleFonts.jetBrainsMono(fontSize: 13, color: AppColors.kinInk)
                : AppTheme.bodyStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.kinInk)
            ),
          ),
        ],
      ),
    );
  }
}
