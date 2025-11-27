import 'package:json_annotation/json_annotation.dart';

part 'chat_group_model.g.dart';

/// ChatGroup model representing a group chat
@JsonSerializable()
class ChatGroup {
  @JsonKey(name: '_id')
  final String id;
  
  final String name;
  final List<String> members;
  final String createdBy;
  final DateTime createdAt;
  final DateTime? updatedAt;
  
  @JsonKey(includeFromJson: false, includeToJson: false)
  String? lastMessage;
  
  @JsonKey(includeFromJson: false, includeToJson: false)
  DateTime? lastMessageTime;
  
  @JsonKey(includeFromJson: false, includeToJson: false)
  int unreadCount;

  ChatGroup({
    required this.id,
    required this.name,
    required this.members,
    required this.createdBy,
    required this.createdAt,
    this.updatedAt,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
  });

  /// Get member count
  int get memberCount => members.length;

  /// Check if user is a member
  bool isMember(String userId) => members.contains(userId);

  /// Factory method to create ChatGroup from JSON
  factory ChatGroup.fromJson(Map<String, dynamic> json) => _$ChatGroupFromJson(json);

  /// Method to convert ChatGroup to JSON
  Map<String, dynamic> toJson() => _$ChatGroupToJson(this);

  /// Copy method for immutable updates
  ChatGroup copyWith({
    String? id,
    String? name,
    List<String>? members,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? lastMessage,
    DateTime? lastMessageTime,
    int? unreadCount,
  }) {
    return ChatGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      members: members ?? this.members,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}
