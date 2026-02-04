import 'package:json_annotation/json_annotation.dart';
import 'user_model.dart';

part 'department_model.g.dart';

@JsonSerializable(explicitToJson: true)
class Department {
  @JsonKey(name: '_id')
  final String id;
  
  final String name;
  final String? description;
  
  @JsonKey(name: 'manager', fromJson: _userFromJson)
  final User? manager;
  
  static User? _userFromJson(dynamic json) {
    if (json == null) return null;
    if (json is String) return null;
    if (json is Map<String, dynamic>) return User.fromJson(json);
    return null;
  }

  final String? location;
  final String? color;
  final int? budget;
  
  @JsonKey(name: 'employeeCount')
  final int? employeeCount;
  
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

  Department({
    required this.id,
    required this.name,
    this.description,
    this.manager,
    this.location,
    this.color,
    this.budget,
    this.employeeCount,
    this.isActive = true,
    this.createdBy,
    this.updatedBy,
    this.createdAt,
    this.updatedAt,
  });

  String get formattedBudget {
    if (budget == null) return 'N/A';
    return '€${budget! ~/ 1000}K';
  }

  bool isManager(String userId) {
    return manager?.id == userId;
  }

  String get displayInfo {
    final parts = <String>[];
    if (location != null) parts.add(location!);
    if (employeeCount != null) parts.add('$employeeCount employees');
    if (budget != null) parts.add(formattedBudget);
    return parts.join(' • ');
  }

  factory Department.fromJson(Map<String, dynamic> json) => _$DepartmentFromJson(json);

  Map<String, dynamic> toJson() => _$DepartmentToJson(this);

  Department copyWith({
    String? id,
    String? name,
    String? description,
    User? manager,
    String? location,
    String? color,
    int? budget,
    int? employeeCount,
    bool? isActive,
    String? createdBy,
    String? updatedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Department(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      manager: manager ?? this.manager,
      location: location ?? this.location,
      color: color ?? this.color,
      budget: budget ?? this.budget,
      employeeCount: employeeCount ?? this.employeeCount,
      isActive: isActive ?? this.isActive,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Department(id: $id, name: $name, manager: ${manager?.fullName ?? "No manager"}, employees: $employeeCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Department && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
