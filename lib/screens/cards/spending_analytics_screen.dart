import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

class SpendingAnalyticsScreen extends StatelessWidget {
  const SpendingAnalyticsScreen({super.key});

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
        title: Text('Spending Insights', style: AppTheme.headingStyle(fontSize: 20)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPeriodSelector(),
            const SizedBox(height: 32),
            _buildMonthlyReportHeader(),
            const SizedBox(height: 40),
            Center(child: _buildDonutChart()),
            const SizedBox(height: 40),
            _buildSmartInsightCard(),
            const SizedBox(height: 32),
            _buildBreakdownList(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _buildPeriodButton('Week', false),
          _buildPeriodButton('Month', true),
          _buildPeriodButton('Year', false),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(String label, bool isSelected) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)] : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.kinInk : Colors.grey[600],
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMonthlyReportHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Monthly Report', style: AppTheme.headingStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text('May 1 - May 31, 2026', style: TextStyle(color: Colors.grey[500], fontSize: 14)),
      ],
    );
  }

  Widget _buildDonutChart() {
    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(200, 200),
            painter: DonutChartPainter(),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Total Spent', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              Text('£2,450.00', style: AppTheme.headingStyle(fontSize: 24)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmartInsightCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryCoral.withValues(alpha: 0.1), Colors.orange[50]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primaryCoral.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: AppColors.primaryCoral, size: 20),
              const SizedBox(width: 8),
              Text('Smart Savings Insight', style: AppTheme.headingStyle(fontSize: 16, color: AppColors.primaryCoral)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Camille, your dining expenses are 12% higher this month. Consider setting a weekly cap to stay on track for your vacation goal.',
            style: TextStyle(color: Colors.grey[800], fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownList() {
    final data = [
      {'name': 'Groceries', 'percent': '40%', 'amount': '£980.00', 'trend': '-4%', 'isUp': false, 'color': Colors.teal[400]},
      {'name': 'Eating Out', 'percent': '25%', 'amount': '£612.50', 'trend': '+12%', 'isUp': true, 'color': Colors.orange[400]},
      {'name': 'Travel', 'percent': '20%', 'amount': '£490.00', 'trend': '-2%', 'isUp': false, 'color': Colors.blue[400]},
      {'name': 'Bills', 'percent': '15%', 'amount': '£367.50', 'trend': '0%', 'isUp': null, 'color': Colors.purple[400]},
    ];

    return Column(
      children: data.map((item) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)],
          ),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(color: item['color'] as Color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['name'] as String, style: AppTheme.headingStyle(fontSize: 15)),
                    Text('${item['percent']} of total spending', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(item['amount'] as String, style: AppTheme.dataStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      if (item['isUp'] != null)
                        Icon(
                          item['isUp'] == true ? Icons.trending_up : Icons.trending_down,
                          size: 14,
                          color: item['isUp'] == true ? Colors.red : Colors.green,
                        ),
                      const SizedBox(width: 4),
                      Text(
                        item['trend'] as String,
                        style: TextStyle(
                          color: item['isUp'] == null ? Colors.grey : (item['isUp'] == true ? Colors.red : Colors.green),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class DonutChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = 25.0;
    final rect = Rect.fromCircle(center: center, radius: radius - (strokeWidth / 2));

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final data = [
      {'percent': 0.40, 'color': Colors.teal[400]},
      {'percent': 0.25, 'color': Colors.orange[400]},
      {'percent': 0.20, 'color': Colors.blue[400]},
      {'percent': 0.15, 'color': Colors.purple[400]},
    ];

    double startAngle = -math.pi / 2;
    for (var item in data) {
      final sweepAngle = (item['percent'] as double) * 2 * math.pi;
      paint.color = item['color'] as Color;
      canvas.drawArc(rect, startAngle + 0.05, sweepAngle - 0.1, false, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
