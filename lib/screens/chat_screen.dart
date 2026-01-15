import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_theme.dart';
import '../services/chat_service.dart';

class ChatScreen extends StatefulWidget {
  final String conversationId;
  final String otherUserName;
  final String otherUserAvatar;
  final String currentUserId;

  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.otherUserName,
    this.otherUserAvatar = '',
    required this.currentUserId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _listenToNewMessages();
  }

  Future<void> _loadMessages() async {
    final messages = await ChatService.getMessages(
      conversationId: widget.conversationId,
    );
    setState(() {
      _messages = messages;
      _isLoading = false;
    });
    _scrollToBottom();
  }

  void _listenToNewMessages() {
    ChatService.messageStream.listen((message) {
      if (message['conversation_id'] == widget.conversationId) {
        setState(() {
          _messages.add(message);
        });
        _scrollToBottom();
      }
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    _messageController.clear();

    await ChatService.sendMessage(
      conversationId: widget.conversationId,
      senderId: widget.currentUserId,
      receiverId: '', // Will be determined by conversation
      content: content,
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: _buildAppBar(),
        body: Column(
          children: [
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildMessagesList(),
            ),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.surface,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_forward, color: AppTheme.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppTheme.gradientPrimary,
            ),
            child: Center(
              child: Text(
                widget.otherUserName.isNotEmpty
                    ? widget.otherUserName[0]
                    : '?',
                style: const TextStyle(
                  color: AppTheme.white,
                  fontWeight: AppTheme.fontBold,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppTheme.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.otherUserName,
                style: const TextStyle(
                  color: AppTheme.white,
                  fontSize: AppTheme.fontMd,
                  fontWeight: AppTheme.fontBold,
                ),
              ),
              const Text(
                'متصلة الآن',
                style: TextStyle(
                  color: AppTheme.success,
                  fontSize: AppTheme.fontXs,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.videocam, color: AppTheme.primary),
          onPressed: () {
            // Start video call
            _showVideoCallOptions();
          },
        ),
        IconButton(
          icon: const Icon(Icons.call, color: AppTheme.primary),
          onPressed: () {
            // Start voice call
          },
        ),
        IconButton(
          icon: const Icon(Icons.more_vert, color: AppTheme.white),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildMessagesList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(AppTheme.md),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        final isMe = message['sender_id'] == widget.currentUserId;
        return _buildMessageBubble(message, isMe, index);
      },
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message, bool isMe, int index) {
    return Align(
      alignment: isMe ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppTheme.sm),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.start : CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.md,
                vertical: AppTheme.sm,
              ),
              decoration: BoxDecoration(
                gradient: isMe ? AppTheme.gradientPrimary : null,
                color: isMe ? null : AppTheme.surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(AppTheme.radiusMd),
                  topRight: const Radius.circular(AppTheme.radiusMd),
                  bottomLeft: Radius.circular(isMe ? 0 : AppTheme.radiusMd),
                  bottomRight: Radius.circular(isMe ? AppTheme.radiusMd : 0),
                ),
              ),
              child: _buildMessageContent(message),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(message['created_at']),
              style: const TextStyle(
                fontSize: AppTheme.fontXs,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (index * 50).ms);
  }

  Widget _buildMessageContent(Map<String, dynamic> message) {
    final type = message['type'] ?? 'text';

    switch (type) {
      case 'image':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.card,
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
              child: const Icon(
                Icons.image,
                size: 50,
                color: AppTheme.textSecondary,
              ),
            ),
            if (message['content'] != null && message['content'].isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: AppTheme.xs),
                child: Text(
                  message['content'],
                  style: const TextStyle(
                    color: AppTheme.white,
                    fontSize: AppTheme.fontMd,
                  ),
                ),
              ),
          ],
        );
      case 'voice':
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.play_arrow, color: AppTheme.white),
            const SizedBox(width: AppTheme.sm),
            Container(
              width: 100,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.white.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: AppTheme.sm),
            Text(
              '${message['metadata']?['duration'] ?? 0}"',
              style: const TextStyle(
                color: AppTheme.white,
                fontSize: AppTheme.fontSm,
              ),
            ),
          ],
        );
      default:
        return Text(
          message['content'] ?? '',
          style: const TextStyle(
            color: AppTheme.white,
            fontSize: AppTheme.fontMd,
          ),
        );
    }
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.md),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(
          top: BorderSide(color: AppTheme.border.withValues(alpha: 0.3)),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.add, color: AppTheme.primary),
              onPressed: () => _showAttachmentOptions(),
            ),
            Expanded(
              child: TextField(
                controller: _messageController,
                style: const TextStyle(color: AppTheme.white),
                decoration: InputDecoration(
                  hintText: 'اكتبي رسالتك...',
                  hintStyle: const TextStyle(color: AppTheme.textSecondary),
                  filled: true,
                  fillColor: AppTheme.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.md,
                    vertical: AppTheme.sm,
                  ),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: AppTheme.sm),
            IconButton(
              icon: const Icon(Icons.mic, color: AppTheme.primary),
              onPressed: () {
                // Record voice message
              },
            ),
            Container(
              decoration: const BoxDecoration(
                gradient: AppTheme.gradientPrimary,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send, color: AppTheme.white),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusLg)),
      ),
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'إرسال',
                style: TextStyle(
                  fontSize: AppTheme.fontLg,
                  fontWeight: AppTheme.fontBold,
                  color: AppTheme.white,
                ),
              ),
              const SizedBox(height: AppTheme.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildAttachmentOption(
                    icon: Icons.image,
                    label: 'صورة',
                    color: AppTheme.primary,
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  _buildAttachmentOption(
                    icon: Icons.camera_alt,
                    label: 'كاميرا',
                    color: AppTheme.secondary,
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  _buildAttachmentOption(
                    icon: Icons.attach_file,
                    label: 'ملف',
                    color: AppTheme.accent,
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  _buildAttachmentOption(
                    icon: Icons.location_on,
                    label: 'موقع',
                    color: AppTheme.success,
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.lg),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: AppTheme.sm),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.white,
              fontSize: AppTheme.fontSm,
            ),
          ),
        ],
      ),
    );
  }

  void _showVideoCallOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusLg)),
      ),
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'بدء جلسة فيديو',
                style: TextStyle(
                  fontSize: AppTheme.fontLg,
                  fontWeight: AppTheme.fontBold,
                  color: AppTheme.white,
                ),
              ),
              const SizedBox(height: AppTheme.lg),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(AppTheme.sm),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: const Icon(Icons.videocam, color: AppTheme.primary),
                ),
                title: const Text(
                  'مكالمة فيديو مباشرة',
                  style: TextStyle(color: AppTheme.white),
                ),
                subtitle: const Text(
                  'ابدئي مكالمة فيديو الآن',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
                onTap: () {
                  Navigator.pop(context);
                  // Start immediate video call
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(AppTheme.sm),
                  decoration: BoxDecoration(
                    color: AppTheme.secondary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: const Icon(Icons.calendar_today, color: AppTheme.secondary),
                ),
                title: const Text(
                  'جدولة جلسة',
                  style: TextStyle(color: AppTheme.white),
                ),
                subtitle: const Text(
                  'حددي موعداً للجلسة',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
                onTap: () {
                  Navigator.pop(context);
                  // Schedule session
                },
              ),
              const SizedBox(height: AppTheme.lg),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(String? dateString) {
    if (dateString == null) return '';
    try {
      final date = DateTime.parse(dateString);
      final hour = date.hour > 12 ? date.hour - 12 : date.hour;
      final period = date.hour >= 12 ? 'م' : 'ص';
      return '${hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')} $period';
    } catch (e) {
      return '';
    }
  }
}
