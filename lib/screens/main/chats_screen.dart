import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // <-- تم التغيير
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../models/chat_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../chat/chat_detail_screen.dart';

// تم تحويله إلى ConsumerWidget
class ChatsScreen extends ConsumerWidget {
  const ChatsScreen({super.key});

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
  Widget build(BuildContext context, WidgetRef ref) { // <-- تم إضافة WidgetRef
    // استخدام ref.watch من Riverpod
    final authState = ref.watch(authProvider);
    final user = authState.user;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // استخدام ref.watch من Riverpod
    final chatsAsync = ref.watch(userChatsProvider(user.uid));

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.chats), // <-- تم إضافة const
        backgroundColor: AppColors.primaryColor, // <-- تم إصلاح اللون
        foregroundColor: AppColors.textOnPrimaryColor, // <-- تم إصلاح اللون
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
                    color: AppColors.textSecondaryColor, // <-- تم إصلاح اللون
                  ),
                  SizedBox(height: 16),
                  Text(
                    AppStrings.noChatsFound,
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.textSecondaryColor, // <-- تم إصلاح اللون
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'ابدأ محادثة جديدة من خلال الرد على طلب عمل',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.hintTextColor, // <-- تم إصلاح اللون
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
                color: AppColors.errorColor, // <-- تم إصلاح اللون
              ),
              const SizedBox(height: 16),
              const Text( // <-- تم إضافة const
                'خطأ في تحميل المحادثات',
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.errorColor, // <-- تم إصلاح اللون
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(userChatsProvider(user.uid));
                },
                child: const Text(AppStrings.retry), // <-- تم إضافة const
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatTile(BuildContext context, ChatModel chat, String currentUserId) {
    // الحصول على معلومات الطرف الآخر في المحادثة
    final otherUserId = chat.participants.firstWhere((id) => id != currentUserId, orElse: () => '');
    final otherUserName = chat.participantNames[otherUserId] ?? 'مستخدم';
    final isLastMessageFromMe = chat.lastMessageSenderId == currentUserId;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.primaryColor, // <-- تم إصلاح اللون
        child: Text(
          otherUserName.isNotEmpty ? otherUserName.substring(0, 1).toUpperCase() : '?',
          style: const TextStyle(
            color: AppColors.textOnPrimaryColor, // <-- تم إصلاح اللون
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        otherUserName,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimaryColor, // <-- تم إصلاح اللون
        ),
      ),
      subtitle: Row(
        children: [
          if (isLastMessageFromMe) ...[
            const Icon(
              Icons.done,
              size: 16,
              color: AppColors.textSecondaryColor, // <-- تم إصلاح اللون
            ),
            const SizedBox(width: 4),
          ],
          Expanded(
            child: Text(
              chat.lastMessageContent.isEmpty
                  ? 'لا توجد رسائل'
                  : chat.lastMessageContent,
              style: const TextStyle(
                color: AppColors.textSecondaryColor, // <-- تم إصلاح اللون
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
              color: AppColors.textSecondaryColor, // <-- تم إصلاح اللون
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
              otherUserId: otherUserId, // <-- تم إضافة otherUserId
            ),
          ),
        );
      },
    );
  }
}
