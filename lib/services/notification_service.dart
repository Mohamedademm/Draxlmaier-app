import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/notification_model.dart';
import 'api_service.dart';

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Only initialize Firebase on mobile platforms
  if (!kIsWeb) {
    await Firebase.initializeApp();
  }
  print('📱 Background message received: ${message.notification?.title}');
}

/// Professional notification service with FCM support
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final ApiService _apiService = ApiService();
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = 
      FlutterLocalNotificationsPlugin();

  /// Request notification permission (called on first launch)
  Future<bool> requestPermission() async {
    try {
      NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
        announcement: false,
        carPlay: false,
        criticalAlert: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('✅ Notification permission granted');
        return true;
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        print('⚠️ Notification permission provisional');
        return true;
      } else {
        print('❌ Notification permission denied');
        return false;
      }
    } catch (e) {
      print('Error requesting permission: $e');
      return false;
    }
  }

  /// Initialize notification service
  Future<void> initialize() async {
    try {
      // Configure local notifications for Android
      const AndroidInitializationSettings androidSettings = 
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const InitializationSettings settings = InitializationSettings(
        android: androidSettings,
      );

      await _localNotifications.initialize(
        settings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Create notification channel for Android
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'high_importance_channel',
        'Notifications Importantes',
        description: 'Canal pour les notifications importantes de l\'application',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle background message clicks
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

      // Check if app was opened from a notification
      RemoteMessage? initialMessage = await _fcm.getInitialMessage();
      if (initialMessage != null) {
        _handleMessageOpenedApp(initialMessage);
      }

      print('✅ Notification service initialized');
    } catch (e) {
      print('Error initializing notifications: $e');
    }
  }

  /// Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    print('📬 Foreground message: ${message.notification?.title}');
    
    // Show local notification when app is in foreground
    if (message.notification != null) {
      _showLocalNotification(
        title: message.notification!.title ?? 'Notification',
        body: message.notification!.body ?? '',
        payload: message.data.toString(),
      );
    }
  }

  /// Handle notification tapped
  void _handleMessageOpenedApp(RemoteMessage message) {
    print('🔔 Notification tapped: ${message.data}');
    // TODO: Navigate to appropriate screen based on message.data
  }

  /// Handle local notification tapped
  void _onNotificationTapped(NotificationResponse response) {
    print('🔔 Local notification tapped: ${response.payload}');
    // TODO: Navigate to appropriate screen
  }

  /// Show local notification
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'Notifications Importantes',
      channelDescription: 'Canal pour les notifications importantes',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      playSound: true,
      enableVibration: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
  }

  /// Get FCM token
  Future<String?> getFcmToken() async {
    try {
      String? token = await _fcm.getToken();
      if (token != null) {
        print('📱 FCM Token: ${token.substring(0, 20)}...');
      }
      return token;
    } catch (e) {
      print('Error getting FCM token: $e');
      return null;
    }
  }

  /// Send FCM token to backend
  Future<void> sendTokenToBackend(String token) async {
    try {
      await _apiService.post('/users/fcm-token', {'fcmToken': token});
      print('✅ FCM token sent to backend');
    } catch (e) {
      print('Error sending token to backend: $e');
    }
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
      await _apiService.put('/notifications/mark-all-read', {});
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

  /// Get admin notifications (filtered by type)
  Future<Map<String, dynamic>> getAdminNotifications({String? type, bool? unreadOnly}) async {
    try {
      final queryParams = <String, String>{};
      if (type != null) queryParams['type'] = type;
      if (unreadOnly != null) queryParams['unreadOnly'] = unreadOnly.toString();

      final response = await _apiService.get('/notifications/admin', queryParams: queryParams);
      final data = _apiService.handleResponse(response);
      
      final List<dynamic> notificationsJson = data['notifications'];
      final notifications = notificationsJson
          .map((json) => NotificationModel.fromJson(json))
          .toList();
      
      return {
        'notifications': notifications,
        'unreadCountsByType': data['unreadCountsByType'] ?? {},
      };
    } catch (e) {
      throw Exception('Failed to get admin notifications: $e');
    }
  }
}
