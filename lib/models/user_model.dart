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
  
  final String? phone;
  final String? position;
  final String? department;
  final String? address;
  final String? city;
  final String? postalCode;
  final double? latitude;
  final double? longitude;
  final String? status;
  final String? profileImage;
  
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
    this.phone,
    this.position,
    this.department,
    this.address,
    this.city,
    this.postalCode,
    this.latitude,
    this.longitude,
    this.status,
    this.profileImage,
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
    String? phone,
    String? position,
    String? department,
    String? address,
    String? city,
    String? postalCode,
    double? latitude,
    double? longitude,
    String? status,
    String? profileImage,
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
      phone: phone ?? this.phone,
      position: position ?? this.position,
      department: department ?? this.department,
      address: address ?? this.address,
      city: city ?? this.city,
      postalCode: postalCode ?? this.postalCode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      status: status ?? this.status,
      profileImage: profileImage ?? this.profileImage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
