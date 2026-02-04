import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../providers/location_provider.dart';
import '../providers/auth_provider.dart';
import '../models/location_log_model.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  List<Marker> _markers = [];
  bool _hasMovedOnce = false;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadLocations();
      });
    }
  }

  Future<void> _loadLocations() async {
    final locationProvider = context.read<LocationProvider>();
    final authProvider = context.read<AuthProvider>();

    if (authProvider.canManageUsers) {
      await locationProvider.loadTeamLocations();
      _updateMarkers(locationProvider.teamLocations);
    } else {
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
    if (!mounted) return;

    setState(() {
      _markers = locations.map((location) {
        return Marker(
          width: 80.0,
          height: 80.0,
          point: LatLng(location.latitude, location.longitude),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                  ],
                ),
                child: Text(
                  location.userName ?? 'Utilisateur',
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(
                Icons.location_on,
                color: Colors.redAccent,
                size: 40.0,
              ),
            ],
          ),
        );
      }).toList();
    });

    if (locations.isNotEmpty && !_hasMovedOnce) {
      _hasMovedOnce = true;
      _mapController.move(
        LatLng(locations.first.latitude, locations.first.longitude),
        14.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final locationProvider = context.watch<LocationProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          authProvider.canManageUsers ? 'Carte des Équipes' : 'Ma Position',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: kIsWeb ? null : _loadLocations,
          ),
        ],
      ),
      body: kIsWeb
          ? _buildWebLocationList(locationProvider)
          : Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: const MapOptions(
                    initialCenter: LatLng(36.8065, 10.1815),
                    initialZoom: 12,
                    interactionOptions: InteractionOptions(
                      flags: InteractiveFlag.all,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: isDark 
                          ? 'https:
                          : 'https:
                      subdomains: isDark ? const ['a', 'b', 'c'] : const ['a', 'b', 'c'], 
                      userAgentPackageName: 'com.example.employee_communication_app',
                    ),
                    MarkerLayer(markers: _markers),
                    RichAttributionWidget(
                      attributions: [
                        TextSourceAttribution(
                          'OpenStreetMap contributors',
                          onTap: () {},
                        ),
                      ],
                    ),
                  ],
                ),
                if (locationProvider.isLoading)
                  Container(
                    color: Colors.black.withOpacity(0.3),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
      floatingActionButton: kIsWeb
          ? null
          : FloatingActionButton(
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(Icons.my_location, color: Colors.white),
              onPressed: () async {
                await locationProvider.getCurrentLocation();
                if (locationProvider.currentPosition != null) {
                  _mapController.move(
                    LatLng(
                      locationProvider.currentPosition!.latitude,
                      locationProvider.currentPosition!.longitude,
                    ),
                    15.0,
                  );
                }
              },
            ),
    );
  }

  Widget _buildWebLocationList(LocationProvider locationProvider) {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.map, size: 64, color: Colors.blue),
              const SizedBox(height: 16),
              const Text(
                'Version Web',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'La carte interactive est optimisée pour mobile.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              if (locationProvider.teamLocations.isNotEmpty) ...[
                const Text('Dernières positions connues :', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: locationProvider.teamLocations.length,
                    itemBuilder: (context, index) {
                      final loc = locationProvider.teamLocations[index];
                      return ListTile(
                        leading: const Icon(Icons.person_pin_circle, color: Colors.blue),
                        title: Text(loc.userName ?? 'Inconnu'),
                        subtitle: Text('${loc.latitude.toStringAsFixed(4)}, ${loc.longitude.toStringAsFixed(4)}'),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
