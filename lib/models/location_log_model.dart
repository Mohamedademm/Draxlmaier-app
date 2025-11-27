import 'package:json_annotation/json_annotation.dart';

part 'location_log_model.g.dart';

/// LocationLog model representing a user's location at a specific time
@JsonSerializable()
class LocationLog {
  @JsonKey(name: '_id')
  final String id;
  
  final String userId;
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  
  @JsonKey(includeFromJson: false, includeToJson: false)
  String? userName;

  LocationLog({
    required this.id,
    required this.userId,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.userName,
  });

  /// Factory method to create LocationLog from JSON
  factory LocationLog.fromJson(Map<String, dynamic> json) => 
      _$LocationLogFromJson(json);

  /// Method to convert LocationLog to JSON
  Map<String, dynamic> toJson() => _$LocationLogToJson(this);

  /// Copy method for immutable updates
  LocationLog copyWith({
    String? id,
    String? userId,
    double? latitude,
    double? longitude,
    DateTime? timestamp,
    String? userName,
  }) {
    return LocationLog(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timestamp: timestamp ?? this.timestamp,
      userName: userName ?? this.userName,
    );
  }
}
