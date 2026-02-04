import 'package:json_annotation/json_annotation.dart';
import 'user_model.dart';
import 'department_model.dart';

part 'team_model.g.dart';

@JsonSerializable(explicitToJson: true)
class Team {
  @JsonKey(name: '_id')
  final String id;
  
  final String name;
  final String? description;
  
  @JsonKey(name: 'department', fromJson: _departmentFromJson, toJson: _departmentToJson)
  final Department? department;
  
  static Department? _departmentFromJson(dynamic json) {
    if (json == null) return null;
    if (json is String) return null;
    if (json is Map<String, dynamic>) return Department.fromJson(json);
    return null;
  }
  
  static dynamic _departmentToJson(Department? department) {
    return department?.toJson();
  }
  
  @JsonKey(name: 'leader', fromJson: _userFromJson)
  final User? leader;
  
  static User? _userFromJson(dynamic json) {
    if (json == null) return null;
    if (json is String) return null;
    if (json is Map<String, dynamic>) return User.fromJson(json);
    return null;
  }
  
  @JsonKey(name: 'members', fromJson: _membersFromJson)
  final List<User> members;
  
  static List<User> _membersFromJson(dynamic json) {
    if (json == null) return [];
    if (json is! List) return [];
    return json
        .whereType<Map<String, dynamic>>()
        .map((item) => User.fromJson(item))
        .toList();
  }
  
  final String? color;
  final String? avatar;
  
  @JsonKey(name: 'isActive')
  final bool isActive;
  
  @JsonKey(name: 'createdBy')
  final String? createdBy;
  
  @JsonKey(name: 'updatedBy')
  final String? updatedBy;
  
  @JsonKey(name: 'createdAt')
  final DateTime? createdAt;
  
  @JsonKey(name: 'updatedAt')
  final DateTime? updatedAt;
  
  @JsonKey(name: 'memberCount')
  final int? memberCount;

  Team({
    required this.id,
    required this.name,
    this.description,
    this.department,
    required this.leader,
    this.members = const [],
    this.color,
    this.avatar,
    this.isActive = true,
    this.createdBy,
    this.updatedBy,
    this.createdAt,
    this.updatedAt,
    this.memberCount,
  });

  int get totalMembers => memberCount ?? members.length;

  bool isMember(String userId) {
    return members.any((member) => member.id == userId);
  }

  bool isLeader(String userId) {
    return leader?.id == userId;
  }

  String get memberNames {
    if (members.isEmpty) return 'No members';
    return members.map((m) => m.fullName).join(', ');
  }

  factory Team.fromJson(Map<String, dynamic> json) => _$TeamFromJson(json);

  Map<String, dynamic> toJson() => _$TeamToJson(this);

  Team copyWith({
    String? id,
    String? name,
    String? description,
    Department? department,
    User? leader,
    List<User>? members,
    String? color,
    String? avatar,
    bool? isActive,
    String? createdBy,
    String? updatedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? memberCount,
  }) {
    return Team(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      department: department ?? this.department,
      leader: leader ?? this.leader,
      members: members ?? this.members,
      color: color ?? this.color,
      avatar: avatar ?? this.avatar,
      isActive: isActive ?? this.isActive,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      memberCount: memberCount ?? this.memberCount,
    );
  }

  @override
  String toString() {
    return 'Team(id: $id, name: $name, members: ${members.length}, leader: ${leader?.fullName ?? "No leader"})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Team && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
