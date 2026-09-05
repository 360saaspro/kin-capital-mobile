import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/firestore_service.dart';
import 'admin_kyc_detail_screen.dart';

class AdminKycReviewScreen extends StatefulWidget {
  const AdminKycReviewScreen({super.key});

  @override
  State<AdminKycReviewScreen> createState() => _AdminKycReviewScreenState();
}

class _AdminKycReviewScreenState extends State<AdminKycReviewScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  StreamSubscription? _sub;
  List<Map<String, dynamic>> _users = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _sub = FirestoreService.instance.streamAllUsers().listen((users) {
      if (!mounted) return;
      setState(() { _users = users; _loading = false; });
    });
  }

  @override
  void dispose() { _tabs.dispose(); _sub?.cancel(); super.dispose(); }

  List<Map<String, dynamic>> get _pending =>
      _users.where((u) => (u['kycStatus'] as String? ?? '') == 'pending' ||
          (u['kycStatus'] as String? ?? '') == 'submitted').toList();

  List<Map<String, dynamic>> get _flagged =>
      _users.where((u) => (u['kycStatus'] as String? ?? '') == 'flagged').toList();

  List<Map<String, dynamic>> get _history =>
      _users.where((u) => (u['kycStatus'] as String? ?? '') == 'verified' ||
          (u['kycStatus'] as String? ?? '') == 'rejected').toList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: AppColors.kinTeal))
              : TabBarView(
                  controller: _tabs,
                  children: [
                    _buildList(_pending, isPending: true),
                    _buildList(_flagged, isPending: false),
                    _buildList(_history, isPending: false, isHistory: true),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(children: [
              Text('KYC Review', style: AppTheme.headingStyle(fontSize: 22)),
              const Spacer(),
              if (_pending.isNotEmpty)
                Container(
                  width: 28, height: 28,
                  decoration: const BoxDecoration(color: Color(0xFFFFF7E6), shape: BoxShape.circle),
                  child: Center(child: Text('${_pending.length}',
                      style: AppTheme.bodyStyle(fontSize: 12, color: Color(0xFFB45309), fontWeight: FontWeight.bold))),
                ),
            ]),
          ),
          const SizedBox(height: 12),
          TabBar(
            controller: _tabs,
            labelColor: AppColors.kinTeal,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.kinTeal,
            indicatorWeight: 3,
            labelStyle: AppTheme.bodyStyle(fontSize: 14, fontWeight: FontWeight.bold),
            unselectedLabelStyle: AppTheme.bodyStyle(fontSize: 14),
            tabs: [
              Tab(text: 'Pending (${_pending.length})'),
              Tab(text: 'Flagged (${_flagged.length})'),
              Tab(text: 'History (${_history.length})'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<Map<String, dynamic>> users, {required bool isPending, bool isHistory = false}) {
    if (users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isHistory ? Icons.history_rounded : (isPending ? Icons.check_circle_outline_rounded : Icons.flag_outlined),
                size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(isHistory ? 'No history available' : (isPending ? 'No pending reviews' : 'No flagged users'),
                style: AppTheme.headingStyle(fontSize: 18, color: Colors.grey[400]!)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      itemCount: users.length,
      itemBuilder: (ctx, i) => _buildKycCard(users[i]),
    );
  }

  Widget _buildKycCard(Map<String, dynamic> user) {
    final name = user['fullName'] as String? ?? 'Unknown User';
    final email = user['email'] as String? ?? '';
    final idType = user['identityType'] as String? ?? 'Unknown ID';
    final country = user['countryOfResidence'] as String? ?? user['country'] as String? ?? '';
    final employment = user['employmentStatus'] as String? ?? '';
    final status = user['kycStatus'] as String? ?? 'pending';
    final updatedAt = user['updatedAt'] as String? ?? '';
    final kycChecks = user['kycChecks'] as List<dynamic>? ?? [];
    final reviewedBy = user['kycReviewedBy'] as String? ?? '';
    final decisionNote = user['kycDecisionNote'] as String? ?? user['kycFlagReason'] as String? ?? '';
    final isHistory = status == 'verified' || status == 'rejected';

    String timeStr = '';
    if (updatedAt.isNotEmpty) {
      try {
        final dt = DateTime.parse(updatedAt);
        final diff = DateTime.now().difference(dt);
        timeStr = diff.inDays > 0 ? '${diff.inDays}d ago' : '${diff.inHours}h ago';
      } catch (_) {}
    }

    return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AdminKycDetailScreen(user: user),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0,4))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: status == 'flagged' || status == 'rejected' ? const Color(0xFFFFF5F5) : const Color(0xFFF0FAF9),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: (status == 'flagged' || status == 'rejected' ? AppColors.kinCoral : AppColors.kinTeal).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      status == 'flagged' || status == 'rejected' ? Icons.flag_rounded : Icons.person_rounded,
                      color: status == 'flagged' || status == 'rejected' ? AppColors.kinCoral : AppColors.kinTeal,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(
                      children: [
                        Text(name, style: AppTheme.bodyStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        if (isHistory) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: status == 'verified' ? AppColors.kinTeal.withValues(alpha: 0.2) : AppColors.kinCoral.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              status.toUpperCase(),
                              style: AppTheme.bodyStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: status == 'verified' ? AppColors.kinTeal : AppColors.kinCoral,
                              ),
                            ),
                          ),
                        ],
                      ]
                    ),
                    Text(email, style: AppTheme.bodyStyle(fontSize: 12, color: Colors.grey[500]!), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ])),
                  if (timeStr.isNotEmpty)
                    Text(timeStr, style: AppTheme.bodyStyle(fontSize: 11, color: Colors.grey[400]!)),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(spacing: 8, runSpacing: 8, children: [
                      _chip(Icons.badge_outlined, idType),
                      if (country.isNotEmpty) _chip(Icons.location_on_outlined, country),
                      if (employment.isNotEmpty) _chip(Icons.work_outline_rounded, employment),
                    ]),
                    if (isHistory) ...[
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 12),
                      Text('KYC Decision Breakdown', style: AppTheme.bodyStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey[700]!)),
                      const SizedBox(height: 8),
                      if (kycChecks.isNotEmpty)
                        ...kycChecks.map((check) => Row(children: [
                          Icon(Icons.check_circle, size: 14, color: AppColors.kinTeal),
                          const SizedBox(width: 6),
                          Text(check.toString(), style: AppTheme.bodyStyle(fontSize: 12, color: Colors.grey[600]!)),
                        ])),
                      if (reviewedBy.isNotEmpty)
                        Padding(padding: const EdgeInsets.only(top: 8), child: Text('Reviewed by: $reviewedBy', style: AppTheme.bodyStyle(fontSize: 12, color: Colors.grey[500]!))),
                      if (decisionNote.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.info_outline, size: 16, color: Colors.grey),
                                const SizedBox(width: 8),
                                Expanded(child: Text(decisionNote, style: AppTheme.bodyStyle(fontSize: 12, color: Colors.grey[700]!))),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      );
  }

  Widget _chip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: AppColors.kinMist, borderRadius: BorderRadius.circular(10)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: AppColors.kinTeal),
        const SizedBox(width: 6),
        Text(label, style: AppTheme.bodyStyle(fontSize: 12, color: AppColors.kinInk)),
      ]),
    );
  }

}
