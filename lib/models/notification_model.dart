import 'package:json_annotation/json_annotation.dart';

part 'notification_model.g.dart';

/// Notification model representing a system notification
@JsonSerializable()
class NotificationModel {
  @JsonKey(name: '_id')
  final String id;
  
  final String title;
  final String message;
  final String senderId;
  final List<String> targetUsers;
  final List<String> readBy;
  final DateTime timestamp;
  
  @JsonKey(includeFromJson: false, includeToJson: false)
  String? senderName;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.senderId,
    required this.targetUsers,
    this.readBy = const [],
    required this.timestamp,
    this.senderName,
  });

  /// Check if notification is read by specific user
  bool isReadBy(String userId) => readBy.contains(userId);

  /// Check if notification is unread by specific user
  bool isUnreadBy(String userId) => !readBy.contains(userId);

  /// Get read count
  int get readCount => readBy.length;

  /// Get unread count
  int get unreadCount => targetUsers.length - readBy.length;

  /// Factory method to create NotificationModel from JSON
  factory NotificationModel.fromJson(Map<String, dynamic> json) => 
      _$NotificationModelFromJson(json);

  /// Method to convert NotificationModel to JSON
  Map<String, dynamic> toJson() => _$NotificationModelToJson(this);

  /// Copy method for immutable updates
  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    String? senderId,
    List<String>? targetUsers,
    List<String>? readBy,
    DateTime? timestamp,
    String? senderName,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      senderId: senderId ?? this.senderId,
      targetUsers: targetUsers ?? this.targetUsers,
      readBy: readBy ?? this.readBy,
      timestamp: timestamp ?? this.timestamp,
      senderName: senderName ?? this.senderName,
    );
  }
}
