import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/firestore_service.dart';
import 'admin_chat_thread_screen.dart';

class AdminSupportChatsScreen extends StatelessWidget {
  const AdminSupportChatsScreen({super.key});

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
        title: Text('Support Chats', style: AppTheme.headingStyle(fontSize: 20)),
        centerTitle: true,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: FirestoreService.instance.streamSupportChats(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final chats = snapshot.data!;
          if (chats.isEmpty) {
            return const Center(child: Text('No active chats.'));
          }

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              return ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.primaryTeal,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                title: Text('User: ${chat['userId'] ?? chat['id']}'),
                subtitle: Text('Last updated: ${chat['updatedAt'] ?? 'Unknown'}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AdminChatThreadScreen(chatId: chat['id']),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
