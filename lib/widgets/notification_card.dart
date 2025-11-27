import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../utils/helpers.dart';

/// Notification card widget
class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final bool isRead;
  final VoidCallback onTap;

  const NotificationCard({
    super.key,
    required this.notification,
    required this.isRead,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: isRead ? null : Colors.blue.withOpacity(0.1),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isRead ? Colors.grey : Colors.blue,
          child: Icon(
            isRead ? Icons.notifications : Icons.notifications_active,
            color: Colors.white,
          ),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notification.message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (notification.senderName != null) ...[
                  Icon(Icons.person, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    notification.senderName!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  DateTimeHelper.getRelativeTime(notification.timestamp),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
        isThreeLine: true,
        trailing: !isRead
            ? Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              )
            : null,
        onTap: onTap,
      ),
    );
  }
}
