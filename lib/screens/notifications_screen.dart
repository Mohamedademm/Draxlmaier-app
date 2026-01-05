import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/notification_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import '../models/notification_model.dart';
import '../models/user_model.dart';
import '../theme/modern_theme.dart';
import '../widgets/modern_widgets.dart';
import '../widgets/skeleton_loader.dart';

/// Modern Notifications Screen
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
    await context.read<NotificationProvider>().loadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final currentUserId = authProvider.currentUser?.id ?? '';

    return Scaffold(
      appBar: ModernAppBar(
        title: 'Notifications',
        showBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all, color: ModernTheme.textPrimary),
            onPressed: () => _markAllAsRead(currentUserId),
            tooltip: 'Tout marquer comme lu',
          ),
          if (authProvider.canManageUsers)
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: ModernTheme.primaryBlue),
              onPressed: _showSendNotificationDialog,
              tooltip: 'Envoyer une notification',
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: ModernTheme.primaryBlue,
          unselectedLabelColor: ModernTheme.textSecondary,
          indicatorColor: ModernTheme.primaryBlue,
          tabs: const [
            Tab(text: 'Toutes'),
            Tab(text: 'Non lues'),
          ],
        ),
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const SkeletonList(itemCount: 8);
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildNotificationsList(provider.notifications, currentUserId),
              _buildNotificationsList(provider.unreadNotifications, currentUserId),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNotificationsList(List<NotificationModel> notifications, String currentUserId) {
    if (notifications.isEmpty) {
      return const EmptyState(
        icon: Icons.notifications_none,
        title: 'Aucune notification',
        message: 'Vous êtes à jour !',
      );
    }

    // Group notifications by date
    final grouped = _groupNotificationsByDate(notifications);

    return RefreshIndicator(
      onRefresh: _loadNotifications,
      child: ListView.builder(
        padding: const EdgeInsets.all(ModernTheme.spacingM),
        itemCount: grouped.length,
        itemBuilder: (context, index) {
          final group = grouped[index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: Text(
                  group.dateLabel,
                  style: const TextStyle(
                    color: ModernTheme.textTertiary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
              ...group.notifications.map((notification) => _buildNotificationItem(
                notification,
                currentUserId,
              )),
              const SizedBox(height: 8),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNotificationItem(NotificationModel notification, String currentUserId) {
    final isSender = notification.senderId == currentUserId;
    final isRead = notification.isReadBy(currentUserId) || isSender;
    // If targetUsers is empty, assume it's a broadcast or we are authorized (fallback)
    // But strictly, if we are not in targetUsers and it's not empty, we are not a recipient.
    final isRecipient = notification.targetUsers.isEmpty || notification.targetUsers.contains(currentUserId);

    return Dismissible(
      key: Key(notification.id),
      background: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: ModernTheme.primaryBlue,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.check, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        if (!isRead && !isSender && isRecipient) {
          await context.read<NotificationProvider>().markAsRead(
            notification.id,
            currentUserId,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Marquée comme lue'),
              duration: Duration(seconds: 1),
            ),
          );
        }
        return false;
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: ModernCard(
          onTap: () async {
            if (!isRead && !isSender && isRecipient) {
              await context.read<NotificationProvider>().markAsRead(
                notification.id,
                currentUserId,
              );
            }
          },
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isRead 
                      ? ModernTheme.surfaceVariant 
                      : ModernTheme.primaryBlue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isRead ? Icons.notifications_none : Icons.notifications_active,
                  color: isRead ? ModernTheme.textSecondary : ModernTheme.primaryBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                              color: ModernTheme.textPrimary,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Text(
                          _formatTime(notification.createdAt),
                          style: const TextStyle(
                            fontSize: 11,
                            color: ModernTheme.textTertiary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: TextStyle(
                        color: isRead ? ModernTheme.textSecondary : ModernTheme.textPrimary,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    if (isSender)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Envoyé par vous',
                          style: TextStyle(
                            fontSize: 11,
                            color: ModernTheme.primaryBlue.withOpacity(0.8),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (!isRead && !isSender && isRecipient)
                Container(
                  margin: const EdgeInsets.only(left: 8, top: 8),
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: ModernTheme.primaryBlue,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  List<_NotificationGroup> _groupNotificationsByDate(List<NotificationModel> notifications) {
    final groups = <String, List<NotificationModel>>{};
    
    for (var notification in notifications) {
      final date = DateTime(
        notification.createdAt.year,
        notification.createdAt.month,
        notification.createdAt.day,
      );
      final key = date.toIso8601String();
      
      if (!groups.containsKey(key)) {
        groups[key] = [];
      }
      groups[key]!.add(notification);
    }

    final sortedKeys = groups.keys.toList()
      ..sort((a, b) => DateTime.parse(b).compareTo(DateTime.parse(a)));

    return sortedKeys.map((key) {
      final date = DateTime.parse(key);
      String label;
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));

      if (date == today) {
        label = 'Aujourd\'hui';
      } else if (date == yesterday) {
        label = 'Hier';
      } else {
        label = DateFormat('dd MMMM yyyy', 'fr').format(date);
      }

      return _NotificationGroup(label, groups[key]!);
    }).toList();
  }

  String _formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  Future<void> _markAllAsRead(String userId) async {
    await context.read<NotificationProvider>().markAllAsRead(userId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Toutes les notifications marquées comme lues'),
          backgroundColor: ModernTheme.success,
        ),
      );
    }
  }

  void _showSendNotificationDialog() {
    final titleController = TextEditingController();
    final messageController = TextEditingController();
    String targetType = 'all'; // 'all', 'department', 'user'
    String? selectedDepartment;
    List<User> selectedUsers = [];
    List<User> allUsers = [];
    bool isFetchingUsers = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          if (allUsers.isEmpty && !isFetchingUsers && (targetType == 'user' || targetType == 'department')) {
            isFetchingUsers = true;
            final userProvider = context.read<UserProvider>();
            
            // Function to update state with users
            void updateUsers() {
              setDialogState(() {
                allUsers = userProvider.users;
                isFetchingUsers = false;
              });
            }

            if (userProvider.users.isEmpty) {
              userProvider.loadUsers().then((_) => updateUsers());
            } else {
              // Use Future.microtask to avoid calling setState during build
              Future.microtask(() => updateUsers());
            }
          }

          final departments = ['Qualité', 'Logistique', 'MM shift A', 'MM shift B', 'SZB shift A', 'SZB shift B', 'Direction', 'IT', 'RH'];

          return AlertDialog(
            title: const Text('Envoyer une notification'),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Destinataires', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: ModernTheme.textSecondary)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('Tous'),
                            selected: targetType == 'all',
                            onSelected: (val) => setDialogState(() => targetType = 'all'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('Dépt'),
                            selected: targetType == 'department',
                            onSelected: (val) => setDialogState(() => targetType = 'department'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('Perso'),
                            selected: targetType == 'user',
                            onSelected: (val) => setDialogState(() => targetType = 'user'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (targetType == 'department')
                      DropdownButtonFormField<String>(
                        value: selectedDepartment,
                        decoration: InputDecoration(
                          labelText: 'Sélectionner le département',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        items: departments.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                        onChanged: (val) => setDialogState(() => selectedDepartment = val),
                      ),
                    if (targetType == 'user')
                      isFetchingUsers 
                        ? const Center(child: CircularProgressIndicator())
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DropdownButtonFormField<User>(
                                decoration: InputDecoration(
                                  labelText: 'Sélectionner un utilisateur',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                items: allUsers.map((u) => DropdownMenuItem(value: u, child: Text(u.fullName))).toList(),
                                onChanged: (u) {
                                  if (u != null && !selectedUsers.any((user) => user.id == u.id)) {
                                    setDialogState(() => selectedUsers.add(u));
                                  }
                                },
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                children: selectedUsers.map((u) => Chip(
                                  label: Text(u.fullName, style: const TextStyle(fontSize: 12)),
                                  onDeleted: () => setDialogState(() => selectedUsers.removeWhere((user) => user.id == u.id)),
                                )).toList(),
                              ),
                            ],
                          ),
                    const Divider(height: 32),
                    ModernTextField(
                      controller: titleController,
                      label: 'Titre',
                      hint: 'Ex: Information importante',
                    ),
                    const SizedBox(height: 16),
                    ModernTextField(
                      controller: messageController,
                      label: 'Message',
                      hint: 'Saisissez votre message ici...',
                      maxLines: 4,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ModernTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                onPressed: () async {
                  if (titleController.text.isEmpty || messageController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez remplir tous les champs')));
                    return;
                  }

                  if (targetType == 'department' && selectedDepartment == null) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez sélectionner un département')));
                    return;
                  }

                  if (targetType == 'user' && selectedUsers.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez sélectionner au moins un utilisateur')));
                    return;
                  }
                  
                  final success = await context.read<NotificationProvider>().sendNotification(
                    title: titleController.text,
                    message: messageController.text,
                    targetUserIds: targetType == 'user' ? selectedUsers.map((u) => u.id).toList() : null,
                    targetDepartment: targetType == 'department' ? selectedDepartment : null,
                    sendToAll: targetType == 'all',
                  );

                  if (context.mounted) {
                    Navigator.pop(context);
                    if (success) {
                      await context.read<NotificationProvider>().loadNotifications();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Notification envoyée avec succès'),
                          backgroundColor: ModernTheme.success,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Échec de l\'envoi de la notification'),
                          backgroundColor: ModernTheme.error,
                        ),
                      );
                    }
                  }
                },
                child: const Text('Envoyer'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _NotificationGroup {
  final String dateLabel;
  final List<NotificationModel> notifications;

  _NotificationGroup(this.dateLabel, this.notifications);
}
