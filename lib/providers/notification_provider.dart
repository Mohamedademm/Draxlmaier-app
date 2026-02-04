import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationService _notificationService = NotificationService();

  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _errorMessage;

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<NotificationModel> get unreadNotifications =>
      _notifications.where((n) => n.readBy.isEmpty).toList();

  List<NotificationModel> get readNotifications =>
      _notifications.where((n) => n.readBy.isNotEmpty).toList();

  Future<void> initialize() async {
    try {
      await _notificationService.initialize();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadNotifications() async {
    _isLoading = true;
    notifyListeners();

    try {
      _notifications = await _notificationService.getNotifications();
      await _updateUnreadCount();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String notificationId, String userId) async {
    try {
      await _notificationService.markAsRead(notificationId);
      
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        final updatedReadBy = [..._notifications[index].readBy, userId];
        _notifications[index] = _notifications[index].copyWith(
          readBy: updatedReadBy,
        );
        await _updateUnreadCount();
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> markAllAsRead(String userId) async {
    try {
      await _notificationService.markAllAsRead(userId);
      
      for (var i = 0; i < _notifications.length; i++) {
        if (!_notifications[i].readBy.contains(userId)) {
          final updatedReadBy = [..._notifications[i].readBy, userId];
          _notifications[i] = _notifications[i].copyWith(readBy: updatedReadBy);
        }
      }
      
      await _updateUnreadCount();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<bool> sendNotification({
    required String title,
    required String message,
    List<String>? targetUserIds,
    String? targetDepartment,
    bool sendToAll = false,
  }) async {
    try {
      await _notificationService.sendNotification(
        title: title,
        message: message,
        targetUserIds: targetUserIds,
        targetDepartment: targetDepartment,
        sendToAll: sendToAll,
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> _updateUnreadCount() async {
    try {
      _unreadCount = await _notificationService.getUnreadCount();
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  Future<void> refreshUnreadCount() async {
    await _updateUnreadCount();
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
