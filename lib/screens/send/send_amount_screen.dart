import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/swipe_to_send_button.dart';
import '../../models/api_models.dart';
import '../../services/api_service.dart';
import '../../services/app_config.dart';
import '../../core/services/firestore_service.dart';
import '../../core/services/auth_service.dart';
import 'processing_transfer_screen.dart';

class SendAmountScreen extends StatefulWidget {
  final String? entityId;
  final String recipientName;
  final String? avatarUrl;
  final String flagEmoji;

  const SendAmountScreen({
    super.key,
    this.entityId,
    required this.recipientName,
    this.avatarUrl,
    this.flagEmoji = '🇯🇲',
  });

  @override
  State<SendAmountScreen> createState() => _SendAmountScreenState();
}

class _SendAmountScreenState extends State<SendAmountScreen> {
  final _api = ApiService();
  final _amountController = TextEditingController(text: '100');

  late final String _entityId;

  bool _loading = false;
  RouteResult? _route;

  static const double _exchangeRate = 195.0; // 1 USD = 195 JMD (demo)

  @override
  void initState() {
    super.initState();
    _entityId = widget.entityId ?? AppConfig().entityId;
    _fetchRoute();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _fetchRoute() async {
    final amt = double.tryParse(_amountController.text) ?? 100;
    if (amt <= 0) return;
    setState(() => _loading = true);
    try {
      final route = await _api.routeTransfer(
        fromEntity: _entityId,
        toEntity: 'recipient_001',
        amount: amt,
      );
      if (mounted) setState(() => _route = route);
    } catch (_) {
      if (mounted) setState(() => _route = null);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _handleExecuteTransfer(double amount) async {
    try {
      final uid = AuthService.instance.currentUid;
      // Deduct balance from Firestore
      await FirestoreService.instance.updateUserBalance(uid, -amount);

      // Record transfer transaction in Firestore
      await FirestoreService.instance.addTransaction(
        userId: uid,
        amount: -amount,
        type: 'transfer',
        title: 'Transfer to ${widget.recipientName}',
        metadata: {
          'counterparty': widget.recipientName,
          'status': 'Success',
          'currency': 'USD/JMD',
        },
      );
    } catch (e) {
      // Fallback
    }

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProcessingTransferScreen(
            recipientName: widget.recipientName,
            amount: amount.toStringAsFixed(0),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final amount = double.tryParse(_amountController.text) ?? 0;
    final fee = _route?.fee ?? 0;
    final feePct = _route?.feePct ?? 5.0;
    final eta = _route?.eta ?? 'seconds';
    final routeName = _route?.selectedRoute ?? 'Stablecoin';

    final recipientAmount = amount * _exchangeRate;
    final feeDisplay = fee > 0 ? '\$${fee.toStringAsFixed(2)}' : '\$${(amount * 0.05).toStringAsFixed(2)}';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Send Money', style: AppTheme.headingStyle(fontSize: 18)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 24),
              // Recipient Chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundImage: widget.avatarUrl != null ? NetworkImage(widget.avatarUrl!) : null,
                    ),
                    const SizedBox(width: 8),
                    Text(widget.recipientName, style: AppTheme.bodyStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(width: 4),
                    Text(widget.flagEmoji),
                  ],
                ),
              ),
              const SizedBox(height: 48),

              // Amount Input
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text('\$', style: AppTheme.headingStyle(fontSize: 48, color: AppColors.primaryTeal)),
                  SizedBox(
                    width: 150,
                    child: TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: AppTheme.headingStyle(fontSize: 80, color: AppColors.primaryTeal),
                      decoration: const InputDecoration(border: InputBorder.none),
                      onChanged: (_) => _fetchRoute(),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              Text(
                '${widget.recipientName} gets \$${recipientAmount.toStringAsFixed(0)} JMD',
                style: AppTheme.headingStyle(fontSize: 20),
              ),
              const SizedBox(height: 8),
              Text(
                'FEE: $feeDisplay • RATE: 1 USD = $_exchangeRate JMD',
                style: AppTheme.bodyStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bolt, color: AppColors.primaryTeal, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'VIA $routeName • ARRIVING IN $eta',
                    style: AppTheme.bodyStyle(fontSize: 12, color: AppColors.primaryTeal, fontWeight: FontWeight.bold),
                  ),
                ],
              ),

              const Spacer(),

              // Method Selector
              if (_loading)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
                )
              else
                Row(
                  children: [
                    _buildRouteOption(
                      label: routeName,
                      subtitle: '${feePct.toStringAsFixed(1)}% fee',
                      saveText: feePct < 1 ? 'SAVES 90%' : null,
                      selected: true,
                    ),
                    const SizedBox(width: 16),
                    _buildRouteOption(
                      label: 'MTO',
                      subtitle: '7.5% fee',
                      selected: false,
                    ),
                  ],
                ),

              const SizedBox(height: 32),

              // Swipe Button
              SwipeToSendButton(
                text: '→ Swipe to send \$${amount.toStringAsFixed(0)}',
                onCompleted: () => _handleExecuteTransfer(amount),
              ),

              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline, color: Colors.grey[400], size: 14),
                  const SizedBox(width: 4),
                  Text('SECURE END-TO-END ENCRYPTED TRANSFER',
                      style: TextStyle(fontSize: 10, color: Colors.grey[400], letterSpacing: 0.5, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRouteOption({
    required String label,
    required String subtitle,
    String? saveText,
    required bool selected,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? AppColors.primaryTeal.withValues(alpha: 0.1) : Colors.transparent),
          boxShadow: selected
              ? [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)]
              : null,
        ),
        child: Column(
          children: [
            Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: selected ? AppColors.kinInk : Colors.grey[700])),
            const SizedBox(height: 4),
            Text(subtitle, style: TextStyle(fontSize: 10, color: Colors.grey[500])),
            if (saveText != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryCoral.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(saveText, style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
              ),
            ] else
              const SizedBox(height: 18),
          ],
        ),
      ),
    );
  }
}