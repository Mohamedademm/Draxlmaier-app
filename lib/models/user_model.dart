import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

/// Enum representing user roles in the system
enum UserRole {
  @JsonValue('admin')
  admin,
  @JsonValue('manager')
  manager,
  @JsonValue('employee')
  employee,
}

/// User model representing an employee in the system
@JsonSerializable()
class User {
  @JsonKey(name: '_id')
  final String id;
  
  final String firstname;
  final String lastname;
  final String email;
  final UserRole role;
  final bool active;
  
  @JsonKey(includeFromJson: false, includeToJson: false)
  String? fcmToken;
  
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.email,
    required this.role,
    this.active = true,
    this.fcmToken,
    this.createdAt,
    this.updatedAt,
  });

  /// Full name getter
  String get fullName => '$firstname $lastname';

  /// Check if user is admin
  bool get isAdmin => role == UserRole.admin;

  /// Check if user is manager
  bool get isManager => role == UserRole.manager;

  /// Check if user is employee
  bool get isEmployee => role == UserRole.employee;

  /// Check if user has admin or manager privileges
  bool get canManageUsers => isAdmin || isManager;

  /// Factory method to create User from JSON
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  /// Method to convert User to JSON
  Map<String, dynamic> toJson() => _$UserToJson(this);

  /// Copy method for immutable updates
  User copyWith({
    String? id,
    String? firstname,
    String? lastname,
    String? email,
    UserRole? role,
    bool? active,
    String? fcmToken,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      firstname: firstname ?? this.firstname,
      lastname: lastname ?? this.lastname,
      email: email ?? this.email,
      role: role ?? this.role,
      active: active ?? this.active,
      fcmToken: fcmToken ?? this.fcmToken,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
