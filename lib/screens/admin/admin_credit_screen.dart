import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/firestore_service.dart';
import '../../services/api_service.dart';
import '../../models/api_models.dart';

class AdminCreditScreen extends StatefulWidget {
  const AdminCreditScreen({super.key});

  @override
  State<AdminCreditScreen> createState() => _AdminCreditScreenState();
}

class _AdminCreditScreenState extends State<AdminCreditScreen> with SingleTickerProviderStateMixin {
  final ApiService _api = ApiService();
  late TabController _tabController;
  
  StreamSubscription? _usersSub;
  List<Map<String, dynamic>> _users = [];
  
  StreamSubscription? _settingsSub;


  // Assess Tab State
  Map<String, dynamic>? _selectedUser;
  String _searchQuery = '';
  bool _loading = false;
  CreditOffer? _offer;
  RiskScore? _risk;
  OrchestrationResult? _orchestration;
  LedgerResponse? _ledger;

  // Settings Tab State
  final _minScoreController = TextEditingController();
  final _maxLimitController = TextEditingController();
  bool _enableLlm = true;
  bool _savingSettings = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    _usersSub = FirestoreService.instance.streamAllUsers().listen((users) {
      if (mounted) setState(() => _users = users);
    });
    
    _settingsSub = FirestoreService.instance.streamAgenticCreditSettings().listen((settings) {
      if (mounted && settings != null) {
        setState(() {
          _minScoreController.text = (settings['minAutoApproveScore'] ?? 700).toString();
          _maxLimitController.text = (settings['maxAutoApproveLimit'] ?? 5000).toString();
          _enableLlm = settings['enableLlmReasoning'] ?? true;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _usersSub?.cancel();
    _settingsSub?.cancel();
    _minScoreController.dispose();
    _maxLimitController.dispose();
    super.dispose();
  }

  String _getCurrencySymbol(String? c) {
    if (c == null) return '\$';
    switch (c.toUpperCase()) {
      case 'JMD': return 'J\$';
      case 'USD': return 'US\$';
      case 'GBP': return '£';
      case 'CAD': return 'CA\$';
      default: return '\$';
    }
  }

  double _toDouble(dynamic val) {
    if (val == null) return 0.0;
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val) ?? 0.0;
    return 0.0;
  }

  Future<void> _runAssessment(String entityId) async {
    setState(() {
      _loading = true;
      _offer = null;
      _risk = null;
      _orchestration = null;
      _ledger = null;
    });

    try {
      final futures = await Future.wait([
        _api.creditOffer(entityId),
        _api.riskScore(entityId),
        if (_enableLlm) _api.orchestrate(entityId, intent: 'assess credit worthiness') else Future.value(null),
      ]);
      final ledgerData = await _api.ledger(entityId);
      
      if (!mounted) return;
      setState(() {
        _offer = futures[0] as CreditOffer;
        _risk = futures[1] as RiskScore;
        _orchestration = futures.length > 2 ? futures[2] as OrchestrationResult? : null;
        _ledger = ledgerData;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Assessment failed: $e'),
        backgroundColor: AppColors.kinCoral,
      ));
    }
  }

  void _approveOffer() async {
    if (_selectedUser == null || _offer == null) return;
    final uid = _selectedUser!['id'] as String? ?? _selectedUser!['uid'] as String?;
    if (uid == null) return;
    
    await FirestoreService.instance.updateCreditProfile(uid, {
      'status': 'approved',
      'score': _offer!.creditScore,
      'limit': _offer!.recommendedLimit,
      'approvedAt': DateTime.now().toIso8601String(),
    });
    
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Credit limit approved.'),
      backgroundColor: AppColors.kinTeal,
    ));
    setState(() => _selectedUser = null);
  }

  void _rejectOffer() async {
    if (_selectedUser == null || _offer == null) return;
    final uid = _selectedUser!['id'] as String? ?? _selectedUser!['uid'] as String?;
    if (uid == null) return;
    
    await FirestoreService.instance.updateCreditProfile(uid, {
      'status': 'rejected',
      'score': _offer!.creditScore,
      'rejectedAt': DateTime.now().toIso8601String(),
    });
    
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Credit limit rejected.'),
      backgroundColor: AppColors.kinCoral,
    ));
    setState(() => _selectedUser = null);
  }

  Future<void> _saveSettings() async {
    setState(() => _savingSettings = true);
    await FirestoreService.instance.updateAgenticCreditSettings({
      'minAutoApproveScore': int.tryParse(_minScoreController.text) ?? 700,
      'maxAutoApproveLimit': int.tryParse(_maxLimitController.text) ?? 5000,
      'enableLlmReasoning': _enableLlm,
    });
    if (!mounted) return;
    setState(() => _savingSettings = false);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Settings saved successfully.'),
      backgroundColor: AppColors.kinTeal,
    ));
  }

  void _showDecisionDetails(Map<String, dynamic> user) {
    final uid = user['id'] as String? ?? user['uid'] as String?;
    if (uid == null) return;
    
    final cp = user['creditProfile'];
    final name = user['fullName'] as String? ?? 'Unknown';
    final initialLimit = _toDouble(cp['limit']);
    
    final limitController = TextEditingController(text: initialLimit.toStringAsFixed(0));
    bool isLoading = true;
    LedgerResponse? ledger;
    OrchestrationResult? orchestration;
    String? error;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            if (isLoading && ledger == null) {
              _api.orchestrate(uid, intent: 'assess credit worthiness').then((orchResult) {
                return _api.ledger(uid).then((ledgResult) {
                  if (mounted) {
                    setModalState(() {
                      ledger = ledgResult;
                      orchestration = orchResult;
                      isLoading = false;
                    });
                  }
                });
              }).catchError((e) {
                if (mounted) {
                  setModalState(() {
                    error = e.toString();
                    isLoading = false;
                  });
                }
              });
            }

            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFFF9FAFA),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Credit Decision: $name', style: AppTheme.headingStyle(fontSize: 18)),
                      IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                    ],
                  ),
                  const Divider(),
                  if (isLoading)
                    const Expanded(child: Center(child: CircularProgressIndicator(color: AppColors.kinTeal)))
                  else if (error != null)
                    Expanded(child: Center(child: Text('Error: $error', style: const TextStyle(color: AppColors.kinCoral))))
                  else
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),
                            if (orchestration != null) ...[
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.grey[200]!),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.psychology_rounded, color: AppColors.kinTeal, size: 20),
                                        const SizedBox(width: 8),
                                        Text('Agentic Reasoning', style: AppTheme.headingStyle(fontSize: 16)),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(orchestration!.llmReasoning ?? 'No reasoning available.', style: AppTheme.bodyStyle(fontSize: 14)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                            if (ledger != null && ledger!.entries.isNotEmpty) ...[
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.grey[200]!),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.list_alt_rounded, color: AppColors.kinTeal, size: 20),
                                        const SizedBox(width: 8),
                                        Text('Recent Transactions', style: AppTheme.headingStyle(fontSize: 16)),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    ...ledger!.entries.take(5).map((e) => Padding(
                                      padding: const EdgeInsets.only(bottom: 12),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(color: AppColors.kinMist, borderRadius: BorderRadius.circular(8)),
                                            child: const Icon(Icons.swap_horiz_rounded, size: 16, color: AppColors.kinTeal),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(e.eventType, style: AppTheme.bodyStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                                Text(e.counterparty, style: AppTheme.bodyStyle(fontSize: 11, color: Colors.grey[500]!)),
                                              ],
                                            ),
                                          ),
                                          Text('${_getCurrencySymbol(e.currency)}${e.amount.toStringAsFixed(0)}', style: GoogleFonts.jetBrainsMono(fontSize: 13, fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    )),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey[200]!),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.edit_note_rounded, color: AppColors.kinTeal, size: 20),
                                      const SizedBox(width: 8),
                                      Text('Edit Credit Limit', style: AppTheme.headingStyle(fontSize: 16)),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  TextField(
                                    controller: limitController,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText: 'Credit Limit',
                                      prefixText: '\$ ',
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        final newLimit = double.tryParse(limitController.text);
                                        if (newLimit != null) {
                                          await FirestoreService.instance.updateCreditProfile(uid, {
                                            'limit': newLimit,
                                          });
                                          if (context.mounted) {
                                            Navigator.pop(context);
                                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                              content: Text('Credit limit updated successfully.'),
                                              backgroundColor: AppColors.kinTeal,
                                            ));
                                          }
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.kinTeal,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                      child: const Text('Save Limit', style: TextStyle(fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Agentic Credit', style: AppTheme.headingStyle(fontSize: 22)),
            ],
          ),
        ),
        TabBar(
          controller: _tabController,
          labelColor: AppColors.kinTeal,
          unselectedLabelColor: Colors.grey[600],
          indicatorColor: AppColors.kinTeal,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Assess'),
            Tab(text: 'Settings'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(),
              _buildAssessTab(),
              _buildSettingsTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewTab() {
    final creditUsers = _users.where((u) => u['creditProfile'] != null).toList();
    final approvedUsers = creditUsers.where((u) => u['creditProfile']['status'] == 'approved').toList();
    
    final totalLimits = approvedUsers.fold<double>(0.0, (sum, u) => sum + _toDouble(u['creditProfile']['limit']));
    final totalScores = approvedUsers.fold<double>(0.0, (sum, u) => sum + _toDouble(u['creditProfile']['score']));
    final avgScore = approvedUsers.isEmpty ? 0.0 : totalScores / approvedUsers.length;

    creditUsers.sort((a, b) {
      final aDate = a['creditProfile']['approvedAt'] ?? a['creditProfile']['rejectedAt'] ?? '';
      final bDate = b['creditProfile']['approvedAt'] ?? b['creditProfile']['rejectedAt'] ?? '';
      return (bDate as String).compareTo(aDate as String);
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _buildStatCard('Active Lines', approvedUsers.length.toString(), Icons.people_outline)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard('Total Exposure', '\$${totalLimits.toStringAsFixed(0)}', Icons.monetization_on_outlined)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard('Avg Score', avgScore.toStringAsFixed(0), Icons.speed_outlined)),
            ],
          ),
          const SizedBox(height: 32),
          Text('Recent Decisions', style: AppTheme.headingStyle(fontSize: 18)),
          const SizedBox(height: 16),
          if (creditUsers.isEmpty)
            Center(child: Padding(
              padding: const EdgeInsets.all(40),
              child: Text('No credit decisions yet.', style: AppTheme.bodyStyle(color: Colors.grey)),
            ))
          else
            ...creditUsers.map((u) {
              final cp = u['creditProfile'];
              final status = cp['status'] as String? ?? 'approved';
              final limit = _toDouble(cp['limit']);
              final name = u['fullName'] as String? ?? 'Unknown';
              final isApprove = status == 'approved';
              
              return GestureDetector(
                onTap: () => _showDecisionDetails(u),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: isApprove ? AppColors.kinTeal.withValues(alpha: 0.1) : AppColors.kinCoral.withValues(alpha: 0.1),
                      child: Icon(isApprove ? Icons.check_rounded : Icons.close_rounded, 
                        color: isApprove ? AppColors.kinTeal : AppColors.kinCoral),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: AppTheme.bodyStyle(fontWeight: FontWeight.bold)),
                          Text(isApprove ? 'Approved for \$${limit.toStringAsFixed(0)}' : 'Rejected', 
                            style: AppTheme.bodyStyle(fontSize: 12, color: Colors.grey[600]!)),
                        ],
                      ),
                    ),
                    Text(cp['score']?.toString() ?? '-', style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.bold, color: AppColors.kinInk)),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.kinTeal, size: 24),
          const SizedBox(height: 12),
          Text(value, style: GoogleFonts.jetBrainsMono(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(title, style: AppTheme.bodyStyle(fontSize: 12, color: Colors.grey[600]!)),
        ],
      ),
    );
  }

  Widget _buildAssessTab() {
    return Column(
      children: [
        if (_selectedUser == null) ...[
          Padding(
            padding: const EdgeInsets.all(20),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search user by name or email',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: _users.where((u) {
                if (_searchQuery.isEmpty) return true;
                final name = (u['fullName'] as String? ?? '').toLowerCase();
                final email = (u['email'] as String? ?? '').toLowerCase();
                return name.contains(_searchQuery) || email.contains(_searchQuery);
              }).map((u) {
                final name = u['fullName'] as String? ?? 'Unknown';
                final email = u['email'] as String? ?? '';
                final hasCredit = u['creditProfile'] != null;
                return ListTile(
                  title: Text(name, style: AppTheme.bodyStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(email, style: AppTheme.bodyStyle(fontSize: 12)),
                  trailing: hasCredit ? const Icon(Icons.check_circle, color: AppColors.kinTeal) : const Icon(Icons.arrow_forward_ios, size: 14),
                  onTap: () {
                    setState(() => _selectedUser = u);
                    final uid = u['id'] as String? ?? u['uid'] as String?;
                    if (uid != null) _runAssessment(uid);
                  },
                );
              }).toList(),
            ),
          ),
        ] else ...[
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => setState(() => _selectedUser = null),
                ),
                const SizedBox(width: 8),
                Text('Assessing: ${_selectedUser!['fullName'] ?? 'Unknown'}', style: AppTheme.headingStyle(fontSize: 18)),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_loading)
                    const Center(child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(color: AppColors.kinTeal),
                    ))
                  else if (_offer != null) ...[
                    _buildCreditCard(),
                    const SizedBox(height: 20),
                    if (_enableLlm && _orchestration != null) _buildReasoningCard(),
                    const SizedBox(height: 20),
                    if (_ledger != null && _ledger!.entries.isNotEmpty) _buildLedgerCard(),
                  ],
                ],
              ),
            ),
          ),
        ]
      ],
    );
  }

  Widget _buildCreditCard() {
    final bool isApproved = _selectedUser != null && 
        _selectedUser!['creditProfile'] != null && 
        _selectedUser!['creditProfile']['status'] == 'approved';
        
    final double limit = isApproved 
        ? _toDouble(_selectedUser!['creditProfile']['limit']) 
        : _offer!.recommendedLimit;
        
    final int score = isApproved && _selectedUser!['creditProfile']['score'] != null
        ? _toDouble(_selectedUser!['creditProfile']['score']).toInt()
        : _offer!.creditScore.toInt();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF004D46), AppColors.kinTeal],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppColors.kinTeal.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.monetization_on_rounded, color: Colors.white, size: 24),
              const SizedBox(width: 8),
              Text(isApproved ? 'Current Credit Limit' : 'Recommended Credit Limit', style: AppTheme.headingStyle(fontSize: 16, color: Colors.white)),
              const Spacer(),
              if (_offer!.escalated && !isApproved)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.kinCoral, borderRadius: BorderRadius.circular(8)),
                  child: Text('ESCALATED', style: AppTheme.bodyStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text('\$${limit.toStringAsFixed(0)}', style: GoogleFonts.jetBrainsMono(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildStat('Credit Score', score.toString()),
              Container(width: 1, height: 40, color: Colors.white24, margin: const EdgeInsets.symmetric(horizontal: 20)),
              _buildStat('Risk Score', '${(_risk!.riskScore * 100).toStringAsFixed(1)}%'),
              Container(width: 1, height: 40, color: Colors.white24, margin: const EdgeInsets.symmetric(horizontal: 20)),
              _buildStat('Model', _risk!.modelVersion),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 16),
          Text(_offer!.explanation, style: AppTheme.bodyStyle(fontSize: 14, color: Colors.white70)),
          if (!isApproved) ...[
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _rejectOffer,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white54),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Reject'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _approveOffer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.kinTeal,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                    ),
                    child: const Text('Approve Limit'),
                  ),
                ),
              ],
            ),
          ] else ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text('User is already approved', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildStat(String label, String val) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTheme.bodyStyle(fontSize: 12, color: Colors.white60)),
        const SizedBox(height: 4),
        Text(val, style: GoogleFonts.jetBrainsMono(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
      ],
    );
  }

  Widget _buildReasoningCard() {
    final orch = _orchestration!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 16, offset: const Offset(0,4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.psychology_rounded, color: AppColors.kinTeal, size: 20),
              const SizedBox(width: 8),
              Text('Agentic Reasoning', style: AppTheme.headingStyle(fontSize: 16)),
            ],
          ),
          const SizedBox(height: 16),
          Text(orch.llmReasoning ?? '', style: AppTheme.bodyStyle(fontSize: 14, color: AppColors.kinInk)),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFF0F4F3)),
          const SizedBox(height: 16),
          Text('Execution Plan:', style: AppTheme.bodyStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...orch.plan.map((step) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, size: 14, color: AppColors.kinTeal),
                    const SizedBox(width: 8),
                    Text(step, style: GoogleFonts.jetBrainsMono(fontSize: 12, color: Colors.grey[700])),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildLedgerCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 16, offset: const Offset(0,4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.list_alt_rounded, color: AppColors.kinTeal, size: 20),
              const SizedBox(width: 8),
              Text('Ledger History (API)', style: AppTheme.headingStyle(fontSize: 16)),
            ],
          ),
          const SizedBox(height: 16),
          ..._ledger!.entries.take(5).map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: AppColors.kinMist, borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.swap_horiz_rounded, size: 16, color: AppColors.kinTeal),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(e.eventType, style: AppTheme.bodyStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                          Text(e.counterparty, style: AppTheme.bodyStyle(fontSize: 11, color: Colors.grey[500]!)),
                        ],
                      ),
                    ),
                    Text('${_getCurrencySymbol(e.currency)}${e.amount.toStringAsFixed(0)}', style: GoogleFonts.jetBrainsMono(fontSize: 13, fontWeight: FontWeight.bold)),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Auto-Approval Settings', style: AppTheme.headingStyle(fontSize: 18)),
            const SizedBox(height: 24),
            Text('Minimum Auto-Approve Score', style: AppTheme.bodyStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _minScoreController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                hintText: 'e.g. 700',
              ),
            ),
            const SizedBox(height: 24),
            Text('Maximum Auto-Approve Limit', style: AppTheme.bodyStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _maxLimitController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixText: '\$ ',
                hintText: 'e.g. 5000',
              ),
            ),
            const SizedBox(height: 24),
            SwitchListTile(
              title: Text('Enable LLM Agent Reasoning', style: AppTheme.bodyStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Generate explanation and execution plans via orchestration API.', style: AppTheme.bodyStyle(fontSize: 12)),
              value: _enableLlm,
              activeTrackColor: AppColors.kinTeal,
              contentPadding: EdgeInsets.zero,
              onChanged: (val) => setState(() => _enableLlm = val),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _savingSettings ? null : _saveSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.kinTeal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _savingSettings 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Save Settings', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
