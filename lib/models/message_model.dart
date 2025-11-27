import 'package:json_annotation/json_annotation.dart';

part 'message_model.g.dart';

/// Enum representing message status
enum MessageStatus {
  @JsonValue('sent')
  sent,
  @JsonValue('delivered')
  delivered,
  @JsonValue('read')
  read,
}

/// Message model representing a chat message
@JsonSerializable()
class Message {
  @JsonKey(name: '_id')
  final String id;
  
  final String senderId;
  final String? receiverId;
  final String? groupId;
  final String content;
  final MessageStatus status;
  final DateTime timestamp;
  
  @JsonKey(includeFromJson: false, includeToJson: false)
  String? senderName;
  
  @JsonKey(includeFromJson: false, includeToJson: false)
  bool isMe;

  Message({
    required this.id,
    required this.senderId,
    this.receiverId,
    this.groupId,
    required this.content,
    this.status = MessageStatus.sent,
    required this.timestamp,
    this.senderName,
    this.isMe = false,
  });

  /// Check if this is a group message
  bool get isGroupMessage => groupId != null;

  /// Check if this is a direct message
  bool get isDirectMessage => receiverId != null;

  /// Factory method to create Message from JSON
  factory Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);

  /// Method to convert Message to JSON
  Map<String, dynamic> toJson() => _$MessageToJson(this);

  /// Copy method for immutable updates
  Message copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? groupId,
    String? content,
    MessageStatus? status,
    DateTime? timestamp,
    String? senderName,
    bool? isMe,
  }) {
    return Message(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      groupId: groupId ?? this.groupId,
      content: content ?? this.content,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      senderName: senderName ?? this.senderName,
      isMe: isMe ?? this.isMe,
    );
  }
}
