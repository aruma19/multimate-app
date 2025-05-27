import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

/// Widget TrackinglbsPage
/// 
/// Halaman utama untuk fitur pelacakan lokasi dan navigasi
/// Menampilkan peta dengan posisi pengguna, pencarian lokasi, dan navigasi rute
class TrackinglbsPage extends StatefulWidget {
  const TrackinglbsPage({super.key});

  @override
  State<TrackinglbsPage> createState() => _TrackinglbsPageState();
}

class _TrackinglbsPageState extends State<TrackinglbsPage> {
  // Lokasi default (Yogyakarta) sebagai titik awal sebelum mendapatkan lokasi pengguna
  LatLng _currentPosition = LatLng(-7.7956, 110.3695); 
  
  // Lokasi tujuan untuk navigasi, null jika belum ditentukan
  LatLng? _destinationPosition;
  
  // Controller untuk mengontrol tampilan peta
  final MapController _mapController = MapController();
  
  // Level zoom default peta
  double _currentZoom = 16.0;
  
  // Status navigasi aktif
  bool _isNavigating = false;
  
  // Titik-titik rute untuk polyline
  List<LatLng> _routePoints = [];
  
  /// Warna tema aplikasi
  final Color primaryColor = const Color.fromARGB(255, 89, 0, 185); // Ungu utama
  final Color secondaryColor = const Color(0xFF6A11CB); // Ungu terang
  final Color accentColor = const Color.fromARGB(255, 173, 110, 241); // Ungu lebih terang
  final Color textColor = Colors.white; // Warna teks utama
  
  /// Controller dan variabel untuk fitur pencarian
  // Controller untuk field input pencarian
  final TextEditingController _searchController = TextEditingController();
  
  // Hasil pencarian lokasi
  List<Map<String, dynamic>> _searchResults = [];
  
  // Status proses pencarian
  bool _isSearching = false;
  
  // Timer untuk debounce input pencarian (mengurangi request API)
  Timer? _searchDebounce;
  
  // Waktu debounce untuk pencarian
  final Duration _searchDebounceTime = const Duration(milliseconds: 500);
  
  // Cache hasil pencarian untuk menghemat request API
  final Map<String, List<Map<String, dynamic>>> _searchCache = {};
  
  /// Variabel untuk pelacakan lokasi
  // Subscription untuk stream posisi
  late StreamSubscription<Position> _positionStream;
  
  // Status pelacakan otomatis
  bool _isTracking = true;
  
  // Status loading awal lokasi
  bool _isLocationLoading = true;

  /// Inisialisasi state
  /// Dipanggil saat widget pertama kali dibuat
  @override
  void initState() {
    super.initState();
    // Mendapatkan posisi awal
    _determinePosition();
    // Memulai pelacakan lokasi real-time
    _startLocationTracking();
  }

  /// Pembersihan resource saat widget dihapus
  @override
  void dispose() {
    // Membatalkan subscription posisi untuk mencegah memory leak
    _positionStream.cancel();
    // Membersihkan controller pencarian
    _searchController.dispose();
    // Membatalkan timer debounce jika masih aktif
    _searchDebounce?.cancel();
    super.dispose();
  }

  /// Memulai pelacakan lokasi pengguna secara real-time
  /// 
  /// Menggunakan Geolocator untuk mendapatkan stream posisi
  /// dan mengupdate lokasi pengguna secara berkala
  void _startLocationTracking() {
    // Konfigurasi akurasi dan filter jarak untuk efisiensi baterai
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation, // Akurasi tinggi untuk navigasi
      distanceFilter: 10, // Update setiap pergerakan 10 meter
    );
    
