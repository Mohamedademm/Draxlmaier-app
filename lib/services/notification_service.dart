// import 'package:firebase_messaging/firebase_messaging.dart';
import '../models/notification_model.dart';
import 'api_service.dart';

/// Notification service handling notifications (Firebase disabled for web)
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final ApiService _apiService = ApiService();

  /// Initialize notification service
  Future<void> initialize() async {
    print('Notification service initialized (Firebase disabled for web)');
    // Firebase messaging disabled for web compatibility
  }

  /// Get FCM token (returns null when Firebase is disabled)
  Future<String?> getFcmToken() async {
    return null;
  }

  /// Get all notifications from server
  Future<List<NotificationModel>> getNotifications() async {
    try {
      final response = await _apiService.get('/notifications');
      final data = _apiService.handleResponse(response);
      
      final List<dynamic> notificationsJson = data['notifications'];
      return notificationsJson
          .map((json) => NotificationModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get notifications: $e');
    }
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _apiService.post('/notifications/$notificationId/read', {});
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead(String userId) async {
    try {
      final response = await _apiService.put('/notifications/mark-all-read', {});
      // Note: Assuming the API returns 200 OK on success
    } catch (e) {
      throw Exception('Failed to mark all as read: $e');
    }
  }

  /// Create and send notification (Admin/Manager only)
  Future<void> sendNotification({
    required String title,
    required String message,
    List<String>? targetUserIds,
    String? targetDepartment,
    bool sendToAll = false,
  }) async {
    try {
      await _apiService.post('/notifications/send', {
        'title': title,
        'message': message,
        'targetUsers': targetUserIds ?? [],
        'targetDepartment': targetDepartment,
        'sendToAll': sendToAll,
      });
    } catch (e) {
      throw Exception('Failed to send notification: $e');
    }
  }

  /// Get unread notification count
  Future<int> getUnreadCount() async {
    try {
      final response = await _apiService.get('/notifications/unread-count');
      final data = _apiService.handleResponse(response);
      return data['count'] ?? 0;
    } catch (e) {
      throw Exception('Failed to get unread count: $e');
    }
  }
}
