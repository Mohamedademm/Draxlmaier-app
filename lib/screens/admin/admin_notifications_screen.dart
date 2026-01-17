import 'package:flutter/material.dart';
import '../../models/notification_model.dart';
import '../../services/notification_service.dart';
import 'package:intl/intl.dart';

class AdminNotificationsScreen extends StatefulWidget {
  const AdminNotificationsScreen({super.key});

  @override
  State<AdminNotificationsScreen> createState() => _AdminNotificationsScreenState();
}

class _AdminNotificationsScreenState extends State<AdminNotificationsScreen> {
  final NotificationService _notificationService = NotificationService();
  
  List<NotificationModel> _notifications = [];
  Map<String, dynamic> _unreadCountsByType = {};
  bool _isLoading = true;
  String? _selectedType;
  bool _showUnreadOnly = false;

  final List<Map<String, String>> _notificationTypes = [
    {'value': 'all', 'label': 'Toutes', 'icon': '📬'},
    {'value': 'address_change', 'label': 'Changements d\'adresse', 'icon': '📍'},
    {'value': 'department_update', 'label': 'Départements', 'icon': '🏢'},
    {'value': 'system', 'label': 'Système', 'icon': '⚙️'},
    {'value': 'general', 'label': 'Général', 'icon': '📢'},
  ];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);

    try {
      final result = await _notificationService.getAdminNotifications(
        type: _selectedType == 'all' ? null : _selectedType,
        unreadOnly: _showUnreadOnly ? true : null,
      );

      setState(() {
        _notifications = result['notifications'] as List<NotificationModel>;
        _unreadCountsByType = result['unreadCountsByType'] as Map<String, dynamic>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _markAsRead(String notificationId) async {
    try {
      await _notificationService.markAsRead(notificationId);
      await _loadNotifications(); // Refresh list
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications Admin'),
        backgroundColor: const Color(0xFF0EA5E9),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadNotifications,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtres
          Container(
            color: Colors.grey[100],
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Type filter
                const Text(
                  'Filtrer par type:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _notificationTypes.map((type) {
                    final isSelected = _selectedType == type['value'] || 
                                      (_selectedType == null && type['value'] == 'all');
                    final unreadCount = type['value'] != 'all' 
                        ? _unreadCountsByType[type['value']] ?? 0 
                        : _unreadCountsByType.values.fold<int>(0, (sum, count) => sum + (count as int));
                    
                    return FilterChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(type['icon']!),
                          const SizedBox(width: 4),
                          Text(type['label']!),
                          if (unreadCount > 0) ...[
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '$unreadCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedType = type['value'] == 'all' ? null : type['value'];
                        });
                        _loadNotifications();
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
                // Unread only toggle
                Row(
                  children: [
                    Checkbox(
                      value: _showUnreadOnly,
                      onChanged: (value) {
                        setState(() => _showUnreadOnly = value ?? false);
                        _loadNotifications();
                      },
                    ),
                    const Text('Non-lues uniquement'),
                  ],
                ),
              ],
            ),
          ),
          
          // Liste des notifications
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _notifications.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.notifications_off,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Aucune notification',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadNotifications,
                        child: ListView.builder(
                          itemCount: _notifications.length,
                          itemBuilder: (context, index) {
                            final notification = _notifications[index];
                            return _buildNotificationCard(notification);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    final isUnread = !notification.isRead;
    final isAddressChange = notification.type == 'address_change';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: isUnread ? const Color(0xFFE0F2FE) : Colors.white,
      child: InkWell(
        onTap: isUnread ? () => _markAsRead(notification.id) : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Icon based on type
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getNotificationColor(notification.type).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getNotificationIcon(notification.type),
                      color: _getNotificationColor(notification.type),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                notification.title,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                                ),
                              ),
                            ),
                            if (isUnread)
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF0EA5E9),
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('dd/MM/yyyy à HH:mm').format(notification.timestamp),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
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
                style: const TextStyle(fontSize: 14),
              ),
              
              // Afficher les détails pour les changements d'adresse
              if (isAddressChange && notification.metadata != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Utilisateur: ${notification.metadata!['userFullName'] ?? 'Inconnu'}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Ancienne adresse:',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        _formatAddress(notification.metadata!['oldAddress']),
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Nouvelle adresse:',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        _formatAddress(notification.metadata!['newAddress']),
                        style: const TextStyle(fontSize: 12, color: Color(0xFF0EA5E9), fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
              
              if (isUnread) ...[
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => _markAsRead(notification.id),
                  child: const Text('Marquer comme lu'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatAddress(Map<String, dynamic>? address) {
    if (address == null) return 'Non renseignée';
    
    final parts = <String>[];
    if (address['address'] != null && address['address'].toString().isNotEmpty) {
      parts.add(address['address'].toString());
    }
    if (address['city'] != null && address['city'].toString().isNotEmpty) {
      parts.add(address['city'].toString());
    }
    if (address['postalCode'] != null && address['postalCode'].toString().isNotEmpty) {
      parts.add(address['postalCode'].toString());
    }
    
    return parts.isEmpty ? 'Non renseignée' : parts.join(', ');
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'address_change':
        return Icons.location_on;
      case 'department_update':
        return Icons.business;
      case 'system':
        return Icons.settings;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'address_change':
        return const Color(0xFF0EA5E9);
      case 'department_update':
        return const Color(0xFF8B5CF6);
      case 'system':
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF6B7280);
    }
  }
}
