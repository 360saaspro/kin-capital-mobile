import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'top_up_amount_screen.dart';
import 'bank_handoff_screen.dart';
import '../profile/support_chat_screen.dart';

class AddMoneyMethodsScreen extends StatelessWidget {
  const AddMoneyMethodsScreen({super.key});

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
        title: Text('Add Money', style: AppTheme.headingStyle(fontSize: 18)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 32),
            _buildMethodCard(
              context,
              'Debit Card',
              'Add money using your Mastercard or Visa.',
              Icons.credit_card_outlined,
              destination: const TopUpAmountScreen(),
              footer: 'Small fee applies',
              iconColor: Colors.red[100]!,
              iconTextColor: Colors.red[700]!,
            ),
            _buildMethodCard(
              context,
              'Easy Bank Transfer',
              'Instant, secure transfer via Open Banking. No manual entry needed.',
              Icons.account_balance_outlined,
              destination: const BankHandoffScreen(),
              isRecommended: true,
              tags: ['Instant', 'Secure'],
              tagIcons: [Icons.bolt, Icons.verified_user_outlined],
            ),
            _buildMethodCard(
              context,
              'Apple Pay',
              'Fast checkout using your stored cards.',
              Icons.apple,
              destination: const TopUpAmountScreen(),
              footer: 'Instant',
              iconColor: Colors.black,
              iconTextColor: Colors.white,
              footerColor: AppColors.primaryTeal.withValues(alpha: 0.15),
              footerTextColor: AppColors.primaryTeal,
            ),
            const SizedBox(height: 32),
            _buildSupportCard(),
            const SizedBox(height: 24),
            _buildChatLink(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey[300]!, Colors.grey[100]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            top: -10,
            child: Opacity(
              opacity: 0.1,
              child: const Icon(Icons.account_balance_wallet, size: 100),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add money', style: AppTheme.headingStyle(fontSize: 28)),
              const SizedBox(height: 8),
              Text('Choose a method to fund your\naccount.', style: TextStyle(color: Colors.grey[600], height: 1.4)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMethodCard(
    BuildContext context,
    String title,
    String description,
    IconData icon, {
    required Widget destination,
    bool isRecommended = false,
    List<String>? tags,
    List<IconData>? tagIcons,
    String? footer,
    Color? iconColor,
    Color? iconTextColor,
    Color? footerColor,
    Color? footerTextColor,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destination),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isRecommended ? AppColors.primaryTeal : Colors.grey[200]!, width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconColor ?? AppColors.primaryTeal.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconTextColor ?? AppColors.primaryTeal, size: 24),
                ),
                if (isRecommended)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: AppColors.primaryTeal, borderRadius: BorderRadius.circular(20)),
                    child: const Text('RECOMMENDED', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Text(title, style: AppTheme.headingStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text(description, style: TextStyle(color: Colors.grey[600], fontSize: 13, height: 1.4)),
            if (tags != null) ...[
              const SizedBox(height: 16),
              Row(
                children: List.generate(tags.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Row(
                      children: [
                        Icon(tagIcons![index], size: 14, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text(tags[index], style: TextStyle(color: Colors.grey[500], fontSize: 12, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  );
                }),
              ),
            ],
            if (footer != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: footerColor ?? Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  footer,
                  style: TextStyle(
                    color: footerTextColor ?? Colors.grey[600],
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSupportCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'Having trouble? Our Caribbean support team is here to help you move your money smoothly.',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.orange[900], fontSize: 13, height: 1.5),
      ),
    );
  }

  Widget _buildChatLink(BuildContext context) {
    return Center(
      child: TextButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SupportChatScreen()),
          );
        },
        icon: const Icon(Icons.chat_bubble_outline, size: 18, color: AppColors.primaryTeal),
        label: const Text('Chat with Kin Support', style: TextStyle(color: AppColors.primaryTeal, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
