import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/notification_card.dart';
import '../utils/helpers.dart';

/// Notifications screen showing all notifications
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNotifications();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadNotifications() async {
    final notificationProvider = context.read<NotificationProvider>();
    await notificationProvider.loadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Unread'),
          ],
        ),
        actions: [
          if (authProvider.canManageUsers)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _showSendNotificationDialog,
            ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, notificationProvider, _) {
          if (notificationProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildNotificationsList(
                notificationProvider.notifications,
                authProvider.currentUser?.id ?? '',
              ),
              _buildNotificationsList(
                notificationProvider.unreadNotifications,
                authProvider.currentUser?.id ?? '',
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNotificationsList(List notifications, String currentUserId) {
    if (notifications.isEmpty) {
      return const Center(
        child: Text('No notifications'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadNotifications,
      child: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return NotificationCard(
            notification: notification,
            isRead: notification.isReadBy(currentUserId),
            onTap: () async {
              if (notification.isUnreadBy(currentUserId)) {
                final notificationProvider = context.read<NotificationProvider>();
                await notificationProvider.markAsRead(
                  notification.id,
                  currentUserId,
                );
              }
            },
          );
        },
      ),
    );
  }

  void _showSendNotificationDialog() {
    final titleController = TextEditingController();
    final messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Notification'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: messageController,
              decoration: const InputDecoration(
                labelText: 'Message',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              // TODO: Add user selection logic
              final notificationProvider = context.read<NotificationProvider>();
              final success = await notificationProvider.sendNotification(
                title: titleController.text,
                message: messageController.text,
                targetUserIds: [], // All users or selected users
              );

              if (context.mounted) {
                Navigator.pop(context);
                if (success) {
                  UiHelper.showSnackBar(context, 'Notification sent');
                } else {
                  UiHelper.showSnackBar(
                    context,
                    'Failed to send notification',
                    isError: true,
                  );
                }
              }
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }
}
