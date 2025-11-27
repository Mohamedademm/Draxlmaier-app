import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/location_provider.dart';
import '../providers/auth_provider.dart';
import '../models/location_log_model.dart';

/// Map screen showing employee locations
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  Future<void> _loadLocations() async {
    final locationProvider = context.read<LocationProvider>();
    final authProvider = context.read<AuthProvider>();

    if (authProvider.canManageUsers) {
      // Load team locations for admin/manager
      await locationProvider.loadTeamLocations();
      _updateMarkers(locationProvider.teamLocations);
    } else {
      // Load only current user location for employees
      await locationProvider.getCurrentLocation();
      if (locationProvider.currentPosition != null) {
        _updateMarkers([
          LocationLog(
            id: 'current',
            userId: authProvider.currentUser?.id ?? '',
            latitude: locationProvider.currentPosition!.latitude,
            longitude: locationProvider.currentPosition!.longitude,
            timestamp: DateTime.now(),
            userName: authProvider.currentUser?.fullName,
          ),
        ]);
      }
    }
  }

  void _updateMarkers(List<LocationLog> locations) {
    setState(() {
      _markers = locations.map((location) {
        return Marker(
          markerId: MarkerId(location.userId),
          position: LatLng(location.latitude, location.longitude),
          infoWindow: InfoWindow(
            title: location.userName ?? 'Unknown',
            snippet: 'Last updated: ${location.timestamp.toString()}',
          ),
        );
      }).toSet();
    });

    // Move camera to first location
    if (locations.isNotEmpty && _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(locations.first.latitude, locations.first.longitude),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final locationProvider = context.watch<LocationProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          authProvider.canManageUsers ? 'Team Locations' : 'My Location',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadLocations,
          ),
        ],
      ),
      body: locationProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(0, 0),
                zoom: 12,
              ),
              markers: _markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              onMapCreated: (controller) {
                _mapController = controller;
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await locationProvider.getCurrentLocation();
          if (locationProvider.currentPosition != null) {
            _mapController?.animateCamera(
              CameraUpdate.newLatLng(
                LatLng(
                  locationProvider.currentPosition!.latitude,
                  locationProvider.currentPosition!.longitude,
                ),
              ),
            );
          }
        },
        child: const Icon(Icons.my_location),
      ),
    );
  }
}
