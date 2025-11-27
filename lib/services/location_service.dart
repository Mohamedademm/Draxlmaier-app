import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/location_log_model.dart';
import 'api_service.dart';

/// Location service handling GPS tracking and location updates
class LocationService {
  final ApiService _apiService = ApiService();

  /// Check if location permission is granted
  Future<bool> hasPermission() async {
    final status = await Permission.location.status;
    return status.isGranted;
  }

  /// Request location permission
  Future<bool> requestPermission() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }

  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Get current position
  Future<Position> getCurrentPosition() async {
    // Check if location services are enabled
    bool serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled');
    }

    // Check permission
    bool hasPermission = await this.hasPermission();
    if (!hasPermission) {
      bool granted = await requestPermission();
      if (!granted) {
        throw Exception('Location permission denied');
      }
    }

    // Get current position
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  /// Start tracking location in background
  Stream<Position> trackLocation() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 50, // Update every 50 meters
      ),
    );
  }

  /// Update user location on server
  Future<void> updateLocation(double latitude, double longitude) async {
    try {
      await _apiService.post('/location/update', {
        'latitude': latitude,
        'longitude': longitude,
      });
    } catch (e) {
      throw Exception('Failed to update location: $e');
    }
  }

  /// Get team member locations (Admin/Manager only)
  Future<List<LocationLog>> getTeamLocations() async {
    try {
      final response = await _apiService.get('/location/team');
      final data = _apiService.handleResponse(response);
      
      final List<dynamic> locationsJson = data['locations'];
      return locationsJson.map((json) => LocationLog.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get team locations: $e');
    }
  }

  /// Get user's own location history
  Future<List<LocationLog>> getMyLocationHistory() async {
    try {
      final response = await _apiService.get('/location/my-history');
      final data = _apiService.handleResponse(response);
      
      final List<dynamic> locationsJson = data['locations'];
      return locationsJson.map((json) => LocationLog.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get location history: $e');
    }
  }

  /// Calculate distance between two coordinates in kilometers
  double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000;
  }
}
