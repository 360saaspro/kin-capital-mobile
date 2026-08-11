import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/branded_background.dart';

class CardManagementScreen extends StatefulWidget {
  const CardManagementScreen({super.key});

  @override
  State<CardManagementScreen> createState() => _CardManagementScreenState();
}

class _CardManagementScreenState extends State<CardManagementScreen> {
  bool isFrozen = false;
  bool showDetails = false;

  void _showPin() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Center(child: Text('Your PIN', style: AppTheme.headingStyle(fontSize: 20))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('8 8 4 0', style: AppTheme.dataStyle(fontSize: 32, letterSpacing: 8, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Text('Do not share this with anyone.', style: AppTheme.bodyStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: AppColors.primaryTeal, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
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
        title: Text('Your Kin Card', style: AppTheme.headingStyle(fontSize: 20)),
        centerTitle: true,
      ),
      body: BrandedBackground(
        opacity: 0.03,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDeliveryStatus(),
              const SizedBox(height: 32),
              _buildCardPreview(),
              const SizedBox(height: 40),
              Text('Management', style: AppTheme.headingStyle(fontSize: 18)),
              const SizedBox(height: 16),
              _buildManagementOption(
                icon: Icons.ac_unit,
                title: 'Freeze Card',
                subtitle: 'Lost your card? Freeze it instantly to prevent unauthorized transactions.',
                value: isFrozen,
                onChanged: (val) => setState(() => isFrozen = val),
              ),
              const SizedBox(height: 12),
              _buildActionItem(
                icon: Icons.pin_outlined,
                title: 'View PIN',
                subtitle: 'Securely reveal your card\'s PIN.',
                onTap: _showPin,
              ),
              const SizedBox(height: 12),
              _buildActionItem(
                icon: Icons.visibility_outlined,
                title: showDetails ? 'Hide Details' : 'View Card Details',
                subtitle: 'Show card number, CVV and expiry.',
                onTap: () => setState(() => showDetails = !showDetails),
              ),
              const SizedBox(height: 12),
              _buildActionItem(
                icon: Icons.sync_problem,
                title: 'Replace Card',
                subtitle: 'Damaged or stolen? Order a new one.',
                onTap: () {},
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeliveryStatus() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryTeal.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primaryTeal.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(color: AppColors.primaryTeal, shape: BoxShape.circle),
            child: const Icon(Icons.local_shipping_outlined, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Junior\'s card is on its way to Kingston 🇯🇲',
                  style: TextStyle(color: AppColors.kinInk, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text('Expected delivery: Oct 24th', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardPreview() {
    return Center(
      child: Container(
        height: 180,
        width: 280,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isFrozen ? [Colors.grey[400]!, Colors.grey[300]!] : [AppColors.primary, const Color(0xFFD35400)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 10))],
        ),
        child: Stack(
          children: [
            if (isFrozen)
              const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.ac_unit, color: Colors.white, size: 40),
                    SizedBox(height: 8),
                    Text('FROZEN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 2)),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.eco, color: Colors.amber, size: 20),
                  const Spacer(),
                  Text('•••• 8840', style: AppTheme.dataStyle(color: Colors.white, fontSize: 16)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManagementOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryTeal),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTheme.headingStyle(fontSize: 15)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: Colors.grey[500], fontSize: 11, height: 1.4)),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primaryTeal,
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)],
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primaryTeal),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTheme.headingStyle(fontSize: 15)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(color: Colors.grey[500], fontSize: 11, height: 1.4)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[300]),
          ],
        ),
      ),
    );
  }
}
