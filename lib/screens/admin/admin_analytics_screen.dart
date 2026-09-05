import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/firestore_service.dart';

class AdminAnalyticsScreen extends StatefulWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  State<AdminAnalyticsScreen> createState() => _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends State<AdminAnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;
  StreamSubscription? _userSub, _txSub;

  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _transactions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);

    _userSub = FirestoreService.instance.streamAllUsers().listen((u) {
      if (!mounted) return;
      setState(() { _users = u; if (!_loading || _transactions.isNotEmpty) _loading = false; });
      _fadeCtrl.forward();
    });
    _txSub = FirestoreService.instance.streamAllTransactions(limit: 200).listen((txs) {
      if (!mounted) return;
      setState(() { _transactions = txs; _loading = false; });
      _fadeCtrl.forward();
    });
  }

  @override
  void dispose() { _fadeCtrl.dispose(); _userSub?.cancel(); _txSub?.cancel(); super.dispose(); }

  double _normalizeToJmd(double amount, String? currency) {
    if (currency == null) return amount;
    switch (currency.toUpperCase()) {
      case 'USD': return amount * 155.0;
      case 'GBP': return amount * 195.0;
      case 'CAD': return amount * 115.0;
      case 'JMD':
      default:
        return amount;
    }
  }

  // Daily transaction volume (last 7 days)
  List<BarChartGroupData> _buildBarGroups() {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      final dayStr = '${day.year}-${day.month.toString().padLeft(2,'0')}-${day.day.toString().padLeft(2,'0')}';
      final vol = _transactions
          .where((t) => (t['createdAt'] as String? ?? '').startsWith(dayStr))
          .fold<double>(0, (sum, t) {
            final amt = (t['amount'] as num?)?.toDouble().abs() ?? 0;
            final currency = t['currency'] as String?;
            return sum + _normalizeToJmd(amt, currency);
          });
      return BarChartGroupData(x: i, barRods: [
        BarChartRodData(
          toY: vol > 0 ? vol : 0.5,
          gradient: const LinearGradient(
            colors: [AppColors.kinTealLight, AppColors.kinTeal],
            begin: Alignment.bottomCenter, end: Alignment.topCenter,
          ),
          width: 16, borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
        ),
      ]);
    });
  }

  // User registrations last 14 days
  List<FlSpot> _buildLineSpots() {
    final now = DateTime.now();
    return List.generate(14, (i) {
      final day = now.subtract(Duration(days: 13 - i));
      final dayStr = '${day.year}-${day.month.toString().padLeft(2,'0')}-${day.day.toString().padLeft(2,'0')}';
      final count = _users.where((u) {
        final created = u['createdAt'] as String? ?? u['updatedAt'] as String? ?? '';
        return created.startsWith(dayStr);
      }).length;
      return FlSpot(i.toDouble(), count.toDouble());
    });
  }

  // KYC distribution
  Map<String, int> _kycDistribution() {
    final verified = _users.where((u) => u['kycStatus'] == 'verified').length;
    final pending = _users.where((u) => u['kycStatus'] == 'pending' || u['kycStatus'] == 'submitted').length;
    final flagged = _users.where((u) => u['kycStatus'] == 'flagged').length;
    final other = _users.length - verified - pending - flagged;
    return {'Verified': verified, 'Pending': pending, 'Flagged': flagged, if (other > 0) 'Other': other};
  }

  // Day label
  String _dayLabel(int i) {
    final now = DateTime.now();
    final day = now.subtract(Duration(days: 6 - i));
    const days = ['Mo','Tu','We','Th','Fr','Sa','Su'];
    return days[day.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? const Center(child: CircularProgressIndicator(color: AppColors.kinTeal))
        : FadeTransition(
            opacity: _fadeAnim,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Analytics', style: AppTheme.headingStyle(fontSize: 26)),
                  const SizedBox(height: 8),
                  Text('Live from Firestore — last updated now', style: AppTheme.bodyStyle(fontSize: 13, color: Colors.grey[400]!)),
                  const SizedBox(height: 28),
                  _buildTxVolumeChart(),
                  const SizedBox(height: 24),
                  LayoutBuilder(builder: (ctx, box) {
                    final isWide = box.maxWidth > 700;
                    return isWide
                        ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Expanded(child: _buildUserGrowthChart()),
                            const SizedBox(width: 20),
                            Expanded(child: _buildKycDonut()),
                          ])
                        : Column(children: [
                            _buildUserGrowthChart(),
                            const SizedBox(height: 24),
                            _buildKycDonut(),
                          ]);
                  }),
                  const SizedBox(height: 24),
                  _buildSummaryStats(),
                ],
              ),
            ),
          );
  }

  Widget _buildChartCard({required String title, required String subtitle, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 20, offset: const Offset(0,6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTheme.headingStyle(fontSize: 16)),
          const SizedBox(height: 2),
          Text(subtitle, style: AppTheme.bodyStyle(fontSize: 12, color: Colors.grey[400]!)),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }

  Widget _buildTxVolumeChart() {
    final groups = _buildBarGroups();
    return _buildChartCard(
      title: 'Transaction Volume',
      subtitle: 'Last 7 days',
      child: SizedBox(
        height: 200,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: groups.fold<double>(10, (m, g) => g.barRods.first.toY > m ? g.barRods.first.toY * 1.2 : m),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (_) => FlLine(color: const Color(0xFFF0F4F3), strokeWidth: 1),
            ),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (v, _) => Text('\$${v.toInt()}',
                    style: GoogleFonts.jetBrainsMono(fontSize: 9, color: Colors.grey[400])),
              )),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, _) => Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(_dayLabel(v.toInt()),
                      style: GoogleFonts.manrope(fontSize: 11, color: Colors.grey[500], fontWeight: FontWeight.w600)),
                ),
              )),
            ),
            barGroups: groups,
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem(
                  '\$${rod.toY.toStringAsFixed(0)}',
                  GoogleFonts.jetBrainsMono(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserGrowthChart() {
    final spots = _buildLineSpots();
    return _buildChartCard(
      title: 'User Growth',
      subtitle: 'New registrations — last 14 days',
      child: SizedBox(
        height: 180,
        child: LineChart(LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(color: const Color(0xFFF0F4F3), strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(
              showTitles: true, reservedSize: 28,
              getTitlesWidget: (v, _) => Text(v.toInt().toString(),
                  style: GoogleFonts.jetBrainsMono(fontSize: 9, color: Colors.grey[400])),
            )),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              gradient: const LinearGradient(colors: [AppColors.kinTeal, AppColors.kinTealLight]),
              barWidth: 3,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, _, _, _) => FlDotCirclePainter(
                  radius: 3, color: AppColors.kinTeal,
                  strokeWidth: 2, strokeColor: Colors.white,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [AppColors.kinTeal.withValues(alpha: 0.20), AppColors.kinTeal.withValues(alpha: 0.0)],
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        )),
      ),
    );
  }

  Widget _buildKycDonut() {
    final dist = _kycDistribution();
    final total = dist.values.fold(0, (a, b) => a + b);
    final colors = [AppColors.kinTeal, const Color(0xFFF59E0B), AppColors.kinCoral, Colors.grey];
    final keys = dist.keys.toList();

    return _buildChartCard(
      title: 'KYC Status',
      subtitle: 'Distribution across all users',
      child: total == 0
          ? const Center(child: Text('No data yet'))
          : Column(children: [
              SizedBox(
                height: 160,
                child: PieChart(PieChartData(
                  sections: List.generate(keys.length, (i) {
                    final val = dist[keys[i]]!;
                    return PieChartSectionData(
                      value: val.toDouble(),
                      color: colors[i % colors.length],
                      radius: 50,
                      title: val > 0 ? val.toString() : '',
                      titleStyle: GoogleFonts.manrope(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                    );
                  }),
                  centerSpaceRadius: 40,
                  sectionsSpace: 3,
                )),
              ),
              const SizedBox(height: 16),
              Wrap(spacing: 16, runSpacing: 8,
                children: List.generate(keys.length, (i) => Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(width: 10, height: 10, decoration: BoxDecoration(color: colors[i % colors.length], shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  Text(keys[i], style: AppTheme.bodyStyle(fontSize: 12, color: Colors.grey[600]!)),
                ])),
              ),
            ]),
    );
  }

  Widget _buildSummaryStats() {
    final totalTxVol = _transactions.fold<double>(0, (s, t) => s + ((t['amount'] as num?)?.toDouble().abs() ?? 0));
    final avgPerUser = _users.isEmpty ? 0.0 : totalTxVol / _users.length;
    final txPerUser = _users.isEmpty ? 0.0 : _transactions.length / _users.length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.kinInk, const Color(0xFF2B3230)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(children: [
        _stat('Total Volume', '\$${(totalTxVol / 1000).toStringAsFixed(1)}k', Colors.white, const Color(0xFF4AFF9E)),
        _divider(),
        _stat('Avg per User', '\$${avgPerUser.toStringAsFixed(0)}', Colors.white, AppColors.kinCoralLight),
        _divider(),
        _stat('Tx per User', txPerUser.toStringAsFixed(1), Colors.white, const Color(0xFFFFC947)),
      ]),
    );
  }

  Widget _stat(String label, String value, Color textColor, Color valueColor) {
    return Expanded(child: Column(children: [
      Text(value, style: GoogleFonts.jetBrainsMono(fontSize: 20, fontWeight: FontWeight.bold, color: valueColor)),
      const SizedBox(height: 4),
      Text(label, style: AppTheme.bodyStyle(fontSize: 11, color: Colors.white60), textAlign: TextAlign.center),
    ]));
  }

  Widget _divider() => Container(width: 1, height: 40, color: Colors.white12);
}
