import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/location_log_model.dart';
import 'api_service.dart';

class LocationService {
  final ApiService _apiService = ApiService();

  Future<bool> hasPermission() async {
    final status = await Permission.location.status;
    return status.isGranted;
  }

  Future<bool> requestPermission() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }

  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  Future<Position> getCurrentPosition() async {
    bool serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled');
    }

    bool hasPermission = await this.hasPermission();
    if (!hasPermission) {
      bool granted = await requestPermission();
      if (!granted) {
        throw Exception('Location permission denied');
      }
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Stream<Position> trackLocation() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 50,
      ),
    );
  }

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

  double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000;
  }
}
