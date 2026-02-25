/*import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import '../../data/models/trip_model.dart';
import '../../data/services/trip_service.dart';

class RealtimeTripMap extends StatefulWidget {
  final TripModel trip;

  const RealtimeTripMap({super.key, required this.trip});

  @override
  State<RealtimeTripMap> createState() => _RealtimeTripMapState();
}

class _RealtimeTripMapState extends State<RealtimeTripMap> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  Timer? _locationTimer;
  LatLng? _driverPosition;
  final TripService _tripService = TripService();

  @override
  void initState() {
    super.initState();
    _initializeMap();
    _startLocationTracking();
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _initializeMap() async {
    await _drawRoute();
    _addStaticMarkers();
  }

  void _startLocationTracking() {
    // Poll position toutes les 5 secondes
    _locationTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _fetchDriverLocation();
    });
    _fetchDriverLocation(); // Premier appel immédiat
  }

  Future<void> _fetchDriverLocation() async {
    try {
      final data = await _tripService.trackTripRealtime(widget.trip.id);
      
      if (data['driver_location'] != null) {
        final lat = data['driver_location']['latitude'];
        final lng = data['driver_location']['longitude'];
        
        if (lat != null && lng != null) {
          final newPosition = LatLng(lat.toDouble(), lng.toDouble());
          
          setState(() {
            _driverPosition = newPosition;
            _updateDriverMarker(newPosition);
          });
          
          // Animer la caméra vers la nouvelle position
          _mapController?.animateCamera(
            CameraUpdate.newLatLng(newPosition),
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Erreur récupération position: $e');
    }
  }

  void _updateDriverMarker(LatLng position) {
    _markers.removeWhere((m) => m.markerId.value == 'driver');
    _markers.add(
      Marker(
        markerId: const MarkerId('driver'),
        position: position,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(title: 'Chauffeur'),
        rotation: 0, // Calculer l'angle si nécessaire
      ),
    );
  }

  void _addStaticMarkers() {
    // Marqueur départ (si coordonnées disponibles)
    // Marqueur arrivée
    setState(() {});
  }

  Future<void> _drawRoute() async {
    try {
      final polylinePoints = PolylinePoints();
      final result = await polylinePoints.getRouteBetweenCoordinates(
        'AIzaSyAGd7ZK7kkDEr9NOWcQOzkbDL8ddUStX9A',
        PointLatLng(14.7167, -17.4677), // Départ (à remplacer par vraies coords)
        PointLatLng(14.7392, -17.4850), // Arrivée
      );

      if (result.points.isNotEmpty) {
        final polylineCoordinates = result.points
            .map((point) => LatLng(point.latitude, point.longitude))
            .toList();

        setState(() {
          _polylines.add(
            Polyline(
              polylineId: const PolylineId('route'),
              points: polylineCoordinates,
              color: Colors.blue,
              width: 5,
            ),
          );
        });
      }
    } catch (e) {
      debugPrint('❌ Erreur tracé route: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: const CameraPosition(
        target: LatLng(14.7167, -17.4677),
        zoom: 13,
      ),
      markers: _markers,
      polylines: _polylines,
      onMapCreated: (controller) => _mapController = controller,
      myLocationEnabled: false,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
    );
  }
}
*/
