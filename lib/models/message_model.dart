/// Enum representing message status
enum MessageStatus {
  sent,
  delivered,
  read,
}

/// Message model representing a chat message
class Message {
  final String id;
  final String senderId;
  final String? receiverId;
  final String? groupId;
  final String content;
  final MessageStatus status;
  final DateTime timestamp;
  
  // File attachments
  final String? fileUrl;
  final String? fileName;
  final String? fileType; // 'image', 'pdf', 'document'
  
  String? senderName;
  bool isMe;

  Message({
    required this.id,
    required this.senderId,
    this.receiverId,
    this.groupId,
    required this.content,
    this.status = MessageStatus.sent,
    required this.timestamp,
    this.fileUrl,
    this.fileName,
    this.fileType,
    this.senderName,
    this.isMe = false,
  });

  /// Check if this is a group message
  bool get isGroupMessage => groupId != null;

  /// Check if this is a direct message
  bool get isDirectMessage => receiverId != null;

  /// Factory method to create Message from JSON
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['_id'] ?? json['id'] ?? '',
      senderId: json['senderId'] is String 
          ? json['senderId'] 
          : (json['senderId']?['_id'] ?? json['senderId']?['id'] ?? ''),
      receiverId: json['receiverId'],
      groupId: json['groupId'],
      content: json['content'] ?? '',
      status: _parseStatus(json['status']),
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp']) 
          : DateTime.now(),
      fileUrl: json['fileUrl'],
      fileName: json['fileName'],
      fileType: json['fileType'],
      senderName: json['senderName'],
      isMe: json['isMe'] ?? false,
    );
  }

  /// Parse status from string
  static MessageStatus _parseStatus(dynamic status) {
    if (status == null) return MessageStatus.sent;
    final statusStr = status.toString().toLowerCase();
    switch (statusStr) {
      case 'delivered':
        return MessageStatus.delivered;
      case 'read':
        return MessageStatus.read;
      default:
        return MessageStatus.sent;
    }
  }

  /// Method to convert Message to JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'groupId': groupId,
      'content': content,
      'status': status.name,
      'timestamp': timestamp.toIso8601String(),
      'fileUrl': fileUrl,
      'fileName': fileName,
      'fileType': fileType,
      'senderName': senderName,
      'isMe': isMe,
    };
  }

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
