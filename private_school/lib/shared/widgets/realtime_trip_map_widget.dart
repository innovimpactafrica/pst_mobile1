import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
//import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async';
import 'dart:ui' as ui;
import 'dart:convert';
import 'package:http/http.dart' as http;
//import 'package:flutter_svg/flutter_svg.dart' as vg;
import '../../../core/services/realtime_tracking_service.dart';
import '../../../core/utils/app_colors.dart';
import '../../../parents/pages/school/data/models/school_model.dart';

class RealtimeTripMapWidget extends StatefulWidget {
  final String tripId;
  final String startLocation;
  final String destination;
  final List<SchoolModel> stops;
  final bool enableRealtime;
  
  const RealtimeTripMapWidget({
    super.key,
    required this.tripId,
    required this.startLocation,
    required this.destination,
    this.stops = const [],
    this.enableRealtime = false,
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
  final List<LatLng> _driverPath = [];
  Polyline? _routePolyline; // Tracé de l'itinéraire complet
  
  LatLng? _startCoords;
  LatLng? _endCoords;
  RealtimeTripData? _currentData;
  
  @override
  void initState() {
    super.initState();
    _initializeMap();
    if (widget.enableRealtime) {
      _startRealtimeTracking();
    }
  }
  
  @override
  void dispose() {
    _trackingService.dispose();
    _mapController?.dispose();
    super.dispose();
  }
  
  Future<void> _initializeMap() async {
    await _geocodeLocations();
    await _createStopMarkers();
    await _drawCompleteRoute(); // Dessiner l'itinéraire complet
  }
  
  /// Dessiner l'itinéraire complet avec les stops
  Future<void> _drawCompleteRoute() async {
    if (_startCoords == null || _endCoords == null) return;
    
    try {
      // Construire les waypoints avec les stops géocodés
      List<String> waypoints = [];
      List<LatLng> stopPositions = [];
      
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
                final position = LatLng(location['lat'], location['lng']);
                stopPositions.add(position);
                waypoints.add('via:${location['lat']},${location['lng']}');
              }
            }
          } catch (e) {
            debugPrint('❌ Erreur géocodage stop: $e');
          }
        }
      }
      
      // Construire l'URL avec les waypoints
      String waypointsParam = waypoints.isNotEmpty ? '&waypoints=${waypoints.join('|')}' : '';
      
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
          
          // Décoder les points de la polyline
          final points = _decodePolyline(polylinePoints);
          
          // Créer la polyline avec AppColors.primary
          _routePolyline = Polyline(
            polylineId: const PolylineId('complete_route'),
            points: points,
            color: AppColors.primary, // Couleur primary pour visibilité
            width: 5,
            geodesic: true,
          );
          
          _polylines.add(_routePolyline!);
          
          if (mounted) setState(() {});
          debugPrint('✅ Itinéraire tracé avec ${points.length} points et ${waypoints.length} stops');
        }
      }
    } catch (e) {
      debugPrint('❌ Erreur tracé itinéraire: $e');
    }
  }
  
  /// Décoder une polyline encodée
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
      // Géocoder le point de départ
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
      
      // Géocoder le point d'arrivée
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
      
      // Fallback si le géocodage échoue
      _startCoords ??= const LatLng(14.7167, -17.4677);
      _endCoords ??= const LatLng(14.6928, -17.4467);
      
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('❌ Erreur géocodage: $e');
      // Utiliser des coordonnées par défaut
      setState(() {
        _startCoords = const LatLng(14.7167, -17.4677);
        _endCoords = const LatLng(14.6928, -17.4467);
      });
    }
  }
  
  /// Créer les marqueurs pour les stops (écoles)
  Future<void> _createStopMarkers() async {
    if (widget.stops.isEmpty) return;
    
    // Créer une seule icône d'école pour tous les stops
    final schoolIcon = await _createSchoolMarkerIcon();
    
    for (int i = 0; i < widget.stops.length; i++) {
      final stop = widget.stops[i];
      
      // Géocoder l'adresse de l'école
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
          debugPrint('❌ Erreur géocodage école: $e');
        }
      }
      
      // Fallback: position entre départ et arrivée
      position ??= LatLng(
        14.7167 + (i * 0.01),
        -17.4677 + (i * 0.01),
      );
      
      _markers.add(
        Marker(
          markerId: MarkerId('stop_$i'),
          position: position,
          icon: schoolIcon, // Utiliser l'icône d'école
          infoWindow: InfoWindow(
            title: stop.name,
            snippet: 'Arrêt ${i + 1}',
          ),
        ),
      );
    }
    
    if (mounted) setState(() {});
  }
  
  /// Créer une icône d'école depuis le SVG
  Future<BitmapDescriptor> _createSchoolMarkerIcon() async {
    return _createFallbackSchoolIcon();
  }
  
  /// Icône de secours si le SVG ne charge pas
  Future<BitmapDescriptor> _createFallbackSchoolIcon() async {
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    const size = Size(100, 100);
    
    // Dessiner le fond circulaire
    final bgPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      35,
      bgPaint,
    );
    
    // Bordure blanche
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;
    
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      35,
      borderPaint,
    );
    
    // Dessiner l'icône d'école (bâtiment simple)
    final schoolPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    // Base du bâtiment
    canvas.drawRect(
      const Rect.fromLTWH(30, 45, 40, 30),
      schoolPaint,
    );
    
    // Toit triangulaire
    final path = Path()
      ..moveTo(25, 45)
      ..lineTo(50, 25)
      ..lineTo(75, 45)
      ..close();
    canvas.drawPath(path, schoolPaint);
    
    // Porte
    final doorPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      const Rect.fromLTWH(45, 60, 10, 15),
      doorPaint,
    );
    
    // Fenêtres
    canvas.drawRect(const Rect.fromLTWH(35, 50, 8, 8), doorPaint);
    canvas.drawRect(const Rect.fromLTWH(57, 50, 8, 8), doorPaint);
    
    final picture = pictureRecorder.endRecording();
    final image = await picture.toImage(size.width.toInt(), size.height.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    
    return BitmapDescriptor.bytes(bytes!.buffer.asUint8List());
  }
  
  /// Créer l'icône de voiture
  Future<BitmapDescriptor> _createCarIcon() async {
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    const size = Size(60, 60);
    
    // Dessiner une voiture simple
    final paint = Paint()
      ..color = AppColors.error
      ..style = PaintingStyle.fill;
    
    // Corps de la voiture
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(10, 20, 40, 25),
        const Radius.circular(5),
      ),
      paint,
    );
    
    // Toit
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(15, 10, 30, 15),
        const Radius.circular(5),
      ),
      paint,
    );
    
    // Roues
    final wheelPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(const Offset(20, 45), 5, wheelPaint);
    canvas.drawCircle(const Offset(40, 45), 5, wheelPaint);
    
    final picture = pictureRecorder.endRecording();
    final image = await picture.toImage(size.width.toInt(), size.height.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    
    return BitmapDescriptor.bytes(bytes!.buffer.asUint8List());
  }
  
  /// Démarrer le suivi en temps réel
  void _startRealtimeTracking() {
    _trackingService.startPolling(widget.tripId);
    
    _trackingService.trackingStream.listen((data) {
      _currentData = data;
      _updateDriverPosition(data);
    });
  }
  
  /// Mettre à jour la position du chauffeur
  Future<void> _updateDriverPosition(RealtimeTripData data) async {
    if (data.currentLocation == null) return;
    
    final location = data.currentLocation!;
    final newPosition = LatLng(location.latitude, location.longitude);
    
    // Ajouter au chemin parcouru
    _driverPath.add(newPosition);
    
    // Créer/mettre à jour le marqueur du chauffeur
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
      // Animer le déplacement
      _animateDriverMarker(newPosition, location.heading ?? 0);
    }
    
    // Dessiner le chemin parcouru
    _polylines.add(
      Polyline(
        polylineId: const PolylineId('driver_path'),
        points: _driverPath,
        color: AppColors.success,
        width: 4,
      ),
    );
    
    // Centrer la carte sur le chauffeur
    _mapController?.animateCamera(
      CameraUpdate.newLatLng(newPosition),
    );
    
    if (mounted) setState(() {});
  }
  
  /// Animer le déplacement du marqueur du chauffeur
  void _animateDriverMarker(LatLng newPosition, double heading) {
    if (_driverMarker == null) return;
    
    final oldPosition = _driverMarker!.position;
    const steps = 20;
    int currentStep = 0;
    
    Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (currentStep >= steps) {
        timer.cancel();
        return;
      }
      
      currentStep++;
      final progress = currentStep / steps;
      
      final lat = oldPosition.latitude + 
          (newPosition.latitude - oldPosition.latitude) * progress;
      final lng = oldPosition.longitude + 
          (newPosition.longitude - oldPosition.longitude) * progress;
      
      _markers.removeWhere((m) => m.markerId.value == 'driver');
      _driverMarker = _driverMarker!.copyWith(
        positionParam: LatLng(lat, lng),
        rotationParam: heading,
      );
      _markers.add(_driverMarker!);
      
      if (mounted) setState(() {});
    });
  }
  
  @override
  Widget build(BuildContext context) {
    if (_startCoords == null || _endCoords == null) {
      return const Center(child: CircularProgressIndicator());
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
          },
          myLocationEnabled: false,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: true,
          mapToolbarEnabled: false,
        ),
        
        // Informations de suivi
        if (widget.enableRealtime && _currentData != null)
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: _buildTrackingInfo(),
          ),
      ],
    );
  }
  
  Widget _buildTrackingInfo() {
    if (_currentData == null) return const SizedBox.shrink();
    
    final tracking = _currentData!.tracking;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInfoItem(
            icon: Icons.access_time,
            label: 'Temps écoulé',
            value: tracking.minutesSinceStart != null
                ? '${tracking.minutesSinceStart} min'
                : 'N/A',
          ),
          _buildInfoItem(
            icon: Icons.trending_up,
            label: 'Progression',
            value: '${tracking.progressPercentage.toStringAsFixed(0)}%',
          ),
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
