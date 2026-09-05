import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/firestore_service.dart';
import '../../core/services/auth_service.dart';
import 'admin_user_detail_screen.dart';

class AdminChatThreadScreen extends StatefulWidget {
  final String chatId;
  final String? userId;
  final String? userName;
  final Map<String, dynamic>? user;

  const AdminChatThreadScreen({
    super.key,
    required this.chatId,
    this.userId,
    this.userName,
    this.user,
  });

  @override
  State<AdminChatThreadScreen> createState() => _AdminChatThreadScreenState();
}

class _AdminChatThreadScreenState extends State<AdminChatThreadScreen> {
  final TextEditingController _controller = TextEditingController();
  final String _adminId = AuthService.instance.currentUid;
  Map<String, dynamic>? _user;
  String? _userName;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
    _userName = widget.userName;
    _fetchUserIfNeeded();
  }

  Future<void> _fetchUserIfNeeded() async {
    final uid = widget.userId ?? widget.chatId;
    if (_user == null && uid.isNotEmpty) {
      final profile = await FirestoreService.instance.getUserProfile(uid);
      if (mounted && profile != null) {
        setState(() {
          _user = profile;
          _userName = profile['fullName'] as String? ?? profile['email'] as String? ?? _userName;
        });
      }
    }
  }

  void _openUserAccount() {
    if (_user != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AdminUserDetailScreen(user: _user!)),
      );
    } else {
      final uid = widget.userId ?? widget.chatId;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fetching user profile...'), duration: Duration(milliseconds: 900)),
      );
      FirestoreService.instance.getUserProfile(uid).then((p) {
        if (!mounted) return;
        if (p != null) {
          setState(() => _user = p);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AdminUserDetailScreen(user: p)),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User account profile not found')),
          );
        }
      });
    }
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _controller.clear();
    FirestoreService.instance.sendSupportMessage(widget.chatId, _adminId, text);
  }

  @override
  Widget build(BuildContext context) {
    final email = _user?['email'] as String? ?? '';
    final title = _userName ?? (_user?['fullName'] as String?) ?? 'Chat: ${widget.chatId.length > 8 ? widget.chatId.substring(0, 8) : widget.chatId}';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.kinInk),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTheme.headingStyle(fontSize: 16, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (email.isNotEmpty)
              Text(
                email,
                style: AppTheme.bodyStyle(fontSize: 12, color: Colors.grey[600]!),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: TextButton.icon(
              onPressed: _openUserAccount,
              icon: const Icon(Icons.person_search_rounded, size: 16, color: AppColors.primaryTeal),
              label: const Text(
                'View Account',
                style: TextStyle(
                  color: AppColors.primaryTeal,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              style: TextButton.styleFrom(
                backgroundColor: AppColors.primaryTeal.withValues(alpha: 0.1),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: FirestoreService.instance.streamSupportMessages(widget.chatId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primaryTeal));
                }
                final messages = snapshot.data!;
                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline_rounded, size: 48, color: Colors.grey[300]),
                        const SizedBox(height: 12),
                        Text(
                          'No messages yet in this support thread.',
                          style: AppTheme.bodyStyle(color: Colors.grey[500]!),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg['senderId'] == _adminId;
                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isMe ? AppColors.primaryTeal : Colors.white,
                          borderRadius: BorderRadius.circular(16).copyWith(
                            bottomRight: isMe ? Radius.zero : const Radius.circular(16),
                            bottomLeft: !isMe ? Radius.zero : const Radius.circular(16),
                          ),
                          boxShadow: [
                            if (!isMe)
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                          ],
                        ),
                        child: Text(
                          msg['text'] ?? '',
                          style: TextStyle(
                            color: isMe ? Colors.white : AppColors.kinInk,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16).copyWith(bottom: 32),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                    decoration: InputDecoration(
                      hintText: 'Type your reply...',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryTeal,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
