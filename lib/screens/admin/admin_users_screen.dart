import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/firestore_service.dart';
import 'admin_user_detail_screen.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  StreamSubscription? _sub;
  List<Map<String, dynamic>> _allUsers = [];
  List<Map<String, dynamic>> _filtered = [];
  final _search = TextEditingController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _sub = FirestoreService.instance.streamAllUsers().listen((users) {
      if (!mounted) return;
      setState(() { _allUsers = users; _loading = false; _applyFilter(); });
    });
    _search.addListener(_applyFilter);
  }

  void _applyFilter() {
    final q = _search.text.toLowerCase();
    setState(() {
      _filtered = q.isEmpty ? _allUsers : _allUsers.where((u) {
        final name = (u['fullName'] as String? ?? '').toLowerCase();
        final email = (u['email'] as String? ?? '').toLowerCase();
        return name.contains(q) || email.contains(q);
      }).toList();
    });
  }

  @override
  void dispose() { _sub?.cancel(); _search.dispose(); super.dispose(); }

  String _initials(String? name) {
    if (name == null || name.isEmpty) return '?';
    final p = name.trim().split(' ');
    return p.length >= 2 ? '${p[0][0]}${p[1][0]}'.toUpperCase() : p[0][0].toUpperCase();
  }

  final _avatarColors = const [AppColors.kinTeal, AppColors.kinCoral, Color(0xFF7C3AED), Color(0xFF0EA5E9), Color(0xFFF59E0B)];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: AppColors.kinTeal))
              : _filtered.isEmpty
                  ? _buildEmpty()
                  : RefreshIndicator(
                      color: AppColors.kinTeal,
                      onRefresh: () async => FirestoreService.instance.streamAllUsers().first,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                        itemCount: _filtered.length,
                        itemBuilder: (ctx, i) => _buildUserCard(_filtered[i], i),
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text('Users', style: AppTheme.headingStyle(fontSize: 22)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(color: AppColors.kinMist, borderRadius: BorderRadius.circular(14)),
              child: Text('${_allUsers.length} total',
                  style: AppTheme.bodyStyle(fontSize: 13, color: AppColors.kinTeal, fontWeight: FontWeight.bold)),
            ),
          ]),
          const SizedBox(height: 14),
          TextField(
            controller: _search,
            decoration: InputDecoration(
              hintText: 'Search by name or email...',
              hintStyle: AppTheme.bodyStyle(fontSize: 14, color: Colors.grey[400]!),
              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.kinTeal, size: 20),
              filled: true, fillColor: AppColors.kinMist,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user, int idx) {
    final name = user['fullName'] as String? ?? user['email'] as String? ?? 'Unknown';
    final email = user['email'] as String? ?? '';
    final kyc = user['kycStatus'] as String? ?? 'pending';
    final country = user['country'] as String? ?? user['countryOfResidence'] as String? ?? '';
    final employment = user['employmentStatus'] as String? ?? '';
    final avatarColor = _avatarColors[idx % _avatarColors.length];

    return GestureDetector(
      onTap: () => _showUserDetail(user),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0,4))],
        ),
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(color: avatarColor.withValues(alpha: 0.15), shape: BoxShape.circle),
              child: Center(child: Text(_initials(name),
                  style: AppTheme.headingStyle(fontSize: 16, color: avatarColor))),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTheme.bodyStyle(fontSize: 14, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(email, style: AppTheme.bodyStyle(fontSize: 12, color: Colors.grey[500]!), maxLines: 1, overflow: TextOverflow.ellipsis),
                if (country.isNotEmpty || employment.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text('${employment.isNotEmpty ? employment : ""}${country.isNotEmpty && employment.isNotEmpty ? " · " : ""}$country',
                      style: AppTheme.bodyStyle(fontSize: 11, color: Colors.grey[400]!)),
                ],
              ],
            )),
            const SizedBox(width: 8),
            _buildKycBadge(kyc),
          ],
        ),
      ),
    );
  }

  void _showUserDetail(Map<String, dynamic> user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminUserDetailScreen(user: user),
      ),
    );
  }

  Widget _buildKycBadge(String status) {
    Color bg; Color text; String label;
    switch (status.toLowerCase()) {
      case 'verified': bg = const Color(0xFFE6F7F5); text = AppColors.kinTeal; label = 'Verified'; break;
      case 'flagged': bg = const Color(0xFFFFEDEC); text = AppColors.kinCoral; label = 'Flagged'; break;
      default: bg = const Color(0xFFFFF7E6); text = const Color(0xFFB45309); label = 'Pending';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: AppTheme.bodyStyle(fontSize: 11, color: text, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildEmpty() {
    return Center(child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.people_outline, size: 64, color: Colors.grey[300]),
        const SizedBox(height: 16),
        Text('No users found', style: AppTheme.headingStyle(fontSize: 18, color: Colors.grey[400]!)),
      ],
    ));
  }
}
