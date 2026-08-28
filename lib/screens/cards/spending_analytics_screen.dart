import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/firestore_service.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/currency_service.dart';

class SpendingAnalyticsScreen extends StatefulWidget {
  const SpendingAnalyticsScreen({super.key});

  @override
  State<SpendingAnalyticsScreen> createState() => _SpendingAnalyticsScreenState();
}

class _SpendingAnalyticsScreenState extends State<SpendingAnalyticsScreen> {
  String _selectedPeriod = 'Month'; // 'Week', 'Month', 'Year'

  List<Map<String, dynamic>> _filterTransactions(List<Map<String, dynamic>> allTx) {
    final now = DateTime.now();
    return allTx.where((t) {
      if (t['type'] != 'withdrawal' && t['type'] != 'payment' && t['type'] != 'expense' && t['type'] != 'transfer') return false;
      final createdAtStr = t['createdAt'] as String?;
      if (createdAtStr == null) return false;
      try {
        final date = DateTime.parse(createdAtStr);
        if (_selectedPeriod == 'Week') {
          return now.difference(date).inDays <= 7;
        } else if (_selectedPeriod == 'Month') {
          return date.month == now.month && date.year == now.year;
        } else if (_selectedPeriod == 'Year') {
          return date.year == now.year;
        }
        return false;
      } catch (_) {
        return false;
      }
    }).toList();
  }

  String _getPeriodSubtitle() {
    final now = DateTime.now();
    if (_selectedPeriod == 'Week') {
      return 'Last 7 Days';
    } else if (_selectedPeriod == 'Month') {
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[now.month - 1]} 1 - ${months[now.month - 1]} ${DateTime(now.year, now.month + 1, 0).day}, ${now.year}';
    } else {
      return 'Jan 1 - Dec 31, ${now.year}';
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
        title: Text('Spending Insights', style: AppTheme.headingStyle(fontSize: 20)),
        centerTitle: true,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: FirestoreService.instance.streamUserTransactions(AuthService.instance.currentUid),
        builder: (context, snapshot) {
          final allTransactions = snapshot.data ?? FirestoreService.instance.getCachedTransactions(AuthService.instance.currentUid);
          final txs = _filterTransactions(allTransactions);
          
          double totalSpent = 0;
          Map<String, double> categorySums = {};
          for (var t in txs) {
            final amount = (t['amount'] as num?)?.toDouble() ?? 0.0;
            final cat = (t['title'] as String?) ?? 'Other';
            totalSpent += amount;
            categorySums[cat] = (categorySums[cat] ?? 0.0) + amount;
          }
          
          final sortedCategories = categorySums.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));
          
          final name = AuthService.instance.currentUser?.displayName?.split(' ').first ?? 'User';
          final topCategory = sortedCategories.isNotEmpty ? sortedCategories.first.key : 'general';
          final smartInsight = 'Hey $name, you spent the most on $topCategory this ${_selectedPeriod.toLowerCase()}. Consider reviewing your budget to stay on track.';
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPeriodSelector(),
                const SizedBox(height: 32),
                _buildMonthlyReportHeader(),
                const SizedBox(height: 40),
                Center(child: _buildDonutChart(totalSpent, sortedCategories)),
                const SizedBox(height: 40),
                _buildSmartInsightCard(smartInsight),
                const SizedBox(height: 32),
                _buildBreakdownList(totalSpent, sortedCategories),
                const SizedBox(height: 40),
              ],
            ),
          );
        }
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
          _buildPeriodButton('Week'),
          _buildPeriodButton('Month'),
          _buildPeriodButton('Year'),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(String label) {
    final isSelected = _selectedPeriod == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPeriod = label),
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
      ),
    );
  }

  Widget _buildMonthlyReportHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$_selectedPeriod Report', style: AppTheme.headingStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(_getPeriodSubtitle(), style: TextStyle(color: Colors.grey[500], fontSize: 14)),
      ],
    );
  }

  Widget _buildDonutChart(double total, List<MapEntry<String, double>> categories) {
    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(200, 200),
            painter: DonutChartPainter(total, categories),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Total Spent', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              Text(CurrencyService.instance.format(total), style: AppTheme.headingStyle(fontSize: 24)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmartInsightCard(String insight) {
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
            insight,
            style: TextStyle(color: Colors.grey[800], fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownList(double total, List<MapEntry<String, double>> categories) {
    final colors = [
      Colors.teal[400],
      Colors.orange[400],
      Colors.blue[400],
      Colors.purple[400],
      Colors.brown[400],
      Colors.pink[400],
    ];
    
    return Column(
      children: categories.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        final color = colors[index % colors.length];
        final percent = total > 0 ? (item.value / total * 100).toStringAsFixed(0) : '0';
        
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
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.key, style: AppTheme.headingStyle(fontSize: 15)),
                    Text('$percent% of total spending', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(CurrencyService.instance.format(item.value), style: AppTheme.dataStyle(fontSize: 15, fontWeight: FontWeight.bold)),
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
  final double total;
  final List<MapEntry<String, double>> categories;
  
  DonutChartPainter(this.total, this.categories);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 25.0;
    final rect = Rect.fromCircle(center: center, radius: radius - (strokeWidth / 2));

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
      
    if (total == 0 || categories.isEmpty) {
      paint.color = Colors.grey[200]!;
      canvas.drawArc(rect, 0, 2 * math.pi, false, paint);
      return;
    }

    final colors = [
      Colors.teal[400],
      Colors.orange[400],
      Colors.blue[400],
      Colors.purple[400],
      Colors.brown[400],
      Colors.pink[400],
    ];

    double startAngle = -math.pi / 2;
    for (int i = 0; i < categories.length; i++) {
      final item = categories[i];
      final sweepAngle = (item.value / total) * 2 * math.pi;
      paint.color = colors[i % colors.length]!;
      canvas.drawArc(rect, startAngle + 0.05, sweepAngle - 0.1, false, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant DonutChartPainter oldDelegate) {
    return oldDelegate.total != total || oldDelegate.categories != categories;
  }
}
