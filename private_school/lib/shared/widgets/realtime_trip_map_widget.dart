import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'dart:ui' as ui;
import 'dart:convert';
import 'package:http/http.dart' as http;
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
  Polyline? _routePolyline;

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
    const size = Size(60, 60);

    final paint = Paint()
      ..color = AppColors.error
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(10, 20, 40, 25),
        const Radius.circular(5),
      ),
      paint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(15, 10, 30, 15),
        const Radius.circular(5),
      ),
      paint,
    );

    final wheelPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(20, 45), 5, wheelPaint);
    canvas.drawCircle(const Offset(40, 45), 5, wheelPaint);

    final picture = pictureRecorder.endRecording();
    final image = await picture.toImage(
      size.width.toInt(),
      size.height.toInt(),
    );
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.bytes(bytes!.buffer.asUint8List());
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
    _driverPath.add(newPosition);

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

    _polylines.add(
      Polyline(
        polylineId: const PolylineId('driver_path'),
        points: _driverPath,
        color: AppColors.success,
        width: 4,
      ),
    );

    _mapController?.animateCamera(CameraUpdate.newLatLng(newPosition));

    if (mounted) setState(() {});
  }

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

      final lat =
          oldPosition.latitude +
          (newPosition.latitude - oldPosition.latitude) * progress;
      final lng =
          oldPosition.longitude +
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
      return Container(
        color: Colors.grey.shade200,
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return Stack(
      children: [
        RawGestureDetector(
          gestures: {
            // Absorbe les gestes de scale (zoom 2 doigts)
            ScaleGestureRecognizer:
                GestureRecognizerFactoryWithHandlers<ScaleGestureRecognizer>(
                  () => ScaleGestureRecognizer(),
                  (ScaleGestureRecognizer instance) {
                    instance.onStart = (_) {};
                    instance.onUpdate = (_) {};
                    instance.onEnd = (_) {};
                  },
                ),
            // Absorbe les gestes de pan (déplacer la carte)
            PanGestureRecognizer:
                GestureRecognizerFactoryWithHandlers<PanGestureRecognizer>(
                  () => PanGestureRecognizer(),
                  (PanGestureRecognizer instance) {
                    instance.onStart = (_) {};
                    instance.onUpdate = (_) {};
                    instance.onEnd = (_) {};
                  },
                ),
          },
          child: GoogleMap(
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

            zoomControlsEnabled: true,
            mapToolbarEnabled: false,

            zoomGesturesEnabled: true,
            scrollGesturesEnabled: true,
            tiltGesturesEnabled: true,
            rotateGesturesEnabled: true,
          ),
        ),

        // Informations de suivi en temps réel
        if (widget.enableRealtime && _currentData != null)
          Positioned(top: 16, left: 16, right: 16, child: _buildTrackingInfo()),
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
