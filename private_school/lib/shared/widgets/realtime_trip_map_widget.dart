import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'dart:ui' as ui;
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/services/realtime_tracking_service.dart';
import '../../../core/utils/app_colors.dart';
import '../../../parents/pages/school/data/models/school_model.dart';
import 'package:geolocator/geolocator.dart';

class RealtimeTripMapWidget extends StatefulWidget {
  final String tripId;
  final String startLocation;
  final String destination;
  final List<SchoolModel> stops;
  final bool enableRealtime;
  final bool isDriver;

  const RealtimeTripMapWidget({
    super.key,
    required this.tripId,
    required this.startLocation,
    required this.destination,
    this.stops = const [],
    this.enableRealtime = false,
    this.isDriver = false,
  });

  @override
  State<RealtimeTripMapWidget> createState() => _RealtimeTripMapWidgetState();
}

class _RealtimeTripMapWidgetState extends State<RealtimeTripMapWidget> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  GoogleMapController? _mapController;
  final RealtimeTrackingService _trackingService = RealtimeTrackingService();

  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  Marker? _driverMarker;
  final List<LatLng> _traveledPath = []; // Points GPS bruts
  final List<LatLng> _traveledRoutePoints = []; // Points de route calculés
  Polyline? _routePolyline;
  List<LatLng> _fullRoutePoints = [];
  bool _isRecalculating = false;
  bool _hasRecalculatedOffRoute = false;
  LatLng? _startCoords;
  LatLng? _endCoords;
  RealtimeTripData? _currentData;
  LatLng? _lastCalculatedPosition; // Dernière position pour laquelle on a calculé la route

  Timer? _idleAnimationTimer;
  Timer? _movementTimer;
  double _currentHeading = 0.0;
  bool _isMoving = false;
  StreamSubscription<Position>? _driverPositionStream;

  @override
  void initState() {
    super.initState();
    if (widget.enableRealtime) {
      if (widget.isDriver) {
        _startDriverGpsTracking();
      } else {
        _startRealtimeTracking();
      }
    }
  }

  @override
  void dispose() {
    _idleAnimationTimer?.cancel();
    _movementTimer?.cancel();
    _trackingService.dispose();
    _mapController?.dispose();
    _driverPositionStream?.cancel();
    super.dispose();
  }

  Future<void> _initializeMap() async {
    debugPrint('\n [MAP INIT] Début initialisation');
    debugPrint('   startLocation: ${widget.startLocation}');
    debugPrint('   destination: ${widget.destination}');
    debugPrint('   stops: ${widget.stops.length}');
    
    await _geocodeLocations();
    debugPrint('   startCoords: $_startCoords');
    debugPrint('   endCoords: $_endCoords');
    
    await _createStopMarkers();
    debugPrint('   markers: ${_markers.length}');
    
    await _drawCompleteRoute();
    debugPrint('   polylines: ${_polylines.length}');
    debugPrint('   fullRoutePoints: ${_fullRoutePoints.length}');
    debugPrint(' [MAP INIT] Terminé\n');
    
    if (mounted) setState(() {});
  }

  bool _isCoordNearRoute(LatLng coord) {
    if (_startCoords == null || _endCoords == null) return false;
    // Vérifier que le waypoint est dans une boîte englobante raisonnable (+ 1 degré de marge)
    final minLat = (_startCoords!.latitude < _endCoords!.latitude
        ? _startCoords!.latitude : _endCoords!.latitude) - 1.0;
    final maxLat = (_startCoords!.latitude > _endCoords!.latitude
        ? _startCoords!.latitude : _endCoords!.latitude) + 1.0;
    final minLng = (_startCoords!.longitude < _endCoords!.longitude
        ? _startCoords!.longitude : _endCoords!.longitude) - 1.0;
    final maxLng = (_startCoords!.longitude > _endCoords!.longitude
        ? _startCoords!.longitude : _endCoords!.longitude) + 1.0;
    return coord.latitude >= minLat && coord.latitude <= maxLat &&
           coord.longitude >= minLng && coord.longitude <= maxLng;
  }

  Future<void> _drawCompleteRoute() async {
    if (_startCoords == null || _endCoords == null) {
      debugPrint(' [ROUTE] Annulé - coords null');
      return;
    }

    try {
      List<String> waypoints = [];

      for (var stop in widget.stops) {
        if (stop.latitude != null && stop.longitude != null) {
          final coord = LatLng(stop.latitude!, stop.longitude!);
          if (_isCoordNearRoute(coord)) {
            waypoints.add('via:${stop.latitude},${stop.longitude}');
            debugPrint(' [ROUTE] Waypoint ajouté: ${stop.name} $coord');
          } else {
            debugPrint(' [ROUTE] Waypoint ignoré (trop loin): ${stop.name} $coord');
          }
        } else if (stop.address.isNotEmpty) {
          try {
            final url = Uri.parse(
              'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(stop.address + ', Sénégal')}&region=sn&key=AIzaSyAGd7ZK7kkDEr9NOWcQOzkbDL8ddUStX9A',
            );
            final response = await http.get(url);
            if (response.statusCode == 200) {
              final data = json.decode(response.body);
              if (data['results'] != null && data['results'].isNotEmpty) {
                final location = data['results'][0]['geometry']['location'];
                final coord = LatLng(location['lat'], location['lng']);
                if (_isCoordNearRoute(coord)) {
                  waypoints.add('via:${location['lat']},${location['lng']}');
                  debugPrint(' [ROUTE] Waypoint géocodé ajouté: ${stop.name} $coord');
                } else {
                  debugPrint(' [ROUTE] Waypoint géocodé ignoré (trop loin): ${stop.name} $coord');
                }
              }
            }
          } catch (e) {
            debugPrint(' Erreur géocodage stop: $e');
          }
        }
      }

      String waypointsParam = waypoints.isNotEmpty
          ? '&waypoints=${waypoints.join('|')}'
          : '';

      final routeUrl =
          'https://maps.googleapis.com/maps/api/directions/json?'
          'origin=${_startCoords!.latitude},${_startCoords!.longitude}&'
          'destination=${_endCoords!.latitude},${_endCoords!.longitude}'
          '$waypointsParam&'
          'mode=driving&'
          'key=AIzaSyAGd7ZK7kkDEr9NOWcQOzkbDL8ddUStX9A';

      debugPrint(' [ROUTE] URL: $routeUrl');

      final response = await http.get(Uri.parse(routeUrl));
      debugPrint(' [ROUTE] Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint(' [ROUTE] Status API: ${data['status']}');

        if (data['routes'] != null && (data['routes'] as List).isNotEmpty) {
          final route = data['routes'][0];
          final polylinePoints = route['overview_polyline']['points'];
          final points = _decodePolyline(polylinePoints);
          _fullRoutePoints = points;
          debugPrint(' [ROUTE] ${_fullRoutePoints.length} points chargés');

          if (mounted) {
            setState(() {
              _polylines.removeWhere((p) => p.polylineId.value == 'complete_route');
              _polylines.add(Polyline(
                polylineId: const PolylineId('complete_route'),
                points: points,
                color: const Color(0xFF1A73E8),
                width: 5,
                geodesic: true,
              ));
            });
          }

          _fitBounds();
        } else {
          debugPrint(' [ROUTE] Aucune route trouvée - status: ${data['status']}');
          // Tracer une ligne droite comme fallback
          _drawStraightLine();
        }
      } else {
        debugPrint(' [ROUTE] Erreur HTTP: ${response.statusCode}');
        _drawStraightLine();
      }
    } catch (e) {
      debugPrint(' [ROUTE] Exception: $e');
      _drawStraightLine();
    }
  }

  void _drawStraightLine() {
    if (_startCoords == null || _endCoords == null) return;
    debugPrint(' [ROUTE] Tracé ligne droite fallback');
    final points = [_startCoords!, _endCoords!];
    _fullRoutePoints = points;
    if (mounted) {
      setState(() {
        _polylines.removeWhere((p) => p.polylineId.value == 'complete_route');
        _polylines.add(Polyline(
          polylineId: const PolylineId('complete_route'),
          points: points,
          color: const Color(0xFF1A73E8),
          width: 5,
          geodesic: true,
        ));
      });
    }
  }

  /// Ajuster la caméra pour voir tout le trajet
  Future<void> _fitBounds() async {
    if (_startCoords == null || _endCoords == null || _mapController == null) {
      debugPrint(' [FIT BOUNDS] Annulé - coords ou controller null');
      return;
    }

    debugPrint(' [FIT BOUNDS] Ajustement vue');

    double minLat = _startCoords!.latitude < _endCoords!.latitude
        ? _startCoords!.latitude : _endCoords!.latitude;
    double maxLat = _startCoords!.latitude > _endCoords!.latitude
        ? _startCoords!.latitude : _endCoords!.latitude;
    double minLng = _startCoords!.longitude < _endCoords!.longitude
        ? _startCoords!.longitude : _endCoords!.longitude;
    double maxLng = _startCoords!.longitude > _endCoords!.longitude
        ? _startCoords!.longitude : _endCoords!.longitude;

    // Inclure les stops dans les bounds
    for (final marker in _markers) {
      final lat = marker.position.latitude;
      final lng = marker.position.longitude;
      if (lat < minLat) minLat = lat;
      if (lat > maxLat) maxLat = lat;
      if (lng < minLng) minLng = lng;
      if (lng > maxLng) maxLng = lng;
    }

    try {
      await _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(minLat - 0.005, minLng - 0.005),
            northeast: LatLng(maxLat + 0.005, maxLng + 0.005),
          ),
          60,
        ),
      );
      debugPrint(' [FIT BOUNDS] Vue ajustée');
    } catch (e) {
      debugPrint(' [FIT BOUNDS] Erreur: $e');
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0;
    int len = encoded.length;
    int lat = 0;
    int lng = 0;

    while (index < len) {
      int b;
      int shift = 0;
      int result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return points;
  }

  Future<void> _geocodeLocations() async {
    try {
      if (widget.startLocation.isNotEmpty) {
        final startUrl = Uri.parse(
          'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(widget.startLocation)}&region=sn&key=AIzaSyAGd7ZK7kkDEr9NOWcQOzkbDL8ddUStX9A',
        );
        final startResponse = await http.get(startUrl);
        if (startResponse.statusCode == 200) {
          final startData = json.decode(startResponse.body);
          if (startData['results'] != null && startData['results'].isNotEmpty) {
            final location = startData['results'][0]['geometry']['location'];
            _startCoords = LatLng(location['lat'], location['lng']);
          }
        }
      }

      if (widget.destination.isNotEmpty) {
        final endUrl = Uri.parse(
          'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(widget.destination)}&region=sn&key=AIzaSyAGd7ZK7kkDEr9NOWcQOzkbDL8ddUStX9A',
        );
        final endResponse = await http.get(endUrl);
        if (endResponse.statusCode == 200) {
          final endData = json.decode(endResponse.body);
          if (endData['results'] != null && endData['results'].isNotEmpty) {
            final location = endData['results'][0]['geometry']['location'];
            _endCoords = LatLng(location['lat'], location['lng']);
          }
        }
      }

      _startCoords ??= const LatLng(14.7167, -17.4677);
      _endCoords ??= const LatLng(14.6928, -17.4467);

      if (mounted) setState(() {});
    } catch (e) {
      debugPrint(' Erreur géocodage: $e');
      setState(() {
        _startCoords = const LatLng(14.7167, -17.4677);
        _endCoords = const LatLng(14.6928, -17.4467);
      });
    }
  }

  Future<void> _createStopMarkers() async {
    if (_startCoords != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('start'),
          position: _startCoords!,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
          infoWindow: InfoWindow(
            title: 'Départ',
            snippet: widget.startLocation,
          ),
        ),
      );
    }

    if (_endCoords != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('end'),
          position: _endCoords!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(title: 'Arrivée', snippet: widget.destination),
        ),
      );
    }

    final schoolIcon = await _createFallbackSchoolIcon();

    for (int i = 0; i < widget.stops.length; i++) {
      final stop = widget.stops[i];
      LatLng? position;

      // Utiliser les coordonnées GPS directement si disponibles
      if (stop.latitude != null && stop.longitude != null) {
        position = LatLng(stop.latitude!, stop.longitude!);
        debugPrint(' École "${stop.name}" coords directes: $position');
      } else {
        // Fallback: géocoder par adresse ou nom
        final query = stop.address.isNotEmpty
            ? '${stop.address}, Sénégal'
            : '${stop.name}, Dakar, Sénégal';
        try {
          final url = Uri.parse(
            'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(query)}&region=sn&key=AIzaSyAGd7ZK7kkDEr9NOWcQOzkbDL8ddUStX9A',
          );
          final response = await http.get(url);
          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            if (data['results'] != null && data['results'].isNotEmpty) {
              final location = data['results'][0]['geometry']['location'];
              position = LatLng(location['lat'], location['lng']);
              debugPrint(' École "${stop.name}" géocodée: $position');
            }
          }
        } catch (e) {
          debugPrint(' Erreur géocodage école: $e');
        }
      }

      position ??= LatLng(14.7167 + (i * 0.01), -17.4677 + (i * 0.01));

      _markers.add(
        Marker(
          markerId: MarkerId('stop_$i'),
          position: position,
          icon: schoolIcon,
          infoWindow: InfoWindow(title: stop.name, snippet: 'Arrêt ${i + 1}'),
        ),
      );
    }

    if (mounted) setState(() {});
  }

  Future<BitmapDescriptor> _createFallbackSchoolIcon() async {
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    const size = Size(48, 48);

    final bgPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 18, bgPaint);

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 18, borderPaint);

    final schoolPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawRect(const Rect.fromLTWH(16, 22, 16, 12), schoolPaint);

    final path = Path()
      ..moveTo(14, 22)
      ..lineTo(24, 14)
      ..lineTo(34, 22)
      ..close();
    canvas.drawPath(path, schoolPaint);

    final doorPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;
    canvas.drawRect(const Rect.fromLTWH(21, 28, 6, 6), doorPaint);

    final picture = pictureRecorder.endRecording();
    final image = await picture.toImage(
      size.width.toInt(),
      size.height.toInt(),
    );
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.bytes(bytes!.buffer.asUint8List());
  }

  Future<BitmapDescriptor> _createCarIcon() async {
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    const double w = 52;
    const double h = 52;

    // Ombre
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawCircle(const Offset(26, 27), 20, shadowPaint);

    // Cercle blanc extérieur
    canvas.drawCircle(const Offset(26, 25), 20, Paint()..color = Colors.white);

    // Cercle bleu intérieur
    canvas.drawCircle(
      const Offset(26, 25),
      17,
      Paint()..color = const Color(0xFF1A73E8),
    );

    // Corps du bus (blanc)
    final busPaint = Paint()..color = Colors.white;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(13, 17, 26, 16),
        const Radius.circular(3),
      ),
      busPaint,
    );

    // Fenêtres (bleues)
    final winPaint = Paint()..color = const Color(0xFF1A73E8);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(15, 19, 7, 5),
        const Radius.circular(1),
      ),
      winPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(24, 19, 7, 5),
        const Radius.circular(1),
      ),
      winPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(33, 19, 4, 5),
        const Radius.circular(1),
      ),
      winPaint,
    );

    // Roues
    final wheelPaint = Paint()..color = const Color(0xFF333333);
    canvas.drawCircle(const Offset(18, 34), 3, wheelPaint);
    canvas.drawCircle(const Offset(34, 34), 3, wheelPaint);

    // Pointe en bas (épingle)
    final pinPath = Path()
      ..moveTo(21, 44)
      ..lineTo(31, 44)
      ..lineTo(26, 50)
      ..close();
    canvas.drawPath(pinPath, Paint()..color = const Color(0xFF1A73E8));

    final picture = pictureRecorder.endRecording();
    final image = await picture.toImage(w.toInt(), (h + 4).toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.bytes(bytes!.buffer.asUint8List());
  }

  /// Trouve l'index du point le plus proche sur la route
  int _findClosestPointIndex(LatLng driverPos, List<LatLng> routePoints) {
    int closestIndex = 0;
    double minDistance = double.infinity;

    for (int i = 0; i < routePoints.length; i++) {
      final d = _calculateDistanceMeters(
        driverPos.latitude,
        driverPos.longitude,
        routePoints[i].latitude,
        routePoints[i].longitude,
      );
      if (d < minDistance) {
        minDistance = d;
        closestIndex = i;
      }
    }
    return closestIndex;
  }

  /// Distance réelle en mètres entre deux coordonnées GPS (Haversine)
  double _calculateDistanceMeters(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    const double earthRadius = 6371000;
    final dLatM = (lat2 - lat1) * (3.141592653589793 / 180) * earthRadius;
    final dLngM =
        (lng2 - lng1) * (3.141592653589793 / 180) * earthRadius * 0.85;
    return _sqrt(dLatM * dLatM + dLngM * dLngM);
  }

  double _sqrt(double value) {
    if (value <= 0) return 0;
    double x = value;
    double y = 1;
    double e = 0.000001;
    while (x - y > e) {
      x = (x + y) / 2;
      y = value / x;
    }
    return x;
  }

  double _sinApprox(double x) {
    // Normaliser entre -π et π
    while (x > 3.14159) {
      x -= 6.28318;
    }
    while (x < -3.14159) {
      x += 6.28318;
    }
    // Approximation polynomiale
    final x2 = x * x;
    return x * (1 - x2 / 6 * (1 - x2 / 20));
  }

  ///  Suivi GPS direct pour le chauffeur
  void _startDriverGpsTracking() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) return;

      // Position initiale immédiate
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _onDriverPositionUpdate(position);

      // Écoute en continu
      _driverPositionStream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 5, // mise à jour tous les 5 mètres
        ),
      ).listen(_onDriverPositionUpdate);
    } catch (e) {
      debugPrint(' Erreur GPS chauffeur: $e');
    }
  }

  /// Traiter chaque mise à jour GPS du chauffeur
  void _onDriverPositionUpdate(Position position) {
    // Construire un RealtimeTripData factice avec la position GPS réelle
    final fakeData = RealtimeTripData(
      tripId: int.tryParse(widget.tripId) ?? 0,
      tripType: 'aller',
      currentLocation: CurrentLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        direction: 'aller',
        speed: position.speed * 3.6, // m/s → km/h
        accuracy: position.accuracy,
        heading: position.heading,
        timestamp: DateTime.now(),
      ),
      tracking: TrackingInfo(
        isActive: true,
        activeDirection: 'aller',
        progressPercentage: 0,
      ),
    );

    _currentData = fakeData;
    _updateDriverPosition(fakeData);
  }

  void _startRealtimeTracking() {
    debugPrint('\n [REALTIME TRACKING] Démarrage pour trip ${widget.tripId}');
    
    // Attendre que la carte soit initialisée avant de démarrer le tracking
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      
      debugPrint(' Coordonnées de départ: $_startCoords');
      debugPrint(' Coordonnées d\'arrivée: $_endCoords');
      
      _trackingService.startPolling(widget.tripId);
      _trackingService.trackingStream.listen((data) {
        debugPrint('📡 [REALTIME] Données reçues pour trip ${data.tripId}');
        _currentData = data;
        _updateDriverPosition(data);
      });
    });
  }

  Future<void> _updateDriverPosition(RealtimeTripData data) async {
    if (data.currentLocation == null) {
      debugPrint(' [UPDATE DRIVER] Pas de localisation');
      return;
    }

    final location = data.currentLocation!;
    final newPosition = LatLng(location.latitude, location.longitude);
    
    debugPrint('\n [UPDATE DRIVER POSITION]');
    debugPrint('   Nouvelle position: $newPosition');
    debugPrint('   Historique GPS: ${_traveledPath.length} points');
    debugPrint('   Historique route: ${_traveledRoutePoints.length} points');
    
    // Initialiser avec le point de départ si c'est la première position
    if (_traveledPath.isEmpty && _startCoords != null) {
      debugPrint(' Point de départ ajouté à l\'historique');
      
      // Calculer immédiatement la route du départ à la position actuelle
      debugPrint(' Calcul route initiale: départ → position actuelle');
      await _calculateTraveledRoute(_startCoords!, newPosition);
      _lastCalculatedPosition = newPosition;
      debugPrint(' Route initiale calculée: ${_traveledRoutePoints.length} points');
    }
    
    // Ajouter la position GPS brute
    _traveledPath.add(newPosition);
    debugPrint(' Position GPS ajoutée: ${_traveledPath.length} points');
    
    // Calculer la route entre la dernière position et la nouvelle (tous les 50m)
    if (_lastCalculatedPosition != null) {
      final distance = _calculateDistanceMeters(
        _lastCalculatedPosition!.latitude,
        _lastCalculatedPosition!.longitude,
        newPosition.latitude,
        newPosition.longitude,
      );
      
      debugPrint('   Distance depuis dernière calcul: ${distance.toStringAsFixed(1)}m');
      
      if (distance > 50) {
        debugPrint(' Calcul nouvelle route: ${distance.toStringAsFixed(1)}m parcourus');
        await _calculateTraveledRoute(_lastCalculatedPosition!, newPosition);
        _lastCalculatedPosition = newPosition;
        debugPrint(' Route mise à jour: ${_traveledRoutePoints.length} points totaux');
      }
    }

    // Mise à jour marqueur chauffeur
    if (_driverMarker == null) {
      final carIcon = await _createCarIcon();
      _driverMarker = Marker(
        markerId: const MarkerId('driver'),
        position: newPosition,
        icon: carIcon,
        anchor: const Offset(0.5, 0.5),
        rotation: location.heading ?? 0,
        infoWindow: InfoWindow(
          title: 'Chauffeur',
          snippet: location.speed != null
              ? '${location.speed!.toStringAsFixed(0)} km/h'
              : null,
        ),
      );
      _markers.add(_driverMarker!);
    } else {
      _animateDriverMarker(newPosition, location.heading ?? 0);
    }

    await _updateRouteColors(newPosition);

    _mapController?.animateCamera(CameraUpdate.newLatLng(newPosition));
    if (mounted) setState(() {});
  }

  Future<void> _updateRouteColors(LatLng driverPos) async {
    if (_isRecalculating) return;

    debugPrint('\n🔄 [UPDATE ROUTE COLORS] Début');
    debugPrint('   Position chauffeur: $driverPos');
    debugPrint('   Points route complète: ${_fullRoutePoints.length}');
    debugPrint('   Points parcourus (GPS): ${_traveledPath.length}');
    debugPrint('   Points parcourus (route): ${_traveledRoutePoints.length}');

    // Si la route n'est pas encore chargée, la charger maintenant
    if (_fullRoutePoints.isEmpty) {
      debugPrint(' [UPDATE ROUTE COLORS] Route vide, rechargement...');
      await _drawCompleteRoute();
      if (_fullRoutePoints.isEmpty) {
        debugPrint(' [UPDATE ROUTE COLORS] Toujours vide après rechargement');
        return;
      }
    }

    _isRecalculating = true;

    try {
      if (mounted) {
        setState(() {
          // Supprimer les anciennes polylines
          _polylines.removeWhere(
            (p) =>
                p.polylineId.value == 'traveled_path' ||
                p.polylineId.value == 'complete_route',
          );

          // TOUJOURS tracer le chemin avec les points de route calculés en VERT
          if (_traveledRoutePoints.length >= 2) {
            _polylines.add(
              Polyline(
                polylineId: const PolylineId('traveled_path'),
                points: List.from(_traveledRoutePoints),
                color: const Color(0xFF34A853),
                width: 6,
                geodesic: true,
                zIndex: 2,
              ),
            );
            debugPrint(' Tracé vert ajouté: ${_traveledRoutePoints.length} points de route');
          } else {
            debugPrint(' Pas assez de points pour le tracé vert: ${_traveledRoutePoints.length} (minimum 2 requis)');
          }
        });
      }

      // TOUJOURS recalculer la route bleue depuis la position actuelle du chauffeur
      await _recalculateRouteFromPosition(driverPos);
      debugPrint(' [UPDATE ROUTE COLORS] Terminé\n');
    } finally {
      _isRecalculating = false;
    }
  }

  Future<void> _recalculateRouteFromPosition(LatLng fromPos) async {
    if (_endCoords == null) return;

    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json?'
        'origin=${fromPos.latitude},${fromPos.longitude}&'
        'destination=${_endCoords!.latitude},${_endCoords!.longitude}&'
        'mode=driving&'
        'key=AIzaSyAGd7ZK7kkDEr9NOWcQOzkbDL8ddUStX9A',
      );

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final polylinePoints =
              data['routes'][0]['overview_polyline']['points'];
          final newPoints = _decodePolyline(polylinePoints);

          if (newPoints.length >= 2 && mounted) {
            setState(() {
              _polylines.removeWhere(
                (p) => p.polylineId.value == 'complete_route',
              );
              _polylines.add(
                Polyline(
                  polylineId: const PolylineId('complete_route'),
                  points: newPoints,
                  color: const Color(0xFF1A73E8),
                  width: 5,
                  zIndex: 1,
                ),
              );
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Erreur recalcul: $e');
    }
  }

  /// Calculer la route entre deux positions GPS
  Future<void> _calculateTraveledRoute(LatLng from, LatLng to) async {
    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json?'
        'origin=${from.latitude},${from.longitude}&'
        'destination=${to.latitude},${to.longitude}&'
        'mode=driving&'
        'key=AIzaSyAGd7ZK7kkDEr9NOWcQOzkbDL8ddUStX9A',
      );

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final polylinePoints =
              data['routes'][0]['overview_polyline']['points'];
          final routePoints = _decodePolyline(polylinePoints);
          
          // Si c'est la première route calculée, ajouter tous les points
          if (_traveledRoutePoints.isEmpty) {
            _traveledRoutePoints.addAll(routePoints);
            debugPrint(' Route initiale calculée: ${routePoints.length} points');
          } else {
            // Sinon, ajouter les nouveaux points (sauf le premier qui est déjà dans la liste)
            if (routePoints.length > 1) {
              _traveledRoutePoints.addAll(routePoints.skip(1));
              debugPrint(' Route calculée: +${routePoints.length - 1} points (total: ${_traveledRoutePoints.length})');
            }
          }
        }
      }
    } catch (e) {
      debugPrint(' Erreur calcul route parcouru: $e');
      // En cas d'erreur, ajouter juste le point de destination
      _traveledRoutePoints.add(to);
    }
  }

  void _animateDriverMarker(LatLng newPosition, double heading) {
    if (_driverMarker == null) return;

    final oldPosition = _driverMarker!.position;

    // Vérifier si le bus a vraiment bougé (> 5 mètres)
    final distance = _calculateDistanceMeters(
      oldPosition.latitude,
      oldPosition.longitude,
      newPosition.latitude,
      newPosition.longitude,
    );

    if (distance > 5) {
      //  BUS EN MOUVEMENT
      _isMoving = true;
      _currentHeading = heading;

      // Arrêter l'animation idle si elle tournait
      _idleAnimationTimer?.cancel();
      _idleAnimationTimer = null;

      // Annuler l'animation précédente
      _movementTimer?.cancel();

      const steps = 30;
      int currentStep = 0;

      _movementTimer = Timer.periodic(const Duration(milliseconds: 50), (
        timer,
      ) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        if (currentStep >= steps) {
          timer.cancel();
          _isMoving = false;
          // Démarrer l'animation idle après l'arrêt
          _startIdleAnimation();
          return;
        }

        currentStep++;
        // Courbe d'accélération/décélération (ease in-out)
        final t = currentStep / steps;
        final progress = t < 0.5 ? 2 * t * t : -1 + (4 - 2 * t) * t;

        final lat =
            oldPosition.latitude +
            (newPosition.latitude - oldPosition.latitude) * progress;
        final lng =
            oldPosition.longitude +
            (newPosition.longitude - oldPosition.longitude) * progress;

        // Interpolation de la rotation
        double angleDiff = heading - _currentHeading;
        if (angleDiff > 180) angleDiff -= 360;
        if (angleDiff < -180) angleDiff += 360;
        final currentRotation = _currentHeading + angleDiff * progress;

        _markers.removeWhere((m) => m.markerId.value == 'driver');
        _driverMarker = _driverMarker!.copyWith(
          positionParam: LatLng(lat, lng),
          rotationParam: currentRotation,
        );
        _markers.add(_driverMarker!);

        if (mounted) setState(() {});
      });
    } else {
      //  BUS À L'ARRÊT → animation idle
      if (!_isMoving) {
        _startIdleAnimation();
      }
    }
  }

  void _startIdleAnimation() {
    // Éviter de démarrer plusieurs timers
    if (_idleAnimationTimer != null && _idleAnimationTimer!.isActive) return;

    double idleAngle = _currentHeading;

    // Oscillation douce gauche/droite (quand le bus attend)
    int tick = 0;
    _idleAnimationTimer = Timer.periodic(const Duration(milliseconds: 50), (
      timer,
    ) {
      if (!mounted || _isMoving) {
        timer.cancel();
        _idleAnimationTimer = null;
        return;
      }

      tick++;
      // Oscillation sinusoïdale ±10 degrés
      final oscillation = 10 * _sinApprox(tick * 0.08);
      final animatedAngle = idleAngle + oscillation;

      _markers.removeWhere((m) => m.markerId.value == 'driver');
      if (_driverMarker != null) {
        _driverMarker = _driverMarker!.copyWith(rotationParam: animatedAngle);
        _markers.add(_driverMarker!);
        if (mounted) setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: _startCoords ?? const LatLng(14.6928, -17.4467),
            zoom: 13,
          ),
          markers: _markers,
          polylines: _polylines,
          onMapCreated: (controller) {
            _mapController = controller;
            debugPrint(' [MAP] onMapCreated - démarrage init');
            _initializeMap().then((_) {
              Future.delayed(const Duration(milliseconds: 300), _fitBounds);
            });
          },
          myLocationEnabled: false,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          zoomGesturesEnabled: true,
          scrollGesturesEnabled: true,
          tiltGesturesEnabled: true,
          rotateGesturesEnabled: true,
        ),

        // Indicateur de chargement
        if (_startCoords == null)
          Container(
            color: Colors.grey.shade200,
            child: const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          ),

        if (widget.enableRealtime && _currentData != null)
          Positioned(
            bottom: 12,
            left: 12,
            right: 12,
            child: _buildTrackingInfo(),
          ),
      ],
    );
  }

  Widget _buildTrackingInfo() {
    if (_currentData == null) return const SizedBox.shrink();

    final tracking = _currentData!.tracking;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInfoItem(
            icon: Icons.access_time,
            label: 'Temps',
            value: tracking.minutesSinceStart != null
                ? '${tracking.minutesSinceStart} min'
                : 'N/A',
          ),
          Container(width: 1, height: 30, color: Colors.grey.shade300),
          _buildInfoItem(
            icon: Icons.trending_up,
            label: 'Progression',
            value: '${tracking.progressPercentage.toStringAsFixed(0)}%',
          ),
          Container(width: 1, height: 30, color: Colors.grey.shade300),
          _buildInfoItem(
            icon: tracking.isActive ? Icons.play_circle : Icons.pause_circle,
            label: 'Statut',
            value: tracking.isActive ? 'En cours' : 'Arrêté',
            valueColor: tracking.isActive ? AppColors.success : AppColors.error,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
