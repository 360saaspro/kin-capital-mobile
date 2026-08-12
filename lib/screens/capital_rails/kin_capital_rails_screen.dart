// Kin Capital Rails — credit & remittance intelligence dashboard
// Wired to the FastAPI backend. Shows: credit score, risk factors,
// recommended working capital limit, cheapest remittance route.

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../models/api_models.dart';
import '../../services/api_service.dart';

class KinCapitalRailsScreen extends StatefulWidget {
  final String entityId;
  const KinCapitalRailsScreen({super.key, required this.entityId});

  @override
  State<KinCapitalRailsScreen> createState() => _KinCapitalRailsScreenState();
}

class _KinCapitalRailsScreenState extends State<KinCapitalRailsScreen> {
  final _api = ApiService();

  bool _loading = true;
  String? _error;
  CreditOffer? _credit;
  RiskScore? _risk;
  RouteResult? _route;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        _api.creditOffer(widget.entityId, requestedAmount: 50000),
        _api.riskScore(widget.entityId),
        _api.routeTransfer(
          fromEntity: widget.entityId,
          toEntity: 'recipient_001',
          amount: 500,
        ),
      ]);
      setState(() {
        _credit = results[0] as CreditOffer;
        _risk = results[1] as RiskScore;
        _route = results[2] as RouteResult;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 245, 251, 248),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Kin Capital Rails',
          style: AppTheme.headingStyle(fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _buildError()
          : RefreshIndicator(
              onRefresh: _load,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCreditScoreCard(),
                    const SizedBox(height: 20),
                    _buildRiskFactorsCard(),
                    const SizedBox(height: 20),
                    _buildRouteCard(),
                    const SizedBox(height: 20),
                    _buildOrchestrateButton(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 48, color: AppColors.kinCoral),
            const SizedBox(height: 16),
            Text(
              'Could not connect to Kin Capital Rails API',
              style: AppTheme.bodyStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.from(
                  alpha: 1,
                  red: 0,
                  green: 0.416,
                  blue: 0.38,
                ),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreditScoreCard() {
    final c = _credit!;
    final scorePct = (c.creditScore / 850).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Cash-Flow Credit Score',
                style: AppTheme.bodyStyle(color: Colors.white70, fontSize: 14),
              ),
              if (c.escalated)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.kinCoral,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'ESCALATED',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                c.creditScore.toStringAsFixed(0),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                '/ 850',
                style: TextStyle(color: Colors.white54, fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: scorePct,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Recommended limit: \$${c.recommendedLimit.toStringAsFixed(0)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            c.explanation,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              height: 1.4,
            ),
          ),
          if (c.escalated && c.escalationReason.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.kinCoral.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      c.escalationReason,
                      style: const TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRiskFactorsCard() {
    final r = _risk!;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Risk Assessment',
                style: AppTheme.headingStyle(fontSize: 18),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: r.riskScore < 0.3
                      ? Colors.green.withValues(alpha: 0.1)
                      : r.riskScore < 0.6
                      ? Colors.orange.withValues(alpha: 0.1)
                      : Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${(r.riskScore * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: r.riskScore < 0.3
                        ? Colors.green
                        : r.riskScore < 0.6
                        ? Colors.orange
                        : Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Model: ${r.modelVersion}',
            style: AppTheme.bodyStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          ...r.features.entries
              .take(5)
              .map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(Icons.circle, size: 8, color: AppColors.primaryTeal),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _featureLabel(e.key),
                          style: AppTheme.bodyStyle(
                            fontSize: 13,
                            color: AppColors.kinDeep,
                          ),
                        ),
                      ),
                      Text(
                        (e.value as num).toStringAsFixed(4),
                        style: AppTheme.dataStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }

  String _featureLabel(String key) {
    const labels = {
      'income_regularity': 'Income Regularity',
      'remittance_dependency': 'Remittance Dependency',
      'seasonality': 'Seasonality Score',
      'avg_monthly_volume': 'Avg Monthly Volume',
      'txn_count': 'Transaction Count',
      'months_of_history': 'Months of History',
    };
    return labels[key] ?? key.replaceAll('_', ' ');
  }

  Widget _buildRouteCard() {
    final r = _route!;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Cheapest Route',
                style: AppTheme.headingStyle(fontSize: 18),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bolt, size: 14, color: Colors.green),
                    const SizedBox(width: 4),
                    Text(
                      '${r.feePct.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.route, size: 20, color: AppColors.primaryTeal),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  r.selectedRoute,
                  style: AppTheme.bodyStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildRouteDetail('Amount', '\$${r.amount.toStringAsFixed(0)}'),
              _buildRouteDetail('Fee', '\$${r.fee.toStringAsFixed(2)}'),
              _buildRouteDetail('ETA', r.eta),
            ],
          ),
          if (r.alternatives.isNotEmpty) ...[
            const Divider(height: 32),
            Text(
              'Alternatives',
              style: AppTheme.bodyStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            ...r.alternatives
                .take(3)
                .map(
                  (a) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.swap_horiz,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            a['route']?.toString() ?? '',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        Text(
                          '${a['fee_pct']}%',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          ],
        ],
      ),
    );
  }

  Widget _buildRouteDetail(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.bodyStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTheme.dataStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildOrchestrateButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () async {
          try {
            final result = await _api.orchestrate(widget.entityId);
            if (!mounted) return;
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Orchestration Result'),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (result.llmReasoning != null) ...[
                        Text(
                          'Reasoning:',
                          style: AppTheme.bodyStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          result.llmReasoning!,
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(height: 16),
                      ],
                      Text(
                        'Plan:',
                        style: AppTheme.bodyStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ...result.plan.map(
                        (p) =>
                            Text('• $p', style: const TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          } catch (e) {
            if (!mounted) return;
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Orchestration failed: $e')));
          }
        },
        icon: const Icon(Icons.psychology, color: AppColors.primaryTeal),
        label: const Text(
          'Run Full Orchestration',
          style: TextStyle(
            color: AppColors.primaryTeal,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.primaryTeal),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}
