import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/notification_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import '../models/notification_model.dart';
import '../models/user_model.dart';
import '../widgets/modern_widgets.dart';

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
      backgroundColor: const Color(0xFFF8FAFC),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 160.0,
              floating: false,
              pinned: true,
              elevation: 0,
              backgroundColor: const Color(0xFF0EA5E9),
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                title: Row(
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOutBack,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: child,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.notifications_active_rounded, color: Colors.white, size: 24),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Notifications',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF0EA5E9),
                        Color(0xFF06B6D4),
                        Color(0xFF0891B2),
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -50,
                        top: -30,
                        child: Icon(
                          Icons.notifications_outlined,
                          size: 200,
                          color: Colors.white.withOpacity(0.08),
                        ),
                      ),
                      Positioned(
                        left: -30,
                        bottom: -40,
                        child: Icon(
                          Icons.notification_important_outlined,
                          size: 150,
                          color: Colors.white.withOpacity(0.08),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.done_all_rounded, color: Colors.white),
                    onPressed: () => _markAllAsRead(currentUserId),
                    tooltip: 'Tout marquer comme lu',
                  ),
                ),
                if (authProvider.canManageUsers)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.add_circle_outline_rounded, color: Colors.white),
                      onPressed: _showSendNotificationDialog,
                      tooltip: 'Envoyer une notification',
                    ),
                  ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: TabBar(
                    controller: _tabController,
                    labelColor: const Color(0xFF0EA5E9),
                    unselectedLabelColor: const Color(0xFF94A3B8),
                    indicatorColor: const Color(0xFF0EA5E9),
                    indicatorWeight: 3,
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    tabs: const [
                      Tab(text: 'Toutes'),
                      Tab(text: 'Non lues'),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: Consumer<NotificationProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF0EA5E9),
                ),
              );
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
      ),
    );
  }

  Widget _buildNotificationsList(List<NotificationModel> notifications, String currentUserId) {
    if (notifications.isEmpty) {
      return const Center(
        child: EmptyState(
          icon: Icons.notifications_none_rounded,
          title: 'Aucune notification',
          message: 'Vous êtes à jour !',
        ),
      );
    }

    final grouped = _groupNotificationsByDate(notifications);

    return RefreshIndicator(
      color: const Color(0xFF0EA5E9),
      onRefresh: _loadNotifications,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: grouped.length,
        itemBuilder: (context, index) {
          final group = grouped[index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF0EA5E9).withOpacity(0.15),
                      const Color(0xFF06B6D4).withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  group.dateLabel,
                  style: const TextStyle(
                    color: Color(0xFF0891B2),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              ...group.notifications.asMap().entries.map((entry) {
                final idx = entry.key;
                final notification = entry.value;
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: Duration(milliseconds: 400 + (idx * 50)),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: Opacity(
                        opacity: value,
                        child: child,
                      ),
                    );
                  },
                  child: _buildNotificationItem(notification, currentUserId),
                );
              }),
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
    final isRecipient = notification.targetUsers.isEmpty || notification.targetUsers.contains(currentUserId);

    return Dismissible(
      key: Key(notification.id),
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF10B981), Color(0xFF059669)],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_rounded, color: Colors.white, size: 28),
            SizedBox(height: 4),
            Text(
              'Lu',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        if (!isRead && !isSender && isRecipient) {
          await context.read<NotificationProvider>().markAsRead(
            notification.id,
            currentUserId,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: Colors.white),
                  SizedBox(width: 12),
                  Text('Marquée comme lue'),
                ],
              ),
              backgroundColor: const Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              duration: const Duration(seconds: 1),
            ),
          );
        }
        return false;
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isRead 
                ? const Color(0xFF94A3B8).withOpacity(0.2)
                : const Color(0xFF0EA5E9).withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isRead 
                  ? Colors.black.withOpacity(0.05)
                  : const Color(0xFF0EA5E9).withOpacity(0.15),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () async {
              if (!isRead && !isSender && isRecipient) {
                await context.read<NotificationProvider>().markAsRead(
                  notification.id,
                  currentUserId,
                );
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isRead
                            ? [const Color(0xFF94A3B8), const Color(0xFF64748B)]
                            : [const Color(0xFF0EA5E9), const Color(0xFF0891B2)],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (isRead ? const Color(0xFF94A3B8) : const Color(0xFF0EA5E9))
                              .withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      isRead 
                          ? Icons.notifications_none_rounded 
                          : Icons.notifications_active_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
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
                                  fontWeight: isRead ? FontWeight.w600 : FontWeight.bold,
                                  color: const Color(0xFF1E293B),
                                  fontSize: 16,
                                  letterSpacing: 0.1,
                                  height: 1.3,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFF0EA5E9).withOpacity(0.15),
                                    const Color(0xFF06B6D4).withOpacity(0.1),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.access_time_rounded,
                                    size: 12,
                                    color: Color(0xFF0891B2),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _formatTime(notification.createdAt),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF0891B2),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          notification.message,
                          style: TextStyle(
                            color: isRead ? const Color(0xFF64748B) : const Color(0xFF1E293B),
                            fontSize: 14,
                            height: 1.6,
                            letterSpacing: 0.2,
                            fontWeight: isRead ? FontWeight.w400 : FontWeight.w500,
                          ),
                          textAlign: TextAlign.justify,
                        ),
                      ],
                    ),
                  ),
                  if (!isRead && !isSender && isRecipient)
                    Container(
                      margin: const EdgeInsets.only(left: 12, top: 4),
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0EA5E9), Color(0xFF0891B2)],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0EA5E9).withOpacity(0.5),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
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
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white),
              SizedBox(width: 12),
              Text(
                'Toutes les notifications marquées comme lues',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _showSendNotificationDialog() {
    final titleController = TextEditingController();
    final messageController = TextEditingController();
    String targetType = 'all';
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
            
            void updateUsers() {
              setDialogState(() {
                allUsers = userProvider.users;
                isFetchingUsers = false;
              });
            }

            if (userProvider.users.isEmpty) {
              userProvider.loadUsers().then((_) => updateUsers());
            } else {
              Future.microtask(() => updateUsers());
            }
          }

          final departments = ['Qualité', 'Logistique', 'MM shift A', 'MM shift B', 'SZB shift A', 'SZB shift B', 'Direction', 'IT', 'RH'];

          return AlertDialog(
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0EA5E9), Color(0xFF0891B2)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                const Text('Envoyer une notification'),
              ],
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF0EA5E9).withOpacity(0.1),
                            const Color(0xFF06B6D4).withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.people_rounded, color: Color(0xFF0891B2), size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Destinataires',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Color(0xFF0891B2),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildModernChoiceChip('Tous', targetType == 'all', () => setDialogState(() => targetType = 'all')),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildModernChoiceChip('Dépt', targetType == 'department', () => setDialogState(() => targetType = 'department')),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildModernChoiceChip('Perso', targetType == 'user', () => setDialogState(() => targetType = 'user')),
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
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: EdgeInsets.zero,
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
                        SnackBar(
                          content: const Row(
                            children: [
                              Icon(Icons.check_circle_rounded, color: Colors.white),
                              SizedBox(width: 12),
                              Text(
                                'Notification envoyée avec succès',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          backgroundColor: const Color(0xFF10B981),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Row(
                            children: [
                              Icon(Icons.error_rounded, color: Colors.white),
                              SizedBox(width: 12),
                              Text(
                                'Échec de l\'envoi de la notification',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          backgroundColor: const Color(0xFFEF4444),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    }
                  }
                },
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0EA5E9), Color(0xFF0891B2)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.send_rounded, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Envoyer',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildModernChoiceChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          gradient: selected
              ? const LinearGradient(
                  colors: [Color(0xFF0EA5E9), Color(0xFF0891B2)],
                )
              : null,
          color: selected ? null : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? const Color(0xFF0891B2) : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : Colors.grey.shade700,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationGroup {
  final String dateLabel;
  final List<NotificationModel> notifications;

  _NotificationGroup(this.dateLabel, this.notifications);
}
