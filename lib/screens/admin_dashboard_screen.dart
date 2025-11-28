import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/notification_provider.dart';
import '../utils/constants.dart';
import 'team_management_screen.dart';

/// Admin dashboard screen for managing the system
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final userProvider = context.read<UserProvider>();
    final notificationProvider = context.read<NotificationProvider>();
    
    await userProvider.loadUsers();
    await notificationProvider.loadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
      ),
      body: Consumer2<UserProvider, NotificationProvider>(
        builder: (context, userProvider, notificationProvider, _) {
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Statistics cards
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      title: 'Total Users',
                      value: '${userProvider.users.length}',
                      icon: Icons.people,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      title: 'Active Users',
                      value: '${userProvider.activeUsers.length}',
                      icon: Icons.check_circle,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      title: 'Notifications',
                      value: '${notificationProvider.notifications.length}',
                      icon: Icons.notifications,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      title: 'Unread',
                      value: '${notificationProvider.unreadCount}',
                      icon: Icons.mark_email_unread,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              
              // Quick actions
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              _buildActionTile(
                context,
                icon: Icons.people,
                title: 'User Management',
                subtitle: 'Add, edit, or remove users',
                onTap: () {
                  Navigator.pushNamed(context, Routes.userManagement);
                },
              ),
              _buildActionTile(
                context,
                icon: Icons.notifications_active,
                title: 'Send Notification',
                subtitle: 'Broadcast message to employees',
                onTap: _showSendNotificationDialog,
              ),
              _buildActionTile(
                context,
                icon: Icons.groups,
                title: 'Team Management',
                subtitle: 'Manage teams, departments, and permissions',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TeamManagementScreen(),
                    ),
                  );
                },
              ),
              _buildActionTile(
                context,
                icon: Icons.map,
                title: 'View Team Map',
                subtitle: 'See employee locations',
                onTap: () {
                  Navigator.pushNamed(context, Routes.map);
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon, size: 32),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }

  void _showSendNotificationDialog() {
    // Same as in notifications_screen.dart
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
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: messageController,
              decoration: const InputDecoration(labelText: 'Message'),
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
              final notificationProvider = context.read<NotificationProvider>();
              await notificationProvider.sendNotification(
                title: titleController.text,
                message: messageController.text,
                targetUserIds: [],
              );
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }
}
