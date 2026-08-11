import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

class SetGoalDetailsScreen extends StatefulWidget {
  const SetGoalDetailsScreen({super.key});

  @override
  State<SetGoalDetailsScreen> createState() => _SetGoalDetailsScreenState();
}

class _SetGoalDetailsScreenState extends State<SetGoalDetailsScreen> {
  final TextEditingController _amountController = TextEditingController(text: '500');

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
          'Goal Details',
          style: AppTheme.headingStyle(fontSize: 20),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                'Step 2 of 2',
                style: TextStyle(fontSize: 10, color: Colors.grey[600], fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCategoryHero(),
            const SizedBox(height: 32),
            _buildAmountInput(),
            const SizedBox(height: 24),
            _buildDatePicker(),
            const SizedBox(height: 32),
            _buildBoostersSection(),
            const SizedBox(height: 40),
            _buildCreateButton(),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () {},
                child: Text(
                  'Save as Draft',
                  style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryHero() {
    return Container(
      width: double.infinity,
      height: 140,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primaryTeal,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Opacity(
              opacity: 0.1,
              child: Text(
                'kin',
                style: TextStyle(fontSize: 100, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'POT CATEGORY',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white.withValues(alpha: 0.8), letterSpacing: 1.2),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.umbrella, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    'Island Holiday',
                    style: AppTheme.headingStyle(color: Colors.white, fontSize: 28),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAmountInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Target Amount',
          style: TextStyle(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.kinMistLight.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Text('£', style: AppTheme.headingStyle(fontSize: 24, color: AppColors.kinInk)),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  style: AppTheme.headingStyle(fontSize: 32, color: AppColors.kinInk),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Aim high, start small.',
          style: TextStyle(fontSize: 12, color: Colors.grey[400], fontStyle: FontStyle.italic),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Target Date (Optional)',
          style: TextStyle(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.kinMistLight.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(Icons.calendar_today_outlined, color: Colors.grey[400], size: 20),
              const SizedBox(width: 12),
              Text(
                'Select a date',
                style: TextStyle(color: Colors.grey[400], fontSize: 16),
              ),
              const Spacer(),
              Icon(Icons.keyboard_arrow_down, color: AppColors.primaryTeal),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBoostersSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20, offset: Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SAVINGS BOOSTERS',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey[500], letterSpacing: 1.2),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.kinMistLight.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.orange[100], shape: BoxShape.circle),
                  child: Icon(Icons.sync, color: Colors.orange[700], size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Round-ups', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      Text('ON', style: AppTheme.headingStyle(fontSize: 16, color: AppColors.primaryTeal)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Multiplier', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                    Text('x2', style: AppTheme.headingStyle(fontSize: 16)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, color: AppColors.primaryTeal, size: 18),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Based on your spending, this multiplier will help you reach your £500 goal by August 2024.',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600], height: 1.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCreateButton() {
    return ElevatedButton(
      onPressed: () {
        Navigator.popUntil(context, (route) => route.isFirst);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryTeal,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
      child: Text('Create Pot'),
    );
  }
}
