import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

/// Chat list screen showing all conversations
class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    final chatProvider = context.read<ChatProvider>();
    await chatProvider.loadConversations();
    await chatProvider.loadGroups();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
      ),
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, _) {
          if (chatProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final conversations = chatProvider.conversations;
          final groups = chatProvider.groups;

          if (conversations.isEmpty && groups.isEmpty) {
            return const Center(
              child: Text('No conversations yet'),
            );
          }

          return ListView(
            children: [
              // Groups section
              if (groups.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Groups',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                ...groups.map((group) => ListTile(
                      leading: CircleAvatar(
                        child: Icon(Icons.group),
                      ),
                      title: Text(group.name),
                      subtitle: Text('${group.memberCount} members'),
                      trailing: group.unreadCount > 0
                          ? CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.red,
                              child: Text(
                                '${group.unreadCount}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            )
                          : null,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          Routes.chatDetail,
                          arguments: {
                            'chatId': group.id,
                            'recipientName': group.name,
                            'isGroupChat': true,
                          },
                        );
                      },
                    )),
              ],
              
              // Direct messages section
              if (conversations.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Direct Messages',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                ...conversations.map((conv) => ListTile(
                      leading: CircleAvatar(
                        child: Text(conv['recipientName']?[0] ?? 'U'),
                      ),
                      title: Text(conv['recipientName'] ?? 'Unknown'),
                      subtitle: Text(
                        conv['lastMessage'] ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (conv['lastMessageTime'] != null)
                            Text(
                              DateTimeHelper.formatChatTime(
                                DateTime.parse(conv['lastMessageTime']),
                              ),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          if (conv['unreadCount'] != null && conv['unreadCount'] > 0)
                            CircleAvatar(
                              radius: 10,
                              backgroundColor: Colors.red,
                              child: Text(
                                '${conv['unreadCount']}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                        ],
                      ),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          Routes.chatDetail,
                          arguments: {
                            'chatId': conv['recipientId'],
                            'recipientId': conv['recipientId'],
                            'recipientName': conv['recipientName'],
                            'isGroupChat': false,
                          },
                        );
                      },
                    )),
              ],
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showNewChatDialog();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showNewChatDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Chat'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Direct Message'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Show user selection dialog
              },
            ),
            ListTile(
              leading: const Icon(Icons.group),
              title: const Text('Create Group'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Show group creation dialog
              },
            ),
          ],
        ),
      ),
    );
  }
}
