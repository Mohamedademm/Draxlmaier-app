import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

enum UserRole {
  @JsonValue('admin')
  admin,
  @JsonValue('manager')
  manager,
  @JsonValue('employee')
  employee,
}

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

  String get fullName => '$firstname $lastname';

  bool get isAdmin => role == UserRole.admin;

  bool get isManager => role == UserRole.manager;

  bool get isEmployee => role == UserRole.employee;

  bool get canManageUsers => isAdmin || isManager;

  factory User.fromJson(Map<String, dynamic> json) {
    UserRole parseRole(dynamic roleData) {
      if (roleData == null) return UserRole.employee;
      
      String? roleStr;
      if (roleData is String) {
        roleStr = roleData;
      } else if (roleData is Map && roleData.containsKey('name')) {
        roleStr = roleData['name'];
      } else if (roleData is Map && roleData.containsKey('role')) {
        roleStr = roleData['role'];
      }

      if (roleStr == null) return UserRole.employee;

      switch (roleStr.toLowerCase()) {
        case 'admin':
          return UserRole.admin;
        case 'manager':
          return UserRole.manager;
        case 'employee':
          return UserRole.employee;
        default:
          return UserRole.employee;
      }
    }

    return User(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      firstname: (json['firstname'] ?? json['first_name'] ?? '').toString(),
      lastname: (json['lastname'] ?? json['last_name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      role: parseRole(json['role']),
      active: json['active'] == true || json['active'] == null,
      fcmToken: json['fcmToken']?.toString(),
      phone: json['phone']?.toString(),
      position: json['position']?.toString(),
      department: json['department']?.toString(),
      address: json['address']?.toString(),
      city: json['city']?.toString(),
      postalCode: json['postalCode']?.toString(),
      latitude: json['latitude'] is num ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] is num ? (json['longitude'] as num).toDouble() : null,
      status: json['status']?.toString(),
      profileImage: json['profileImage']?.toString(),
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'firstname': firstname,
      'lastname': lastname,
      'email': email,
      'role': role.name,
      'active': active,
      'phone': phone,
      'position': position,
      'department': department,
      'address': address,
      'city': city,
      'postalCode': postalCode,
      'latitude': latitude,
      'longitude': longitude,
      'status': status,
      'profileImage': profileImage,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

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
