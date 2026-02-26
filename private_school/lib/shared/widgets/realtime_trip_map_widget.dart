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

class _RealtimeTripMapWidgetState extends State<RealtimeTripMapWidget> {
  GoogleMapController? _mapController;
  final RealtimeTrackingService _trackingService = RealtimeTrackingService();

  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  Marker? _driverMarker;
  final List<LatLng> _traveledPath = [];
  Polyline? _routePolyline;
  List<LatLng> _fullRoutePoints = [];
  bool _isRecalculating = false;  
  bool _hasRecalculatedOffRoute = false;            
  LatLng? _startCoords;
  LatLng? _endCoords;
  RealtimeTripData? _currentData;

  Timer? _idleAnimationTimer;
Timer? _movementTimer;
double _currentHeading = 0.0;
bool _isMoving = false;
StreamSubscription<Position>? _driverPositionStream;

 @override
void initState() {
  super.initState();
  _initializeMap();
  if (widget.enableRealtime) {
    if (widget.isDriver) {
      //  Chauffeur : GPS direct du téléphone
      _startDriverGpsTracking();
    } else {
      //  Parent : API realtime comme avant
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
    await _geocodeLocations();
    await _createStopMarkers();
    await _drawCompleteRoute();
  }

  Future<void> _drawCompleteRoute() async {
    if (_startCoords == null || _endCoords == null) return;

    try {
      List<String> waypoints = [];

      for (var stop in widget.stops) {
        if (stop.address.isNotEmpty) {
          try {
            final url = Uri.parse(
              'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(stop.address)}&region=sn&key=AIzaSyAGd7ZK7kkDEr9NOWcQOzkbDL8ddUStX9A',
            );
            final response = await http.get(url);
            if (response.statusCode == 200) {
              final data = json.decode(response.body);
              if (data['results'] != null && data['results'].isNotEmpty) {
                final location = data['results'][0]['geometry']['location'];
                waypoints.add('via:${location['lat']},${location['lng']}');
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

      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json?'
        'origin=${_startCoords!.latitude},${_startCoords!.longitude}&'
        'destination=${_endCoords!.latitude},${_endCoords!.longitude}'
        '$waypointsParam&'
        'mode=driving&'
        'key=AIzaSyAGd7ZK7kkDEr9NOWcQOzkbDL8ddUStX9A',
      );

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          final polylinePoints = route['overview_polyline']['points'];
          final points = _decodePolyline(polylinePoints);
_fullRoutePoints = points; // ← OBLIGATOIRE
debugPrint('✅ ${_fullRoutePoints.length} points de route chargés');

          _routePolyline = Polyline(
            polylineId: const PolylineId('complete_route'),
            points: points,
            color: AppColors.primary,
            width: 5,
            geodesic: true,
          );

          _polylines.add(_routePolyline!);

          if (mounted) setState(() {});

          // Ajuster la caméra pour voir tout le trajet
          _fitBounds();
        }
      }
    } catch (e) {
      debugPrint(' Erreur tracé itinéraire: $e');
    }
  }

  /// Ajuster la caméra pour voir tout le trajet
  Future<void> _fitBounds() async {
    if (_startCoords == null || _endCoords == null || _mapController == null) {
      return;
    }

    final double minLat = _startCoords!.latitude < _endCoords!.latitude
        ? _startCoords!.latitude
        : _endCoords!.latitude;
    final double maxLat = _startCoords!.latitude > _endCoords!.latitude
        ? _startCoords!.latitude
        : _endCoords!.latitude;
    final double minLng = _startCoords!.longitude < _endCoords!.longitude
        ? _startCoords!.longitude
        : _endCoords!.longitude;
    final double maxLng = _startCoords!.longitude > _endCoords!.longitude
        ? _startCoords!.longitude
        : _endCoords!.longitude;

    await _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        60,
      ),
    );
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

      if (stop.address.isNotEmpty) {
        try {
          final url = Uri.parse(
            'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(stop.address)}&region=sn&key=AIzaSyAGd7ZK7kkDEr9NOWcQOzkbDL8ddUStX9A',
          );
          final response = await http.get(url);
          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            if (data['results'] != null && data['results'].isNotEmpty) {
              final location = data['results'][0]['geometry']['location'];
              position = LatLng(location['lat'], location['lng']);
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
  canvas.drawCircle(
    const Offset(26, 25),
    20,
    Paint()..color = Colors.white,
  );

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
  canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(15, 19, 7, 5), const Radius.circular(1)), winPaint);
  canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(24, 19, 7, 5), const Radius.circular(1)), winPaint);
  canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(33, 19, 4, 5), const Radius.circular(1)), winPaint);

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
  double lat1, double lng1,
  double lat2, double lng2,
) {
  const double earthRadius = 6371000;
  final dLatM = (lat2 - lat1) * (3.141592653589793 / 180) * earthRadius;
  final dLngM = (lng2 - lng1) * (3.141592653589793 / 180) * earthRadius * 0.85;
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
  while (x > 3.14159) { x -= 6.28318; }
while (x < -3.14159) { x += 6.28318; }
  // Approximation polynomiale
  final x2 = x * x;
  return x * (1 - x2 / 6 * (1 - x2 / 20));
}

