/// ChatGroup model representing a group chat
class ChatGroup {
  final String id;
  final String name;
  final String? description;
  final String? type;
  final String? department;
  final List<String> members;
  final List<String>? admins;
  final String createdBy;
  final bool? isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
  
  String? lastMessage;
  DateTime? lastMessageTime;
  int unreadCount;

  ChatGroup({
    required this.id,
    required this.name,
    this.description,
    this.type,
    this.department,
    required this.members,
    this.admins,
    required this.createdBy,
    this.isActive,
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
  
  /// Check if user is an admin
  bool isAdmin(String userId) => admins?.contains(userId) ?? false;
  
  /// Check if it's a department group
  bool get isDepartmentGroup => type == 'department';

  /// Factory method to create ChatGroup from JSON
  factory ChatGroup.fromJson(Map<String, dynamic> json) {
    return ChatGroup(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      type: json['type'],
      department: json['department'],
      members: json['members'] != null 
          ? List<String>.from(json['members'].map((m) => m is String ? m : m['_id'] ?? m['id']))
          : [],
      admins: json['admins'] != null
          ? List<String>.from(json['admins'].map((a) => a is String ? a : a['_id'] ?? a['id']))
          : null,
      createdBy: json['createdBy'] is String 
          ? json['createdBy']
          : json['createdBy']?['_id'] ?? json['createdBy']?['id'] ?? '',
      isActive: json['isActive'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  /// Method to convert ChatGroup to JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'type': type,
      'department': department,
      'members': members,
      'admins': admins,
      'createdBy': createdBy,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Copy method for immutable updates
  ChatGroup copyWith({
    String? id,
    String? name,
    String? description,
    String? type,
    String? department,
    List<String>? members,
    List<String>? admins,
    String? createdBy,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? lastMessage,
    DateTime? lastMessageTime,
    int? unreadCount,
  }) {
    return ChatGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      department: department ?? this.department,
      members: members ?? this.members,
      admins: admins ?? this.admins,
      createdBy: createdBy ?? this.createdBy,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}
