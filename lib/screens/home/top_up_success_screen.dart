import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/firestore_service.dart';
import '../../core/services/auth_service.dart';
import '../main_screen.dart';

class TopUpSuccessScreen extends StatelessWidget {
  final double amount;
  const TopUpSuccessScreen({super.key, this.amount = 500.0});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 40),
                        _buildSuccessIcon(),
                        const SizedBox(height: 30),
                        Text(
                          'Balance updated!',
                          style: AppTheme.headingStyle(fontSize: 32),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'J\$${amount.toStringAsFixed(2)} is now ready to send or\nspend.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[600], fontSize: 16, height: 1.5),
                        ),
                        const SizedBox(height: 40),
                        _buildBalanceCard(),
                        const SizedBox(height: 40),
                        const Spacer(),
                        _buildActionButtons(context),
                        const SizedBox(height: 30),
                        _buildFooterIcons(),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSuccessIcon() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: AppColors.primaryTeal.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primaryTeal, width: 3),
          ),
          child: const Icon(Icons.check, color: AppColors.primaryTeal, size: 36),
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return StreamBuilder<Map<String, dynamic>?>(
      stream: FirestoreService.instance.streamUserProfile(AuthService.instance.currentUid),
      builder: (context, snapshot) {
        final bal = (snapshot.data?['balance'] as num?)?.toDouble() ?? 2950.50;
        return Container(
          width: double.infinity,
          height: 180,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primaryTeal, Color(0xFFE27D60)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 10))],
          ),
          child: Stack(
            children: [
              Positioned(
                right: 0,
                top: 0,
                child: Icon(Icons.account_balance_wallet, color: Colors.white.withValues(alpha: 0.8), size: 32),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('KIN PREMIUM', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 20),
                  Text('New Total Balance', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12)),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text('J\$', style: AppTheme.headingStyle(fontSize: 24, color: Colors.white)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            bal.toStringAsFixed(2),
                            style: AppTheme.headingStyle(fontSize: 40, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      const Icon(Icons.account_balance_wallet_outlined, color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      Text('kin', style: AppTheme.headingStyle(fontSize: 16, color: Colors.white)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryTeal,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
          child: const Text('Done', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
        ),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const MainScreen(initialIndex: 1)),
              (route) => false,
            );
          },
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 56),
            side: BorderSide(color: AppColors.primaryTeal.withValues(alpha: 0.5)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text('Send money now', style: TextStyle(color: AppColors.primaryTeal, fontWeight: FontWeight.bold, fontSize: 16)),
              SizedBox(width: 8),
              Icon(Icons.arrow_forward, color: AppColors.primaryTeal, size: 18),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFooterIcons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.eco_outlined, color: Colors.grey[300], size: 24),
        const SizedBox(width: 24),
        Icon(Icons.shield_outlined, color: Colors.grey[300], size: 24),
        const SizedBox(width: 24),
        Icon(Icons.group_outlined, color: Colors.grey[300], size: 24),
      ],
    );
  }
}