/// ✅ NOUVEAU - Suivi GPS direct pour le chauffeur
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
    debugPrint('❌ Erreur GPS chauffeur: $e');
  }
}

/// ✅ NOUVEAU - Traiter chaque mise à jour GPS du chauffeur
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
    _trackingService.startPolling(widget.tripId);
    _trackingService.trackingStream.listen((data) {
      _currentData = data;
      _updateDriverPosition(data);
    });
  }

  Future<void> _updateDriverPosition(RealtimeTripData data) async {
  if (data.currentLocation == null) return;

  final location = data.currentLocation!;
  final newPosition = LatLng(location.latitude, location.longitude);
  _traveledPath.add(newPosition);

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

  // ─── LOGIQUE VERTE / BLEUE ───────────────────────────────
  await _updateRouteColors(newPosition);
  // ────────────────────────────────────────────────────────

  _mapController?.animateCamera(CameraUpdate.newLatLng(newPosition));
  if (mounted) setState(() {});
}

Future<void> _updateRouteColors(LatLng driverPos) async {
  if (_isRecalculating) return;

  // Attendre que la route soit chargée
  int waited = 0;
  while (_fullRoutePoints.isEmpty && waited < 10000) {
    await Future.delayed(const Duration(milliseconds: 500));
    waited += 500;
  }
  if (_fullRoutePoints.isEmpty) return;

  _isRecalculating = true;

  try {
    final closestIndex = _findClosestPointIndex(driverPos, _fullRoutePoints);
    final closestPoint = _fullRoutePoints[closestIndex];
    final distanceToRoute = _calculateDistanceMeters(
      driverPos.latitude, driverPos.longitude,
      closestPoint.latitude, closestPoint.longitude,
    );

    debugPrint('📍 Distance route: ${distanceToRoute.toStringAsFixed(0)}m | Index: $closestIndex/${_fullRoutePoints.length}');

    if (distanceToRoute <= 150.0) {
      // ✅ CAS 1 : Sur la route → vert + bleu sur la polyline officielle
      _hasRecalculatedOffRoute = false; // reset quand on revient sur la route

      final traveledPoints = _fullRoutePoints.sublist(0, closestIndex + 1);
      final remainingPoints = _fullRoutePoints.sublist(closestIndex);

      debugPrint('🟢 Sur route: ${traveledPoints.length} verts | ${remainingPoints.length} bleus');

      if (mounted) {
        setState(() {
          _polylines.removeWhere((p) =>
              p.polylineId.value == 'traveled_path' ||
              p.polylineId.value == 'complete_route' ||
              p.polylineId.value == 'off_route');

          if (traveledPoints.length >= 2) {
            _polylines.add(Polyline(
              polylineId: const PolylineId('traveled_path'),
              points: traveledPoints,
              color: const Color(0xFF34A853),
              width: 6,
              zIndex: 2,
            ));
          }

          if (remainingPoints.length >= 2) {
            _polylines.add(Polyline(
              polylineId: const PolylineId('complete_route'),
              points: remainingPoints,
              color: const Color(0xFF1A73E8),
              width: 5,
              zIndex: 1,
            ));
          }
        });
      }
    } else {
      // 🔄 CAS 2 : Hors route → GPS en vert + recalcul bleu
      debugPrint('🔴 Hors route (${distanceToRoute.toStringAsFixed(0)}m)');

      if (mounted) {
        setState(() {
          // NE PAS supprimer 'complete_route' ici pour éviter le clignotement
          _polylines.removeWhere((p) =>
              p.polylineId.value == 'traveled_path' ||
              p.polylineId.value == 'off_route');

          final gpsTraveledPoints = [
            _fullRoutePoints.first,
            driverPos,
          ];

          _polylines.add(Polyline(
            polylineId: const PolylineId('traveled_path'),
            points: gpsTraveledPoints,
            color: const Color(0xFF34A853),
            width: 6,
            zIndex: 2,
          ));
        });
      }

      // Recalculer UNE SEULE FOIS tant qu'on est hors route
      if (!_hasRecalculatedOffRoute) {
        _hasRecalculatedOffRoute = true;
        await _recalculateRouteFromPosition(driverPos);
      }
    }
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
                (p) => p.polylineId.value == 'complete_route');
            _polylines.add(Polyline(
              polylineId: const PolylineId('complete_route'),
              points: newPoints,
              color: const Color(0xFF1A73E8),
              width: 5,
              zIndex: 1,
            ));
          });
        }
      }
    }
  } catch (e) {
    debugPrint('Erreur recalcul: $e');
  }
}

  void _animateDriverMarker(LatLng newPosition, double heading) {
  if (_driverMarker == null) return;

  final oldPosition = _driverMarker!.position;

  // Vérifier si le bus a vraiment bougé (> 5 mètres)
  final distance = _calculateDistanceMeters(
    oldPosition.latitude, oldPosition.longitude,
    newPosition.latitude, newPosition.longitude,
  );

  if (distance > 5) {
    // 🚌 BUS EN MOUVEMENT
    _isMoving = true;
    _currentHeading = heading;

    // Arrêter l'animation idle si elle tournait
    _idleAnimationTimer?.cancel();
    _idleAnimationTimer = null;

    // Annuler l'animation précédente
    _movementTimer?.cancel();

    const steps = 30;
    int currentStep = 0;

    _movementTimer = Timer.periodic(
      const Duration(milliseconds: 50),
      (timer) {
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
        final progress = t < 0.5
            ? 2 * t * t
            : -1 + (4 - 2 * t) * t;

        final lat = oldPosition.latitude +
            (newPosition.latitude - oldPosition.latitude) * progress;
        final lng = oldPosition.longitude +
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
      },
    );

  } else {
    // 🅿️ BUS À L'ARRÊT → animation idle
    if (!_isMoving) {
      _startIdleAnimation();
    }
  }
}

void _startIdleAnimation() {
  // Éviter de démarrer plusieurs timers
  if (_idleAnimationTimer != null && _idleAnimationTimer!.isActive) return;

  double idleAngle = _currentHeading;

  // Oscillation douce gauche/droite (comme Yango quand le bus attend)
  int tick = 0;
  _idleAnimationTimer = Timer.periodic(
    const Duration(milliseconds: 50),
    (timer) {
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
        _driverMarker = _driverMarker!.copyWith(
          rotationParam: animatedAngle,
        );
        _markers.add(_driverMarker!);
        if (mounted) setState(() {});
      }
    },
  );
}

  @override
  Widget build(BuildContext context) {
    if (_startCoords == null || _endCoords == null) {
      return Container(
        color: Colors.grey.shade200,
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return Stack(
  children: [
    GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _startCoords!,
              zoom: 13,
            ),
            markers: _markers,
            polylines: _polylines,
            onMapCreated: (controller) {
              _mapController = controller;
              // Ajuster la vue après création
              Future.delayed(const Duration(milliseconds: 500), _fitBounds);
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
        

        // Informations de suivi en temps réel
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
