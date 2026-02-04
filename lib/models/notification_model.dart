import 'package:json_annotation/json_annotation.dart';

part 'notification_model.g.dart';

@JsonSerializable()
class NotificationModel {
  @JsonKey(name: '_id')
  final String id;
  
  final String title;
  final String message;
  final String type;
  final Map<String, dynamic>? metadata;
  final String senderId;
  final List<String> targetUsers;
  final List<String> readBy;
  final DateTime timestamp;
  
  DateTime get createdAt => timestamp;
  
  bool get isRead => readBy.isNotEmpty;
  
  @JsonKey(includeFromJson: false, includeToJson: false)
  String? senderName;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    this.type = 'general',
    this.metadata,
    required this.senderId,
    required this.targetUsers,
    this.readBy = const [],
    required this.timestamp,
    this.senderName,
  });

  bool isReadBy(String userId) => readBy.contains(userId);

  bool isUnreadBy(String userId) => !readBy.contains(userId);

  int get readCount => readBy.length;

  int get unreadCount => targetUsers.length - readBy.length;

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    String senderId = '';
    String? senderName;

    final senderData = json['senderId'];
    if (senderData is String) {
      senderId = senderData;
    } else if (senderData is Map<String, dynamic>) {
      senderId = senderData['_id'] ?? senderData['id'] ?? '';
      final first = senderData['firstname'] ?? '';
      final last = senderData['lastname'] ?? '';
      if (first.isNotEmpty || last.isNotEmpty) {
        senderName = '$first $last'.trim();
      }
    }

    return NotificationModel(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? 'general',
      metadata: json['metadata'] as Map<String, dynamic>?,
      senderId: senderId,
      senderName: senderName,
      targetUsers: (json['targetUsers'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      readBy: (json['readBy'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : (json['createdAt'] != null
              ? DateTime.parse(json['createdAt'])
              : DateTime.now()),
    );
  }

  Map<String, dynamic> toJson() => _$NotificationModelToJson(this);

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
