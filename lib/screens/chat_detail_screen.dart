import 'package:flutter/material.dart';
import '../theme/modern_theme.dart';
import '../widgets/modern_widgets.dart';

/// Chat Detail Screen - Conversation individuelle
class ChatDetailScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ModernAppBar(
        title: recipientName,
        showBackButton: true,
      ),
      body: Center(
        child: EmptyState(
          icon: Icons.chat,
          title: 'Chat avec $recipientName',
          message: 'Fonctionnalité en développement',
        ),
      ),
    );
  }
}
