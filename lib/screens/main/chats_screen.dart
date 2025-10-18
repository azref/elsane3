import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../models/chat_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../chat/chat_detail_screen.dart';

class ChatsScreen extends StatelessWidget {
  const ChatsScreen({Key? key}) : super(key: key);

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return AppStrings.now;
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} ${AppStrings.minutesAgo}';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} ${AppStrings.hoursAgo}';
    } else {
      return '${difference.inDays} ${AppStrings.daysAgo}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = Provider.of<AuthProvider>(context);
    final user = authState.user;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final chatsAsync = Provider.of<ChatProvider>(context).getUserChats(userId);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.chats),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search functionality
            },
          ),
        ],
      ),
      body: chatsAsync.when(
        data: (chats) {
          if (chats.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(height: 16),
                  Text(
                    AppStrings.noChatsFound,
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'ابدأ محادثة جديدة من خلال الرد على طلب عمل',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textHint,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              // // // ref.invalidate(userChatsProvider);
            },
            child: ListView.builder(
              itemCount: chats.length,
              itemBuilder: (context, index) {
                final chat = chats[index];
                return _buildChatTile(context, chat, user.uid);
              },
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.error,
              ),
              const SizedBox(height: 16),
              Text(
                'خطأ في تحميل المحادثات',
                style: const TextStyle(
                  fontSize: 18,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // // // ref.invalidate(userChatsProvider);
                },
                child: Text(AppStrings.retry),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatTile(BuildContext context, ChatModel chat, String currentUserId) {
    // الحصول على معلومات الطرف الآخر في المحادثة
    final otherUserId = chat.participants.firstWhere((id) => id != currentUserId);
    final otherUserName = chat.participantNames[otherUserId] ?? 'مستخدم';
    final isLastMessageFromMe = chat.lastMessageSenderId == currentUserId;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.primary,
        child: Text(
          otherUserName.substring(0, 1).toUpperCase(),
          style: const TextStyle(
            color: AppColors.textOnPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        otherUserName,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Row(
        children: [
          if (isLastMessageFromMe) ...[
            const Icon(
              Icons.done,
              size: 16,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 4),
          ],
          Expanded(
            child: Text(
              chat.lastMessageContent.isEmpty 
                  ? 'لا توجد رسائل' 
                  : chat.lastMessageContent,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            _formatTimeAgo(chat.lastMessageTime),
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          // TODO: Add unread message count indicator
        ],
      ),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ChatDetailScreen(
              chatId: chat.id,
              otherUserName: otherUserName,
            ),
          ),
        );
      },
    );
  }
}

