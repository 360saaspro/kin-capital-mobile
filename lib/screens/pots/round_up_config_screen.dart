import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

class RoundUpConfigScreen extends StatefulWidget {
  const RoundUpConfigScreen({super.key});

  @override
  State<RoundUpConfigScreen> createState() => _RoundUpConfigScreenState();
}

class _RoundUpConfigScreenState extends State<RoundUpConfigScreen> {
  bool _isRoundUpEnabled = true;
  int _multiplier = 1;

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
        title: Text(
          'Round-ups',
          style: AppTheme.headingStyle(fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            _buildExplanationCard(),
            const SizedBox(height: 24),
            _buildToggleCard(),
            const SizedBox(height: 24),
            _buildEstimateCard(),
            const SizedBox(height: 24),
            _buildMultiplierCard(),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryTeal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExplanationCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.kinMistLight.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        children: [
          Image.network(
            'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d7/Leaf_icon_1.svg/1024px-Leaf_icon_1.svg.png',
            width: 60,
            color: AppColors.kinInk,
          ),
          const SizedBox(height: 24),
          Text(
            'Yard Pot',
            style: AppTheme.headingStyle(fontSize: 16),
          ),
          const SizedBox(height: 12),
          Text(
            'Every transaction you make is rounded up to the nearest pound, helping you grow your wealth effortlessly.',
            textAlign: TextAlign.center,
            style: AppTheme.bodyStyle(color: Colors.grey[700], fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryTeal.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.account_balance_wallet_outlined, color: AppColors.primaryTeal),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Enable Round-ups', style: AppTheme.bodyStyle(fontWeight: FontWeight.bold)),
                Text('Active on all cards', style: AppTheme.bodyStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Switch.adaptive(
            value: _isRoundUpEnabled,
            onChanged: (v) => setState(() => _isRoundUpEnabled = v),
            activeThumbColor: AppColors.primaryTeal,
          ),
        ],
      ),
    );
  }

  Widget _buildEstimateCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primaryTeal,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.trending_up, color: Colors.white, size: 20),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'JUNE ESTIMATE',
                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Estimated savings',
            style: AppTheme.bodyStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                '£45.20',
                style: AppTheme.dataStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.bolt, color: Colors.white, size: 24),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMultiplierCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.kinMistLight.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
               Icon(Icons.close, color: AppColors.primaryTeal, size: 16),
               const SizedBox(width: 8),
               Text('Round-up Multiplier', style: AppTheme.bodyStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildMultiplierOption(1),
              const SizedBox(width: 12),
              _buildMultiplierOption(2),
              const SizedBox(width: 12),
              _buildMultiplierOption(5),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMultiplierOption(int value) {
    bool isSelected = _multiplier == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _multiplier = value),
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? AppColors.primaryTeal : Colors.transparent),
          ),
          child: Center(
            child: Text(
              '${value}x',
              style: AppTheme.dataStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isSelected ? AppColors.primaryTeal : Colors.grey,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
