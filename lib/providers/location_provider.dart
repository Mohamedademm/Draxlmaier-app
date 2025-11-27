import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../models/location_log_model.dart';
import '../services/location_service.dart';

/// Location tracking state management provider
class LocationProvider with ChangeNotifier {
  final LocationService _locationService = LocationService();

  Position? _currentPosition;
  List<LocationLog> _teamLocations = [];
  bool _isTracking = false;
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<Position>? _positionSubscription;

  Position? get currentPosition => _currentPosition;
  List<LocationLog> get teamLocations => _teamLocations;
  bool get isTracking => _isTracking;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Get current location
  Future<void> getCurrentLocation() async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentPosition = await _locationService.getCurrentPosition();
      
      // Update location on server
      await _locationService.updateLocation(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Start tracking location
  Future<void> startTracking() async {
    if (_isTracking) return;

    try {
      _isTracking = true;
      notifyListeners();

      _positionSubscription = _locationService.trackLocation().listen(
        (position) async {
          _currentPosition = position;
          
          // Update location on server
          try {
            await _locationService.updateLocation(
              position.latitude,
              position.longitude,
            );
          } catch (e) {
            print('Failed to update location: $e');
          }
          
          notifyListeners();
        },
        onError: (error) {
          _errorMessage = error.toString();
          _isTracking = false;
          notifyListeners();
        },
      );
    } catch (e) {
      _errorMessage = e.toString();
      _isTracking = false;
      notifyListeners();
    }
  }

  /// Stop tracking location
  void stopTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _isTracking = false;
    notifyListeners();
  }

  /// Load team member locations (Admin/Manager only)
  Future<void> loadTeamLocations() async {
    _isLoading = true;
    notifyListeners();

    try {
      _teamLocations = await _locationService.getTeamLocations();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Request location permission
  Future<bool> requestPermission() async {
    try {
      return await _locationService.requestPermission();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Check if location permission is granted
  Future<bool> hasPermission() async {
    try {
      return await _locationService.hasPermission();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Calculate distance to a location
  double? calculateDistanceTo(double latitude, double longitude) {
    if (_currentPosition == null) return null;
    
    return _locationService.calculateDistance(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      latitude,
      longitude,
    );
  }

  /// Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    stopTracking();
    super.dispose();
  }
}
