import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // 1. استيراد Riverpod
import 'package:audioplayers/audioplayers.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../models/message_model.dart';
import '../../providers/auth_provider.dart'; // سيبقى هذا لاستخدامه مع Riverpod
import '../../providers/chat_provider.dart'; // سيبقى هذا لاستخدامه مع Riverpod

// 2. تحويل الويدجت إلى ConsumerStatefulWidget
class ChatDetailScreen extends ConsumerStatefulWidget {
  final String chatId;
  final String otherUserName;

  const ChatDetailScreen({
    Key? key,
    required this.chatId,
    required this.otherUserName,
  }) : super(key: key);

  @override
  // 3. تغيير State إلى ConsumerState
  _ChatDetailScreenState createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends ConsumerState<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentlyPlayingAudioUrl;

  @override
  void dispose() {
    _messageController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    // 4. قراءة البروفايدر باستخدام 'ref'
    final currentUser = ref.read(authProvider).user;
    if (currentUser == null || _messageController.text.trim().isEmpty) return;

    final chatService = ref.read(chatProvider);
    // TODO: Determine receiverId based on chat participants
    final receiverId = ''; // Placeholder

    await chatService.sendMessage(
      chatId: widget.chatId,
      // 5. استخدام currentUser.uid بدلاً من .id
      senderId: currentUser.uid,
      receiverId: receiverId, // This needs to be correctly determined
      content: _messageController.text.trim(),
      type: MessageType.text,
    );
    _messageController.clear();
  }

  Future<void> _playAudio(String audioUrl) async {
    try {
      if (_currentlyPlayingAudioUrl == audioUrl) {
        await _audioPlayer.stop();
        setState(() {
          _currentlyPlayingAudioUrl = null;
        });
      } else {
        await _audioPlayer.stop();
        await _audioPlayer.play(UrlSource(audioUrl));
        setState(() {
          _currentlyPlayingAudioUrl = audioUrl;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تشغيل الصوت: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 6. قراءة البروفايدر باستخدام 'ref'
    final currentUser = ref.watch(authProvider).user;
    // 7. استخدام ref.watch لجلب الرسائل
    final messagesAsync = ref.watch(chatMessagesProvider(widget.chatId));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.otherUserName),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              data: (messages) {
                return ListView.builder(
                  reverse: true, // Show latest messages at the bottom
                  padding: const EdgeInsets.all(8.0),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    // 8. استخدام currentUser.uid بدلاً من .id
                    final isMe = message.senderId == currentUser?.uid;
                    return _buildMessageBubble(message, isMe);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(MessageModel message, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primaryLight : AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16.0),
            topRight: const Radius.circular(16.0),
            bottomLeft: isMe ? const Radius.circular(16.0) : const Radius.circular(4.0),
            bottomRight: isMe ? const Radius.circular(4.0) : const Radius.circular(16.0),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (message.type == MessageType.text)
              Text(
                message.content,
                style: TextStyle(
                  color: isMe ? AppColors.textOnPrimary : AppColors.textPrimary,
                ),
              ),
            if (message.type == MessageType.audio)
              GestureDetector(
                onTap: () => _playAudio(message.content),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _currentlyPlayingAudioUrl == message.content ? Icons.pause_circle_filled : Icons.play_circle_fill,
                      color: isMe ? AppColors.textOnPrimary : AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'رسالة صوتية',
                      style: TextStyle(
                        color: isMe ? AppColors.textOnPrimary : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 4),
            Text(
              '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                color: isMe ? AppColors.textOnPrimary.withOpacity(0.7) : AppColors.textSecondary.withOpacity(0.7),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: AppStrings.typeMessage,
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              ),
              maxLines: null,
              keyboardType: TextInputType.multiline,
            ),
          ),
          const SizedBox(width: 8.0),
          CircleAvatar(
            backgroundColor: AppColors.primary,
            radius: 24,
            child: IconButton(
              icon: const Icon(Icons.send, color: AppColors.textOnPrimary),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}
