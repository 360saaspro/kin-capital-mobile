import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/firestore_service.dart';
import 'admin_chat_thread_screen.dart';
import 'admin_user_detail_screen.dart';

class AdminSupportChatsScreen extends StatefulWidget {
  const AdminSupportChatsScreen({super.key});

  @override
  State<AdminSupportChatsScreen> createState() => _AdminSupportChatsScreenState();
}

class _AdminSupportChatsScreenState extends State<AdminSupportChatsScreen> {
  StreamSubscription? _usersSub;
  Map<String, Map<String, dynamic>> _usersMap = {};

  @override
  void initState() {
    super.initState();
    _usersSub = FirestoreService.instance.streamAllUsers().listen((users) {
      if (!mounted) return;
      final map = <String, Map<String, dynamic>>{};
      for (final u in users) {
        final uid = u['uid'] as String? ?? u['id'] as String?;
        if (uid != null && uid.isNotEmpty) {
          map[uid] = u;
        }
      }
      setState(() => _usersMap = map);
    });
  }

  @override
  void dispose() {
    _usersSub?.cancel();
    super.dispose();
  }

  String _timeAgo(String? iso) {
    if (iso == null) return '';
    try {
      final dt = DateTime.parse(iso);
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return '${diff.inDays}d ago';
    } catch (_) {
      return '';
    }
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts[0].isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  Future<void> _openUserAccount(BuildContext context, String uid, Map<String, dynamic>? user) async {
    if (user != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AdminUserDetailScreen(user: user)),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fetching user profile...'), duration: Duration(milliseconds: 900)),
    );

    final profile = await FirestoreService.instance.getUserProfile(uid);
    if (!mounted) return;

    if (profile != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AdminUserDetailScreen(user: profile)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User account profile not found')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: FirestoreService.instance.streamSupportChats(),
      builder: (context, snapshot) {
        if (snapshot.hasError || (!snapshot.hasData && snapshot.connectionState == ConnectionState.done)) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.support_agent_outlined, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text('Could not load chats', style: AppTheme.headingStyle(fontSize: 18, color: Colors.grey[400]!)),
              ],
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator(color: AppColors.kinTeal));
        }
        final chats = snapshot.data!;
        return Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Row(
                children: [
                  Text('Support Chats', style: AppTheme.headingStyle(fontSize: 22)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(color: AppColors.kinMist, borderRadius: BorderRadius.circular(14)),
                    child: Text(
                      '${chats.length} active',
                      style: AppTheme.bodyStyle(fontSize: 13, color: AppColors.kinTeal, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: chats.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.support_agent_outlined, size: 64, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          Text('No active chats', style: AppTheme.headingStyle(fontSize: 18, color: Colors.grey[400]!)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
                      itemCount: chats.length,
                      itemBuilder: (context, index) {
                        final chat = chats[index];
                        final uid = chat['userId'] as String? ?? chat['id'] as String? ?? '';
                        final user = _usersMap[uid];
                        final rawName = user?['fullName'] as String?;
                        final email = user?['email'] as String? ?? '';
                        final name = (rawName != null && rawName.trim().isNotEmpty)
                            ? rawName
                            : (email.isNotEmpty
                                ? email
                                : (uid.length > 10 ? 'User ${uid.substring(0, 8)}...' : 'User $uid'));
                        final kyc = user?['kycStatus'] as String? ?? '';
                        final updated = _timeAgo(chat['updatedAt'] as String?);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AdminChatThreadScreen(
                                    chatId: chat['id'],
                                    userId: uid,
                                    userName: name,
                                    user: user,
                                  ),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    // Avatar
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: AppColors.kinTeal.withValues(alpha: 0.12),
                                        shape: BoxShape.circle,
                                        border: Border.all(color: AppColors.kinTeal.withValues(alpha: 0.25)),
                                      ),
                                      child: Center(
                                        child: Text(
                                          _initials(name),
                                          style: AppTheme.headingStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.kinTeal,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 14),

                                    // Name, Email, Status & Timestamp
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  name,
                                                  style: AppTheme.bodyStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              if (kyc.isNotEmpty) ...[
                                                const SizedBox(width: 8),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: kyc == 'verified'
                                                        ? AppColors.primaryTeal.withValues(alpha: 0.1)
                                                        : Colors.amber.withValues(alpha: 0.15),
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                  child: Text(
                                                    kyc.toUpperCase(),
                                                    style: TextStyle(
                                                      fontSize: 9.5,
                                                      fontWeight: FontWeight.bold,
                                                      color: kyc == 'verified'
                                                          ? AppColors.primaryTeal
                                                          : const Color(0xFFB45309),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                          const SizedBox(height: 3),
                                          Row(
                                            children: [
                                              if (email.isNotEmpty)
                                                Flexible(
                                                  child: Text(
                                                    email,
                                                    style: AppTheme.bodyStyle(
                                                      fontSize: 12.5,
                                                      color: Colors.grey[600]!,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              if (email.isNotEmpty && updated.isNotEmpty)
                                                Text(
                                                  ' • ',
                                                  style: TextStyle(color: Colors.grey[400]!, fontSize: 12),
                                                ),
                                              if (updated.isNotEmpty)
                                                Text(
                                                  updated,
                                                  style: AppTheme.bodyStyle(
                                                    fontSize: 11.5,
                                                    color: Colors.grey[400]!,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(width: 10),

                                    // Quick View Account Action
                                    OutlinedButton.icon(
                                      onPressed: () => _openUserAccount(context, uid, user),
                                      icon: const Icon(Icons.person_search_rounded, size: 15, color: AppColors.kinTeal),
                                      label: const Text(
                                        'Account',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.kinTeal,
                                        ),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        side: BorderSide(color: AppColors.kinTeal.withValues(alpha: 0.3)),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        backgroundColor: AppColors.kinMist,
                                      ),
                                    ),

                                    const SizedBox(width: 6),
                                    const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 20),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
