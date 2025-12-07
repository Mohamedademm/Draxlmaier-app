import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/chat_group_model.dart';
import '../models/message_model.dart';
import '../providers/auth_provider.dart';
import '../services/chat_service.dart';
import '../theme/draexlmaier_theme.dart';
import 'package:intl/intl.dart';

/// Department Chat Screen
/// Allows managers to communicate with all employees in their department
class DepartmentChatScreen extends StatefulWidget {
  const DepartmentChatScreen({super.key});

  @override
  State<DepartmentChatScreen> createState() => _DepartmentChatScreenState();
}

class _DepartmentChatScreenState extends State<DepartmentChatScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  ChatGroup? _departmentGroup;
  List<Message> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _loadDepartmentGroup();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadDepartmentGroup() async {
    setState(() => _isLoading = true);

    try {
      final group = await _chatService.getDepartmentGroup();
      final messages = await _chatService.getChatHistory(
        groupId: group.id,
        limit: 50,
      );

      setState(() {
        _departmentGroup = group;
        _messages = messages;
        _isLoading = false;
      });

      _scrollToBottom();
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement du groupe: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _departmentGroup == null) {
      return;
    }

    final content = _messageController.text.trim();
    _messageController.clear();

    setState(() => _isSending = true);

    try {
      final message = await _chatService.sendGroupMessage(
        groupId: _departmentGroup!.id,
        content: content,
      );

      setState(() {
        _messages.add(message);
        _isSending = false;
      });

      _scrollToBottom();
    } catch (e) {
      setState(() => _isSending = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de l\'envoi du message'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildMessageBubble(Message message, bool isMe) {
    final time = DateFormat('HH:mm').format(message.timestamp);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        decoration: BoxDecoration(
          color: isMe ? DraexlmaierTheme.primaryBlue : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMe && message.senderName != null)
              Text(
                message.senderName!,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isMe ? Colors.white70 : Colors.black54,
                ),
              ),
            if (!isMe && message.senderName != null) const SizedBox(height: 4),
            Text(
              message.content,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black87,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: TextStyle(
                fontSize: 10,
                color: isMe ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final currentUserId = authProvider.currentUser?.id;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_departmentGroup?.name ?? 'Groupe Département'),
            if (_departmentGroup != null)
              Text(
                '${_departmentGroup!.memberCount} membres',
                style: const TextStyle(fontSize: 12),
              ),
          ],
        ),
        actions: [
          if (_departmentGroup != null)
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () => _showGroupInfo(),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (_departmentGroup?.description != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    color: DraexlmaierTheme.secondaryBlue.withOpacity(0.1),
                    child: Text(
                      _departmentGroup!.description!,
                      style: const TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                Expanded(
                  child: _messages.isEmpty
                      ? const Center(
                          child: Text('Aucun message pour le moment'),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(8),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final message = _messages[index];
                            final isMe = message.senderId == currentUserId;
                            return _buildMessageBubble(message, isMe);
                          },
                        ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
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
                            hintText: 'Écrivez votre message...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                          maxLines: null,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: _isSending
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.send),
                        onPressed: _isSending ? null : _sendMessage,
                        color: DraexlmaierTheme.primaryBlue,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  void _showGroupInfo() {
    if (_departmentGroup == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Informations du groupe'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Nom: ${_departmentGroup!.name}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (_departmentGroup!.description != null)
                Text('Description: ${_departmentGroup!.description}'),
              const SizedBox(height: 8),
              if (_departmentGroup!.department != null)
                Text('Département: ${_departmentGroup!.department}'),
              const SizedBox(height: 8),
              Text('Type: ${_departmentGroup!.isDepartmentGroup ? 'Groupe de département' : 'Groupe personnalisé'}'),
              const SizedBox(height: 8),
              Text('Membres: ${_departmentGroup!.memberCount}'),
              const SizedBox(height: 8),
              if (_departmentGroup!.admins != null)
                Text('Administrateurs: ${_departmentGroup!.admins!.length}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
}
