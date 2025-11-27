import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/message_bubble.dart';

/// Chat detail screen for one-to-one or group chat
class ChatDetailScreen extends StatefulWidget {
  final String chatId;
  final String? recipientId;
  final String recipientName;
  final bool isGroupChat;

  const ChatDetailScreen({
    super.key,
    required this.chatId,
    this.recipientId,
    required this.recipientName,
    this.isGroupChat = false,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _joinRoom();
  }

  @override
  void dispose() {
    _leaveRoom();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    final chatProvider = context.read<ChatProvider>();
    await chatProvider.loadChatHistory(
      recipientId: widget.isGroupChat ? null : widget.recipientId,
      groupId: widget.isGroupChat ? widget.chatId : null,
    );
  }

  void _joinRoom() {
    final chatProvider = context.read<ChatProvider>();
    chatProvider.joinRoom(widget.chatId);
  }

  void _leaveRoom() {
    final chatProvider = context.read<ChatProvider>();
    chatProvider.leaveRoom(widget.chatId);
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final chatProvider = context.read<ChatProvider>();
    chatProvider.sendMessage(
      content: _messageController.text.trim(),
      recipientId: widget.isGroupChat ? null : widget.recipientId,
      groupId: widget.isGroupChat ? widget.chatId : null,
    );

    _messageController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _onTypingChanged(String text) {
    final chatProvider = context.read<ChatProvider>();
    final isTypingNow = text.isNotEmpty;

    if (isTypingNow != _isTyping) {
      _isTyping = isTypingNow;
      chatProvider.sendTyping(widget.chatId, isTypingNow);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final currentUserId = authProvider.currentUser?.id ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.recipientName),
            Consumer<ChatProvider>(
              builder: (context, chatProvider, _) {
                final typingUsers = chatProvider.typingUsers;
                final isTyping = typingUsers.values.any((typing) => typing);
                
                if (isTyping) {
                  return const Text(
                    'Typing...',
                    style: TextStyle(fontSize: 12),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chatProvider, _) {
                if (chatProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = chatProvider.messages;

                if (messages.isEmpty) {
                  return const Center(
                    child: Text('No messages yet'),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16.0),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == currentUserId;
                    
                    return MessageBubble(
                      message: message.copyWith(isMe: isMe),
                      showSenderName: widget.isGroupChat && !isMe,
                    );
                  },
                );
              },
            ),
          ),
          
          // Message input
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                      onChanged: _onTypingChanged,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _sendMessage,
                    color: Theme.of(context).primaryColor,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