    // Berlangganan stream posisi
    _positionStream = Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) {
      if (_isTracking) {
        setState(() {
          // Update posisi dengan koordinat baru
          _currentPosition = LatLng(position.latitude, position.longitude);
          // Gerakkan peta ke posisi baru jika tidak sedang navigasi
          if (!_isNavigating) {
            _mapController.move(_currentPosition, _currentZoom);
          }
        });
        
        // Update rute jika sedang dalam mode navigasi
        if (_isNavigating && _destinationPosition != null) {
          _getRoute();
        }
      }
    });
  }

  /// Mendapatkan posisi awal pengguna
  /// 
  /// Memeriksa izin lokasi, mengaktifkan layanan lokasi jika perlu,
  /// dan mendapatkan posisi pengguna saat ini dengan akurasi tinggi
  Future<void> _determinePosition() async {
    setState(() {
      _isLocationLoading = true;
    });
    
    bool serviceEnabled;
    LocationPermission permission;

    // Memeriksa apakah layanan lokasi aktif
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Aktifkan layanan lokasi"),
            backgroundColor: primaryColor,
          ),
        );
      }
      setState(() {
        _isLocationLoading = false;
      });
      return;
    }

    // Memeriksa dan meminta izin lokasi jika diperlukan
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Izin lokasi ditolak"),
              backgroundColor: primaryColor,
            ),
          );
        }
        setState(() {
          _isLocationLoading = false;
        });
        return;
      }
    }

    try {
      // Mendapatkan posisi dengan akurasi tinggi dan batas waktu
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation,
        timeLimit: const Duration(seconds: 10),
      );

      setState(() {
        // Update posisi dan tampilan peta
        _currentPosition = LatLng(position.latitude, position.longitude);
        _mapController.move(_currentPosition, _currentZoom);
        _isLocationLoading = false;
      });
    } catch (e) {
      // Tangani error saat mendapatkan lokasi
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error mendapatkan lokasi: $e"),
            backgroundColor: primaryColor,
          ),
        );
      }
      setState(() {
        _isLocationLoading = false;
      });
    }
  }

  /// Memperbesar tampilan peta (+1 level zoom)
  void _zoomIn() {
    setState(() {
      // Membatasi nilai zoom antara 3.0 - 18.0
      _currentZoom = (_currentZoom + 1).clamp(3.0, 18.0);
      _mapController.move(_mapController.center, _currentZoom);
    });
  }

  /// Memperkecil tampilan peta (-1 level zoom)
  void _zoomOut() {
    setState(() {
      // Membatasi nilai zoom antara 3.0 - 18.0
      _currentZoom = (_currentZoom - 1).clamp(3.0, 18.0);
      _mapController.move(_mapController.center, _currentZoom);
    });
  }

  /// Mencari lokasi berdasarkan query teks
  /// 
  /// Menggunakan API Nominatim (OpenStreetMap) dengan fallback ke API alternatif
  /// jika pencarian utama gagal
  /// 
  /// @param query String pencarian lokasi
  Future<void> _searchLocation(String query) async {
    // Hapus hasil pencarian jika query kosong
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    // Periksa cache untuk menghemat request API
    if (_searchCache.containsKey(query)) {
      setState(() {
        _searchResults = _searchCache[query]!;
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      // Menggunakan API Nominatim untuk pencarian lokasi
      final nominatimResponse = await http.get(
        Uri.parse(
          'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}'
          '&format=json&limit=5&addressdetails=1&countrycodes=id&polygon_geojson=1',
        ),
        headers: {'User-Agent': 'TrackingLBSApp'}, // User-Agent diperlukan oleh Nominatim
      ).timeout(const Duration(seconds: 3)); // Timeout untuk menghindari hang

      if (nominatimResponse.statusCode == 200) {
        List<dynamic> data = jsonDecode(nominatimResponse.body);
        List<Map<String, dynamic>> results = [];

        // Memetakan hasil pencarian ke format yang lebih mudah digunakan
        for (var item in data) {
          results.add({
            'display_name': item['display_name'],
            'lat': double.parse(item['lat']),
            'lon': double.parse(item['lon']),
            'address': item['address'],
            'importance': item['importance'] ?? 0.0,
          });
        }

        // Urutkan berdasarkan importance (lebih tinggi = hasil lebih relevan)
        results.sort((a, b) => (b['importance'] as double).compareTo(a['importance'] as double));

        setState(() {
          _searchResults = results.take(5).toList(); // Batasi 5 hasil teratas
          _isSearching = false;
        });

        // Simpan hasil ke cache
        _searchCache[query] = _searchResults;
      } else {
        // Gunakan API alternatif jika Nominatim gagal
        await _fallbackSearch(query);
      }
    } catch (e) {
      // Gunakan pencarian alternatif jika terjadi error
      await _fallbackSearch(query);
    }
  }

  /// Metode pencarian alternatif dengan Mapbox API
  /// 
  /// Dipanggil jika pencarian utama (Nominatim) gagal
  /// 
  /// @param query String pencarian lokasi
  Future<void> _fallbackSearch(String query) async {
    try {
      // Contoh menggunakan API Mapbox (ganti dengan token yang valid)
      const mapboxToken = 'pk.yourmapboxtoken';
      final response = await http.get(
        Uri.parse(
          'https://api.mapbox.com/geocoding/v5/mapbox.places/${Uri.encodeComponent(query)}.json'
          '?access_token=$mapboxToken'
          '&country=ID&limit=5',
        ),
      ).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<Map<String, dynamic>> results = [];

        // Format hasil Mapbox ke format yang konsisten dengan Nominatim
        for (var feature in data['features']) {
          results.add({
            'display_name': feature['place_name'],
            'lat': feature['center'][1].toDouble(),
            'lon': feature['center'][0].toDouble(),
            'address': {
              'city': feature['context']?.firstWhere(
                (ctx) => ctx['id'].toString().contains('place'),
                orElse: () => null,
              )?['text'],
            },
          });
        }

        setState(() {
          _searchResults = results;
          _isSearching = false;
        });

        // Simpan hasil ke cache
        _searchCache[query] = _searchResults;
      } else {
        throw Exception('Fallback search failed');
      }
    } catch (e) {
      // Tampilkan pesan error jika kedua metode pencarian gagal
      setState(() {
        _searchResults = [{
          'display_name': 'Pencarian tidak tersedia saat ini',
          'error': true
        }];
        _isSearching = false;
      });
    }
  }

  /// Format alamat lokasi untuk tampilan yang lebih user-friendly
  /// 
  /// @param location Map data lokasi
  /// @return String alamat yang diformat
  String _formatAddress(Map<String, dynamic> location) {
    if (location.containsKey('error')) return location['display_name'];
    
    if (location.containsKey('address')) {
      final address = location['address'];
      List<String> parts = [];
      
      // Susun alamat dari yang paling spesifik ke umum
      if (address['road'] != null) parts.add(address['road']);
      if (address['neighbourhood'] != null) parts.add(address['neighbourhood']);
      if (address['suburb'] != null) parts.add(address['suburb']);
      if (address['village'] != null) parts.add(address['village']);
      if (address['city'] != null) parts.add(address['city']);
      if (address['state'] != null) parts.add(address['state']);
      
      // Jika detail tidak cukup, gunakan nama lengkap
      if (parts.length < 2 && location['display_name'] != null) {
        return location['display_name'].toString().split(',').take(3).join(', ');
      }
      
      return parts.join(', ');
    }
    
    // Untuk hasil dari Mapbox
    if (location['display_name'] != null) {
      return location['display_name'].toString().split(',').take(3).join(', ');
    }
    
    return 'Lokasi tidak diketahui';
  }

  /// Mendapatkan subtitle lokasi (biasanya kota dan provinsi)
  /// 
  /// @param result Map data lokasi
  /// @return String subtitle lokasi
  String _getLocationSubtitle(Map<String, dynamic> result) {
    if (result.containsKey('error')) return '';
    
    if (result['address'] is Map) {
      final address = result['address'] as Map;
      if (address['city'] != null && address['state'] != null) {
        return '${address['city']}, ${address['state']}';
      }
      if (address['city'] != null) return address['city'].toString();
      if (address['state'] != null) return address['state'].toString();
    }
    return result['display_name']?.toString().split(',').skip(1).take(2).join(',') ?? '';
  }

  /// Mengatur lokasi tujuan untuk navigasi
  /// 
  /// @param location Map data lokasi yang dipilih
  void _setDestination(Map<String, dynamic> location) {
    if (location.containsKey('lat') && location.containsKey('lon')) {
      setState(() {
        // Set koordinat tujuan
        _destinationPosition = LatLng(location['lat'], location['lon']);
        // Update teks pencarian dengan alamat tujuan
        _searchController.text = _formatAddress(location);
        // Kosongkan hasil pencarian
        _searchResults = [];
        // Hentikan tracking otomatis saat tujuan diatur
        _isTracking = false; 
      });
      
      // Dapatkan rute ke tujuan
      _getRoute();
    }
  }

  /// Mendapatkan rute dari posisi saat ini ke tujuan
  /// 
  /// Menggunakan OSRM API untuk mendapatkan rute mengemudi
  /// dengan fallback ke rute sederhana jika API gagal
  Future<void> _getRoute() async {
    if (_currentPosition == null || _destinationPosition == null) return;
    
    setState(() {
      _isNavigating = true;
    });

    try {
      // Gunakan OSRM API untuk kalkulasi rute
      final response = await http.get(
        Uri.parse(
          'http://router.project-osrm.org/route/v1/driving/'
          '${_currentPosition.longitude},${_currentPosition.latitude};'
          '${_destinationPosition!.longitude},${_destinationPosition!.latitude}'
          '?overview=full&geometries=geojson',
        ),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['code'] == 'Ok') {
          // Ekstrak koordinat dari respons GeoJSON
          List<dynamic> coordinates = data['routes'][0]['geometry']['coordinates'];
          List<LatLng> routePoints = coordinates.map((coord) {
            return LatLng(coord[1].toDouble(), coord[0].toDouble());
          }).toList();

          setState(() {
            _routePoints = routePoints;
          });
          
          // Sesuaikan tampilan peta untuk menampilkan seluruh rute
          _fitRouteOnMap();
        }
      } else {
        throw Exception('Failed to load route');
      }
    } catch (e) {
      // Fallback ke rute sederhana jika API gagal
      List<LatLng> route = _generateSimpleRoute(_currentPosition, _destinationPosition!);
      setState(() {
        _routePoints = route;
      });
      _fitRouteOnMap();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Menggunakan rute perkiraan: $e"),
            backgroundColor: primaryColor,
          ),
        );
      }
    }
  }

  /// Membuat rute sederhana garis lurus dari titik awal ke tujuan
  /// 
  /// Digunakan sebagai fallback jika API rute gagal
  /// 
  /// @param start LatLng posisi awal
  /// @param end LatLng posisi tujuan
  /// @return List<LatLng> titik-titik rute sederhana
  List<LatLng> _generateSimpleRoute(LatLng start, LatLng end) {
    List<LatLng> points = [];
    points.add(start);
    
    // Buat titik perantara untuk membuat tampilan rute
    double latStep = (end.latitude - start.latitude) / 10;
    double lngStep = (end.longitude - start.longitude) / 10;
    
    for (int i = 1; i < 10; i++) {
      points.add(LatLng(
        start.latitude + latStep * i,
        start.longitude + lngStep * i,
      ));
    }
    
    points.add(end);
    return points;
  }

  /// Menyesuaikan tampilan peta untuk menampilkan seluruh rute
  /// 
  /// Menghitung batas, pusat, dan level zoom yang optimal
  void _fitRouteOnMap() {
    if (_routePoints.isEmpty) return;
    
    // Hitung batas koordinat semua titik dalam rute
    double minLat = _routePoints.map((p) => p.latitude).reduce((a, b) => a < b ? a : b);
    double maxLat = _routePoints.map((p) => p.latitude).reduce((a, b) => a > b ? a : b);
    double minLng = _routePoints.map((p) => p.longitude).reduce((a, b) => a < b ? a : b);
    double maxLng = _routePoints.map((p) => p.longitude).reduce((a, b) => a > b ? a : b);
    
    // Tambah padding untuk tampilan lebih baik
    minLat -= 0.01;
    maxLat += 0.01;
    minLng -= 0.01;
    maxLng += 0.01;
    
    // Hitung pusat
    double centerLat = (minLat + maxLat) / 2;
    double centerLng = (minLng + maxLng) / 2;
    
    // Hitung level zoom berdasarkan jarak
    double distance = const Distance().distance(_currentPosition, _destinationPosition!);
    double zoom = 16.0;
    
    // Sesuaikan zoom berdasarkan jarak dalam meter
    if (distance > 5000) zoom = 12.0;
    else if (distance > 2000) zoom = 13.0;
    else if (distance > 1000) zoom = 14.0;
    else if (distance > 500) zoom = 15.0;
    
    // Gerakkan peta untuk menampilkan seluruh rute
    _mapController.move(LatLng(centerLat, centerLng), zoom);
  }

  /// Membatalkan navigasi aktif
  /// 
  /// Menghapus rute, tujuan, dan kembali ke mode pelacakan
  void _cancelNavigation() {
    setState(() {
      _isNavigating = false;
      _routePoints = [];
      _destinationPosition = null;
      _searchController.text = "";
      _isTracking = true; // Mulai kembali tracking otomatis
      _mapController.move(_currentPosition, _currentZoom);
    });
  }

  /// Membangun tampilan widget
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
        backgroundColor: primaryColor,
        iconTheme: IconThemeData(color: textColor),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Widget kotak pencarian
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
                          prefixIcon: Icon(Icons.search, color: primaryColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                          contentPadding: const EdgeInsets.symmetric(vertical: 0),
                        ),
                        onChanged: (value) {
                          // Debounce input pencarian untuk mengurangi request API
                          if (_searchDebounce?.isActive ?? false) _searchDebounce?.cancel();
                          
                          _searchDebounce = Timer(_searchDebounceTime, () {
                            if (value.isNotEmpty) {
                              _searchLocation(value);
                            } else {
                              setState(() {
                                _searchResults = [];
                              });
                            }
                          });
                        },
                      ),
                    ),
                    // Tombol cancel navigasi
                    if (_isNavigating)
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: _cancelNavigation,
                      ),
                  ],
                ),
              ),
              
              // Menampilkan hasil pencarian dalam list
              if (_searchResults.isNotEmpty)
                Container(
                  height: _searchResults.length > 3 ? 200 : null,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: _isSearching
                      ? Center(child: CircularProgressIndicator(color: secondaryColor))
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const ClampingScrollPhysics(),
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            final result = _searchResults[index];
                            return Card(
                              margin: const EdgeInsets.all(4),
                              child: ListTile(
                                leading: Icon(Icons.location_on, color: secondaryColor),
                                title: Text(
                                  _formatAddress(result),
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  _getLocationSubtitle(result),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                onTap: () {
                                  if (!result.containsKey('error')) {
                                    _setDestination(result);
                                    FocusScope.of(context).unfocus();
                                  }
                                },
                              ),
                            );
                          },
                        ),
                )
              // Indikator loading saat pencarian berlangsung
              else if (_isSearching)
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: secondaryColor),
                        const SizedBox(height: 8),
                        const Text("Mencari lokasi..."),
                      ],
                    ),
                  ),
                )
              // Pesan jika tidak ada hasil pencarian
              else if (_searchController.text.isNotEmpty && _searchResults.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  child: const Center(
                    child: Text("Tidak ada hasil ditemukan"),
                  ),
                ),
              
              // Widget peta utama
              Expanded(
                child: Stack(
                  children: [
                    // Komponen FlutterMap untuk menampilkan peta OpenStreetMap
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        center: _currentPosition,
                        zoom: _currentZoom,
                        interactiveFlags: InteractiveFlag.all & ~InteractiveFlag.rotate, // Disable rotasi
                      ),
                      children: [
                        // Layer tile peta dasar
                        TileLayer(
                          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                          subdomains: const ['a', 'b', 'c'],
                          userAgentPackageName: 'com.example.tracking_lbs',
                        ),
                        
                        // Marker lokasi pengguna saat ini
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _currentPosition,
                              width: 40,
                              height: 40,
                              builder: (ctx) => Container(
                                decoration: BoxDecoration(
                                  color: secondaryColor.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(4),
                                child: CircleAvatar(
                                  backgroundColor: primaryColor,
                                  child: Icon(
                                    Icons.navigation,
                                    color: textColor,
                                    size: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        // Polyline untuk menampilkan rute
                        if (_routePoints.isNotEmpty)
                          PolylineLayer(
                            polylines: [
                              Polyline(
                                points: _routePoints,
                                color: accentColor.withOpacity(0.7),
                                strokeWidth: 5.0,
                              ),
                            ],
                          ),
                        
                        // Marker lokasi tujuan
                        if (_destinationPosition != null)
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: _destinationPosition!,
                                width: 40,
                                height: 40,
                                builder: (ctx) => Icon(
                                  Icons.location_pin,
                                  color: Colors.red,
                                  size: 40,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    
                    // Kontrol zoom peta
                    Positioned(
                      bottom: 100,
                      right: 25,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FloatingActionButton(
                            heroTag: "zoomIn",
                            mini: true,
                            backgroundColor: secondaryColor,
                            onPressed: _zoomIn,
                            child: Icon(Icons.add, color: textColor),
                          ),
                          const SizedBox(height: 15),
                          FloatingActionButton(
                            heroTag: "zoomOut",
                            mini: true,
                            backgroundColor: accentColor,
                            onPressed: _zoomOut,
                            child: Icon(Icons.remove, color: textColor),
                          ),
                        ],
                      ),
                    ),
                    
                    // Panel informasi navigasi yang muncul saat navigasi aktif
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
                              Icon(Icons.navigation, color: primaryColor),
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
                                      style: TextStyle(
                                        color: Colors.grey[600],
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
          
          // Indikator loading saat mendapatkan lokasi awal
          if (_isLocationLoading)
            Center(
              child: CircularProgressIndicator(color: primaryColor),
            ),
        ],
      ),
      // Tombol untuk kembali ke lokasi pengguna (my location)
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: () {
          setState(() {
            _isTracking = true; // Aktifkan kembali pelacakan otomatis
          });
          _mapController.move(_currentPosition, _currentZoom);
        },
        child: Icon(Icons.my_location, color: textColor),
      ),
    );
  }
}