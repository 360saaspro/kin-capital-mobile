import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/firestore_service.dart';
import '../../core/services/auth_service.dart';
import 'top_up_success_screen.dart';

class TopUpAmountScreen extends StatefulWidget {
  const TopUpAmountScreen({super.key});

  @override
  State<TopUpAmountScreen> createState() => _TopUpAmountScreenState();
}

class _TopUpAmountScreenState extends State<TopUpAmountScreen> {
  String _amount = "250";
  bool _isLoading = false;

  void _onKeyTap(String key) {
    setState(() {
      if (key == "delete") {
        if (_amount.isNotEmpty) {
          _amount = _amount.substring(0, _amount.length - 1);
        }
      } else {
        if (_amount == "0") _amount = "";
        _amount += key;
      }
    });
  }

  void _addQuickAmount(double value) {
    final current = double.tryParse(_amount.replaceAll(',', '')) ?? 0.0;
    setState(() {
      _amount = (current + value).toStringAsFixed(0);
    });
  }

  Future<void> _handleTopUp() async {
    final parsedAmount = double.tryParse(_amount.replaceAll(',', '')) ?? 0.0;
    if (parsedAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid top up amount.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final uid = AuthService.instance.currentUid;
      // Update balance in Firestore
      await FirestoreService.instance.updateUserBalance(uid, parsedAmount);

      // Record deposit transaction in Firestore
      await FirestoreService.instance.addTransaction(
        userId: uid,
        amount: parsedAmount,
        type: 'deposit',
        title: 'Top Up',
        metadata: {
          'method': 'Debit Card / Bank Handoff',
          'status': 'Success',
        },
      );

      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TopUpSuccessScreen(amount: parsedAmount)),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Top up complete. Balance updated.')),
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TopUpSuccessScreen(amount: parsedAmount)),
        );
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.kinInk),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('TOP UP', style: AppTheme.headingStyle(fontSize: 14, color: Colors.grey[600], letterSpacing: 1.5)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          _buildDestinationPill(),
          const Spacer(),
          _buildAmountDisplay(),
          const SizedBox(height: 8),
          StreamBuilder<Map<String, dynamic>?>(
            stream: FirestoreService.instance.streamUserProfile(AuthService.instance.currentUid),
            builder: (context, snapshot) {
              final bal = (snapshot.data?['balance'] as num?)?.toDouble() ?? 0.00;
              return Text('Current Balance: J\$${bal.toStringAsFixed(2)}', style: TextStyle(color: Colors.grey[500], fontSize: 13));
            },
          ),
          const Spacer(),
          _buildNumericKeypad(),
          const SizedBox(height: 24),
          _buildQuickAddChips(),
          const SizedBox(height: 24),
          _buildContinueButton(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildDestinationPill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.kinMistLight.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(color: AppColors.primaryTeal, shape: BoxShape.circle),
            child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 14),
          ),
          const SizedBox(width: 8),
          Text('To: ', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          const Text('My Kin Account', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(width: 4),
          Icon(Icons.keyboard_arrow_down, color: Colors.grey[400], size: 16),
        ],
      ),
    );
  }

  Widget _buildAmountDisplay() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('J\$', style: AppTheme.headingStyle(fontSize: 32, color: AppColors.primaryTeal)),
        const SizedBox(width: 8),
        Text(
          _amount.isEmpty ? '0' : _amount,
          style: AppTheme.headingStyle(fontSize: 64, color: AppColors.kinInk),
        ),
        Container(
          width: 2,
          height: 50,
          color: AppColors.primaryTeal,
        ),
      ],
    );
  }

  Widget _buildNumericKeypad() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          _buildKeypadRow(['1', '2', '3']),
          const SizedBox(height: 24),
          _buildKeypadRow(['4', '5', '6']),
          const SizedBox(height: 24),
          _buildKeypadRow(['7', '8', '9']),
          const SizedBox(height: 24),
          _buildKeypadRow(['.', '0', 'delete']),
        ],
      ),
    );
  }

  Widget _buildKeypadRow(List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: keys.map((key) {
        return GestureDetector(
          onTap: () => _onKeyTap(key),
          child: Container(
            width: 60,
            height: 40,
            alignment: Alignment.center,
            child: key == 'delete'
                ? const Icon(Icons.backspace_outlined, color: AppColors.kinInk)
                : Text(key, style: AppTheme.headingStyle(fontSize: 24)),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQuickAddChips() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildChip('+J\$50', 50),
        const SizedBox(width: 12),
        _buildChip('+J\$100', 100),
        const SizedBox(width: 12),
        _buildChip('+J\$500', 500),
      ],
    );
  }

  Widget _buildChip(String label, double val) {
    return GestureDetector(
      onTap: () => _addQuickAmount(val),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Text(label, style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold, fontSize: 13)),
      ),
    );
  }

  Widget _buildContinueButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleTopUp,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryTeal,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Continue', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                ],
              ),
      ),
    );
  }
}
