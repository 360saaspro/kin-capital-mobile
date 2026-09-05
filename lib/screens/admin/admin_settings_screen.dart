import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../models/api_models.dart';

class AdminSettingsScreen extends StatefulWidget {
  final String? entityId;
  const AdminSettingsScreen({super.key, this.entityId});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  final _api = ApiService();
  HealthStatus? _health;
  bool _healthLoading = true;
  bool _orchestrating = false;
  OrchestrationResult? _orchResult;

  @override
  void initState() {
    super.initState();
    _fetchHealth();
  }

  Future<void> _fetchHealth() async {
    setState(() => _healthLoading = true);
    try {
      final h = await _api.health();
      if (mounted) setState(() { _health = h; _healthLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _healthLoading = false);
    }
  }

  Future<void> _runOrchestration() async {
    setState(() {
      _orchestrating = true;
      _orchResult = null;
    });
    try {
      final result = await _api.orchestrate(widget.entityId ?? 'admin');
      if (mounted) setState(() { _orchResult = result; _orchestrating = false; });
    } catch (e, st) {
      if (mounted) {
        setState(() => _orchestrating = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Settings', style: AppTheme.headingStyle(fontSize: 26)),
          const SizedBox(height: 6),
          Text('System configuration and API tools', style: AppTheme.bodyStyle(fontSize: 13, color: Colors.grey[400]!)),
          const SizedBox(height: 28),
          _buildApiHealthCard(),
          const SizedBox(height: 20),
          _buildOrchestrationCard(),
          const SizedBox(height: 20),
          _buildAppInfoCard(),
        ],
      ),
    );
  }

  Widget _buildApiHealthCard() {
    final isOk = _health?.status == 'ok' || _health?.modelLoaded == true;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 20, offset: const Offset(0,6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _healthLoading ? AppColors.kinMist : (isOk ? const Color(0xFFE6F7F5) : const Color(0xFFFFEDEC)),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: (_healthLoading ? Colors.grey : (isOk ? AppColors.kinTeal : AppColors.kinCoral)).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: _healthLoading
                    ? const Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.kinTeal))
                    : Icon(isOk ? Icons.check_circle_rounded : Icons.error_rounded,
                        color: isOk ? AppColors.kinTeal : AppColors.kinCoral, size: 22),
              ),
              const SizedBox(width: 14),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('API Status', style: AppTheme.headingStyle(fontSize: 16)),
                Text(
                  _healthLoading ? 'Checking...' : (isOk ? 'All systems operational' : 'Service degraded'),
                  style: AppTheme.bodyStyle(fontSize: 13, color: isOk ? AppColors.kinTeal : AppColors.kinCoral),
                ),
              ]),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh_rounded, color: AppColors.kinTeal),
                onPressed: _fetchHealth,
              ),
            ]),
          ),
          if (_health != null)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(children: [
                _infoRow('Service', _health!.service),
                _infoRow('Model', _health!.impalaModel),
                _infoRow('Mode', _health!.orchestratorMode),
                _infoRow('Model Loaded', _health!.modelLoaded ? 'Yes' : 'No'),
              ]),
            ),
        ],
      ),
    );
  }

  Widget _buildOrchestrationCard() {
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
          Row(children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: AppColors.kinTeal.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: const Icon(Icons.psychology_rounded, color: AppColors.kinTeal, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('AI Orchestration', style: AppTheme.headingStyle(fontSize: 16)),
              Text('Full agentic loop — perceive → reason → act', style: AppTheme.bodyStyle(fontSize: 12, color: Colors.grey[400]!)),
            ])),
          ]),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _orchestrating ? null : _runOrchestration,
              icon: _orchestrating
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.play_arrow_rounded),
              label: Text(_orchestrating ? 'Running...' : 'Run Full Orchestration'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.kinTeal, foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
            ),
          ),
          if (_orchResult != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.kinMist, borderRadius: BorderRadius.circular(14)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Result', style: AppTheme.bodyStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (_orchResult!.llmReasoning != null)
                  Text(_orchResult!.llmReasoning!, style: AppTheme.bodyStyle(fontSize: 12, color: Colors.grey[700]!)),
                const SizedBox(height: 8),
                ..._orchResult!.plan.map((p) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(children: [
                    const Icon(Icons.check_rounded, size: 14, color: AppColors.kinTeal),
                    const SizedBox(width: 6),
                    Text(p, style: AppTheme.bodyStyle(fontSize: 12)),
                  ]),
                )),
              ]),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAppInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF004D46), AppColors.kinTeal],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), shape: BoxShape.circle, border: Border.all(color: Colors.white24)),
            padding: const EdgeInsets.all(8),
            child: Image.asset('assets/images/kin_logo.png', fit: BoxFit.contain),
          ),
          const SizedBox(width: 14),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Kin Banking Platform', style: AppTheme.headingStyle(fontSize: 16, color: Colors.white)),
            Text('Admin Control Centre v1.0', style: AppTheme.bodyStyle(fontSize: 12, color: Colors.white60)),
          ]),
        ]),
        const SizedBox(height: 20),
        _infoRowLight('Version', '1.0.0+1'),
        _infoRowLight('Environment', 'Production'),
        _infoRowLight('API Endpoint', ApiService().baseUrl),
        _infoRowLight('Region', 'Caribbean / LATAM'),
      ]),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [
        SizedBox(width: 120, child: Text(label, style: AppTheme.bodyStyle(fontSize: 13, color: Colors.grey[500]!))),
        Expanded(child: Text(value, style: GoogleFonts.jetBrainsMono(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.kinInk))),
      ]),
    );
  }

  Widget _infoRowLight(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [
        SizedBox(width: 120, child: Text(label, style: AppTheme.bodyStyle(fontSize: 12, color: Colors.white60))),
        Expanded(child: Text(value, style: GoogleFonts.jetBrainsMono(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
            maxLines: 1, overflow: TextOverflow.ellipsis)),
      ]),
    );
  }
}
