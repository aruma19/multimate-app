import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TrackinglbsPage extends StatefulWidget {
  const TrackinglbsPage({super.key});

  @override
  State<TrackinglbsPage> createState() => _TrackinglbsPageState();
}

class _TrackinglbsPageState extends State<TrackinglbsPage> {
  LatLng _currentPosition = LatLng(-6.2088, 106.8456); // Default Jakarta
  LatLng? _destinationPosition;
  final MapController _mapController = MapController();
  double _currentZoom = 16.0;
  bool _isNavigating = false;
  List<LatLng> _routePoints = [];
  
  // Search controller
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Aktifkan layanan lokasi")),
        );
      }
      return;
    }

    // Check location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Izin lokasi ditolak")),
          );
        }
        return;
      }
    }

    try {
      // Get current position with high accuracy
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation,
        timeLimit: const Duration(seconds: 10),
      );

      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _mapController.move(_currentPosition, _currentZoom);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error mendapatkan lokasi: $e")),
        );
      }
    }
  }

  void _zoomIn() {
    setState(() {
      _currentZoom = (_currentZoom + 1).clamp(3.0, 18.0);
      _mapController.move(_currentPosition, _currentZoom);
    });
  }

  void _zoomOut() {
    setState(() {
      _currentZoom = (_currentZoom - 1).clamp(3.0, 18.0);
      _mapController.move(_currentPosition, _currentZoom);
    });
  }

  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      // Use Nominatim API for geocoding (OpenStreetMap)
      final response = await http.get(
        Uri.parse(
          'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json&limit=5',
        ),
        headers: {'User-Agent': 'TrackingLBSApp'},
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        List<Map<String, dynamic>> results = [];

        for (var item in data) {
          results.add({
            'display_name': item['display_name'],
            'lat': double.parse(item['lat']),
            'lon': double.parse(item['lon']),
          });
        }

        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      } else {
        throw Exception('Failed to load search results');
      }
    } catch (e) {
      setState(() {
        _searchResults = [{'display_name': 'Pencarian gagal: $e'}];
        _isSearching = false;
      });
    }
  }

  void _setDestination(Map<String, dynamic> location) {
    if (location.containsKey('lat') && location.containsKey('lon')) {
      setState(() {
        _destinationPosition = LatLng(location['lat'], location['lon']);
        _searchController.text = location['display_name'].toString().split(',').first;
        _searchResults = [];
      });
      
      _getRoute();
    }
  }

  void _getRoute() {
    if (_currentPosition != null && _destinationPosition != null) {
      // For simplicity, we're creating a simple route with intermediate points
      // In a real app, you would use a routing API like OSRM, GraphHopper, or Google Directions
      
      // Calculate intermediate points to simulate a route
      List<LatLng> route = _generateSimpleRoute(_currentPosition, _destinationPosition!);
      
      setState(() {
        _routePoints = route;
        _isNavigating = true;
      });
      
      // Fit map to show the route
      _fitRouteOnMap();
    }
  }
  
  List<LatLng> _generateSimpleRoute(LatLng start, LatLng end) {
    List<LatLng> points = [];
    points.add(start);
    
    // Create some intermediate points to make it look like a route
    // This is a simplified version - real routes would come from a routing API
    
    // Calculate midpoint with some variation
    double midLat = (start.latitude + end.latitude) / 2;
    double midLng = (start.longitude + end.longitude) / 2;
    
    // Add slight offset to make route look more natural
    double latOffset = (end.latitude - start.latitude) * 0.2;
    double lngOffset = (end.longitude - start.longitude) * 0.15;
    
    points.add(LatLng(midLat + latOffset, midLng - lngOffset));
    points.add(LatLng(midLat - latOffset, midLng + lngOffset));
    points.add(end);
    
    return points;
  }
  
  void _fitRouteOnMap() {
    if (_routePoints.isEmpty) return;
    
    // Get bounds of all points in the route
    double minLat = _routePoints.map((p) => p.latitude).reduce((a, b) => a < b ? a : b);
    double maxLat = _routePoints.map((p) => p.latitude).reduce((a, b) => a > b ? a : b);
    double minLng = _routePoints.map((p) => p.longitude).reduce((a, b) => a < b ? a : b);
    double maxLng = _routePoints.map((p) => p.longitude).reduce((a, b) => a > b ? a : b);
    
    // Add some padding
    minLat -= 0.01;
    maxLat += 0.01;
    minLng -= 0.01;
    maxLng += 0.01;
    
    // Calculate center and zoom
    double centerLat = (minLat + maxLat) / 2;
    double centerLng = (minLng + maxLng) / 2;
    
    // Move map to fit route
    _mapController.move(LatLng(centerLat, centerLng), 12.0);
  }

  void _cancelNavigation() {
    setState(() {
      _isNavigating = false;
      _routePoints = [];
      _destinationPosition = null;
      _searchController.text = "";
      _mapController.move(_currentPosition, _currentZoom);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Tracking Maps",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF03254c),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Cari lokasi tujuan...",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        _searchLocation(value);
                      } else {
                        setState(() {
                          _searchResults = [];
                        });
                      }
                    },
                  ),
                ),
                if (_isNavigating)
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: _cancelNavigation,
                  ),
              ],
            ),
          ),
          
          // Search results
          if (_searchResults.isNotEmpty)
            Container(
              height: _searchResults.length > 3 ? 150 : null,
              color: Colors.white,
              child: _isSearching
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final result = _searchResults[index];
                        return ListTile(
                          title: Text(
                            result['display_name'] ?? 'Location',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () {
                            _setDestination(result);
                          },
                        );
                      },
                    ),
            ),
          
          // Map
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    center: _currentPosition,
                    zoom: _currentZoom,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: const ['a', 'b', 'c'],
                    ),
                    
                    // Current location marker
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _currentPosition,
                          width: 40,
                          height: 40,
                          builder: (ctx) => Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF03254c).withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(4),
                            child: const CircleAvatar(
                              backgroundColor: Color(0xFF03254c),
                              child: Icon(
                                Icons.navigation,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    // Route polyline
                    if (_routePoints.isNotEmpty)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: _routePoints,
                            color: Colors.blue,
                            strokeWidth: 4.0,
                          ),
                        ],
                      ),
                    
                    // Destination marker
                    if (_destinationPosition != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _destinationPosition!,
                            width: 40,
                            height: 40,
                            builder: (ctx) => const Icon(
                              Icons.location_on,
                              color: Colors.red,
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                
                // Zoom controls
                Positioned(
                  bottom: 100,
                  right: 25,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FloatingActionButton(
                        heroTag: "zoomIn",
                        mini: true,
                        backgroundColor: const Color(0xFF1167b1),
                        onPressed: _zoomIn,
                        child: const Icon(Icons.add, color: Colors.white),
                      ),
                      const SizedBox(height: 15),
                      FloatingActionButton(
                        heroTag: "zoomOut",
                        mini: true,
                        backgroundColor: const Color(0xFF187bcd),
                        onPressed: _zoomOut,
                        child: const Icon(Icons.remove, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                
                // Navigation info panel
                if (_isNavigating && _destinationPosition != null)
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 70,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.navigation, color: Color(0xFF03254c)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  "Navigasi aktif",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  _searchController.text,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: _cancelNavigation,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],  
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2a9df4),
        onPressed: _determinePosition,
        child: const Icon(Icons.my_location, color: Colors.white),
      ),
    );
  }
}