import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../models/chat_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../chat/chat_detail_screen.dart';

class ChatsScreen extends ConsumerWidget {
  const ChatsScreen({super.key});

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'الآن';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} دقائق';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} ساعات';
    } else {
      return '${difference.inDays} أيام';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final chatsAsync = ref.watch(userChatsProvider(user.uid));

    return Scaffold(
      appBar: AppBar(
        title: const Text('المحادثات'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.textOnPrimaryColor,
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
                    color: AppColors.textSecondaryColor,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'لا توجد محادثات',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.textSecondaryColor,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'ابدأ محادثة جديدة من خلال الرد على طلب عمل',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(userChatsProvider(user.uid));
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
                color: AppColors.errorColor,
              ),
              const SizedBox(height: 16),
              const Text(
                'خطأ في تحميل المحادثات',
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.errorColor,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(userChatsProvider(user.uid));
                },
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatTile(BuildContext context, ChatModel chat, String currentUserId) {
    final otherUserId = chat.participants.firstWhere((id) => id != currentUserId, orElse: () => '');
    final otherUserName = chat.participantNames[otherUserId] ?? 'مستخدم';
    final isLastMessageFromMe = chat.lastMessageSenderId == currentUserId;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.primaryColor,
        child: Text(
          otherUserName.isNotEmpty ? otherUserName.substring(0, 1).toUpperCase() : '?',
          style: const TextStyle(
            color: AppColors.textOnPrimaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        otherUserName,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimaryColor,
        ),
      ),
      subtitle: Row(
        children: [
          if (isLastMessageFromMe) ...[
            const Icon(
              Icons.done,
              size: 16,
              color: AppColors.textSecondaryColor,
            ),
            const SizedBox(width: 4),
          ],
          Expanded(
            child: Text(
              chat.lastMessageContent.isEmpty
                  ? 'لا توجد رسائل'
                  : chat.lastMessageContent,
              style: const TextStyle(
                color: AppColors.textSecondaryColor,
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
              color: AppColors.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ChatDetailScreen(
              chatId: chat.id,
              otherUserId: otherUserId,
            ),
          ),
        );
      },
    );
  }
}
