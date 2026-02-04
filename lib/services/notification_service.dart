import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/notification_model.dart';
import 'api_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (!kIsWeb) {
    await Firebase.initializeApp();
  }
  print('📱 Background message received: ${message.notification?.title}');
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final ApiService _apiService = ApiService();
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = 
      FlutterLocalNotificationsPlugin();

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

  Future<void> initialize() async {
    try {
      const AndroidInitializationSettings androidSettings = 
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const InitializationSettings settings = InitializationSettings(
        android: androidSettings,
      );

      await _localNotifications.initialize(
        settings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

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

      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

      RemoteMessage? initialMessage = await _fcm.getInitialMessage();
      if (initialMessage != null) {
        _handleMessageOpenedApp(initialMessage);
      }

      print('✅ Notification service initialized');
    } catch (e) {
      print('Error initializing notifications: $e');
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    print('📬 Foreground message: ${message.notification?.title}');
    
    if (message.notification != null) {
      _showLocalNotification(
        title: message.notification!.title ?? 'Notification',
        body: message.notification!.body ?? '',
        payload: message.data.toString(),
      );
    }
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    print('🔔 Notification tapped: ${message.data}');
    // TODO: Navigate to appropriate screen based on message.data
  }

  void _onNotificationTapped(NotificationResponse response) {
    print('🔔 Local notification tapped: ${response.payload}');
    // TODO: Navigate to appropriate screen
  }

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

  Future<void> sendTokenToBackend(String token) async {
    try {
      await _apiService.post('/users/fcm-token', {'fcmToken': token});
      print('✅ FCM token sent to backend');
    } catch (e) {
      print('Error sending token to backend: $e');
    }
  }

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

  Future<void> markAsRead(String notificationId) async {
    try {
      await _apiService.post('/notifications/$notificationId/read', {});
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  Future<void> markAllAsRead(String userId) async {
    try {
      await _apiService.put('/notifications/mark-all-read', {});
    } catch (e) {
      throw Exception('Failed to mark all as read: $e');
    }
  }

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

  Future<int> getUnreadCount() async {
    try {
      final response = await _apiService.get('/notifications/unread-count');
      final data = _apiService.handleResponse(response);
      return data['count'] ?? 0;
    } catch (e) {
      throw Exception('Failed to get unread count: $e');
    }
  }

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
