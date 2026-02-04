import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../models/location_log_model.dart';
import '../services/location_service.dart';

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

  Future<void> getCurrentLocation() async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentPosition = await _locationService.getCurrentPosition();
      
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

  Future<void> startTracking() async {
    if (_isTracking) return;

    try {
      _isTracking = true;
      notifyListeners();

      _positionSubscription = _locationService.trackLocation().listen(
        (position) async {
          _currentPosition = position;
          
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

  void stopTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _isTracking = false;
    notifyListeners();
  }

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

  Future<bool> requestPermission() async {
    try {
      return await _locationService.requestPermission();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> hasPermission() async {
    try {
      return await _locationService.hasPermission();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  double? calculateDistanceTo(double latitude, double longitude) {
    if (_currentPosition == null) return null;
    
    return _locationService.calculateDistance(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      latitude,
      longitude,
    );
  }

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
