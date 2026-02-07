import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:private_school/core/utils/app_colors.dart';
import 'package:private_school/core/utils/app_constants.dart';

/// Widget pour afficher une carte Google Maps avec le trajet
class TripMapWidget extends StatefulWidget {
  final String startLocation;
  final String destination;
  final Function(double distance, int duration)? onRouteCalculated;

  const TripMapWidget({
    super.key,
    required this.startLocation,
    required this.destination,
    this.onRouteCalculated,
  });

  @override
  State<TripMapWidget> createState() => _TripMapWidgetState();
}

class _TripMapWidgetState extends State<TripMapWidget> {
  final Completer<GoogleMapController> _controller = Completer();
  
  // Coordonnées par défaut (Dakar, Sénégal)
  static const LatLng _defaultCenter = LatLng(14.6928, -17.4467);
  
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  LatLng? _startLatLng;
  LatLng? _destinationLatLng;
  
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    try {
      // Géocoder les adresses pour obtenir les coordonnées
      _startLatLng = await _geocodeAddress(widget.startLocation);
      _destinationLatLng = await _geocodeAddress(widget.destination);

      if (_startLatLng != null && _destinationLatLng != null) {
        // Créer les markers
        _createMarkers();
        
        // Tracer le trajet
        await _drawRoute();
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ [TripMapWidget] Erreur initialisation: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Géocoder une adresse en coordonnées GPS
  Future<LatLng?> _geocodeAddress(String address) async {
    try {
      // 📍 COORDONNÉES FIXES POUR LES LIEUX COMMUNS AU SÉNÉGAL
      final Map<String, LatLng> commonLocations = {
        // Dakar et quartiers
        'liberte6': LatLng(14.7094, -17.4575),
        'liberté 6': LatLng(14.7094, -17.4575),
        'saint gabriel': LatLng(14.6928, -17.4467),
        'saint-gabriel': LatLng(14.6928, -17.4467),
        'ouakam': LatLng(14.7123, -17.4899),
        'parcelles assainies': LatLng(14.7711, -17.4144),
        'parcelles': LatLng(14.7711, -17.4144),
        'yeumbeul': LatLng(14.7678, -17.3750),
        'pikine': LatLng(14.7549, -17.3959),
        'guediawaye': LatLng(14.7722, -17.4078),
        'sacre coeur': LatLng(14.7031, -17.4556),
        'sacré-coeur': LatLng(14.7031, -17.4556),
        'almadies': LatLng(14.7353, -17.5197),
        'plateau': LatLng(14.6708, -17.4369),
        'medina': LatLng(14.6878, -17.4478),
        'fann': LatLng(14.6883, -17.4558),
        'hann': LatLng(14.7244, -17.4219),
        'grand dakar': LatLng(14.7194, -17.4633),
        'mamelles': LatLng(14.7139, -17.4994),
        'ngor': LatLng(14.7481, -17.5189),
        'yoff': LatLng(14.7389, -17.4764),
        'cambérène': LatLng(14.7808, -17.4614),
        'camberene': LatLng(14.7808, -17.4614),
        
        // Écoles connues
        'ecole primaire saint-michel': LatLng(14.6928, -17.4467),
        'école maternelle les petits loups': LatLng(14.7094, -17.4575),
        'institution sainte jeanne d\'arc': LatLng(14.6975, -17.4558),
        'cours sainte marie de hann': LatLng(14.7267, -17.4247),
        'école1': LatLng(14.7678, -17.3750), // YEUMBEUL
      };

      // Normaliser l'adresse
      final normalizedAddress = address.toLowerCase().trim();
      
      // Chercher dans les lieux communs
      for (var entry in commonLocations.entries) {
        if (normalizedAddress.contains(entry.key)) {
          debugPrint('✅ Lieu trouvé: ${entry.key} -> ${entry.value}');
          return entry.value;
        }
      }

      // Si pas trouvé, utiliser coordonnées par défaut (centre de Dakar)
      debugPrint('⚠️ Lieu non trouvé, utilisation position par défaut');
      return _defaultCenter;
    } catch (e) {
      debugPrint('❌ Erreur géocodage: $e');
      return _defaultCenter;
    }
  }

  /// Créer les marqueurs de départ et d'arrivée
  void _createMarkers() {
    _markers = {
      // Marker de départ (vert)
      Marker(
        markerId: const MarkerId('start'),
        position: _startLatLng!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(
          title: 'Départ',
          snippet: widget.startLocation,
        ),
      ),
      // Marker d'arrivée (rouge)
      Marker(
        markerId: const MarkerId('destination'),
        position: _destinationLatLng!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(
          title: 'Arrivée',
          snippet: widget.destination,
        ),
      ),
    };
  }

  /// Tracer le trajet entre départ et arrivée
  Future<void> _drawRoute() async {
    try {
      final polylinePoints = PolylinePoints();
      
      // Obtenir les points du trajet depuis l'API Google Directions
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleApiKey: 'AIzaSyAGd7ZK7kkDEr9NOWcQOzkbDL8ddUStX9A',
        request: PolylineRequest(
          origin: PointLatLng(_startLatLng!.latitude, _startLatLng!.longitude),
          destination: PointLatLng(_destinationLatLng!.latitude, _destinationLatLng!.longitude),
          mode: TravelMode.driving,
        ),
      );

      if (result.points.isNotEmpty) {
        // Convertir les points en LatLng
        List<LatLng> polylineCoordinates = result.points
            .map((point) => LatLng(point.latitude, point.longitude))
            .toList();

        // Créer la polyline
        _polylines = {
          Polyline(
            polylineId: const PolylineId('route'),
            points: polylineCoordinates,
            color: AppColors.primary,
            width: 5,
          ),
        };

        // Calculer distance et durée
        final distance = _calculateDistance(_startLatLng!, _destinationLatLng!);
        final duration = _estimateDuration(distance);
        
        // Notifier le parent
        if (widget.onRouteCalculated != null) {
          widget.onRouteCalculated!(distance, duration);
        }

        // Ajuster la caméra pour montrer tout le trajet
        _fitBounds();
      } else {
        debugPrint('❌ Aucun point de trajet trouvé');
      }
    } catch (e) {
      debugPrint('❌ Erreur lors du tracé du trajet: $e');
    }
  }

  /// Calculer la distance entre deux points (en km)
  double _calculateDistance(LatLng start, LatLng end) {
    // Formule de Haversine pour calculer la distance
    const double earthRadius = 6371; // Rayon de la Terre en km
    
    final dLat = _toRadians(end.latitude - start.latitude);
    final dLon = _toRadians(end.longitude - start.longitude);
    
    final a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
        Math.cos(_toRadians(start.latitude)) *
            Math.cos(_toRadians(end.latitude)) *
            Math.sin(dLon / 2) *
            Math.sin(dLon / 2);
    
    final c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    
    return earthRadius * c;
  }

  double _toRadians(double degrees) {
    return degrees * (Math.pi / 180);
  }

  /// Estimer la durée du trajet (en minutes)
  int _estimateDuration(double distanceKm) {
    // Vitesse moyenne en ville: 30 km/h
    const double avgSpeedKmPerHour = 30;
    final durationHours = distanceKm / avgSpeedKmPerHour;
    return (durationHours * 60).round(); // Convertir en minutes
  }

  /// Ajuster les limites de la caméra pour afficher tout le trajet
  Future<void> _fitBounds() async {
    if (_startLatLng == null || _destinationLatLng == null) return;

    final GoogleMapController controller = await _controller.future;
    
    // Calculer les limites
    final double minLat = Math.min(_startLatLng!.latitude, _destinationLatLng!.latitude);
    final double maxLat = Math.max(_startLatLng!.latitude, _destinationLatLng!.latitude);
    final double minLng = Math.min(_startLatLng!.longitude, _destinationLatLng!.longitude);
    final double maxLng = Math.max(_startLatLng!.longitude, _destinationLatLng!.longitude);

    final LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        height: 280,
        decoration: BoxDecoration(
          color: AppColors.grey200,
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        ),
      );
    }

    return Container(
      height: 280,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: _startLatLng ?? _defaultCenter,
            zoom: 12,
          ),
          markers: _markers,
          polylines: _polylines,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
            _fitBounds();
          },
        ),
      ),
    );
  }
}

// Classe Math pour les fonctions mathématiques
class Math {
  static double sin(double x) => math.sin(x);
  static double cos(double x) => math.cos(x);
  static double sqrt(double x) => math.sqrt(x);
  static double atan2(double y, double x) => math.atan2(y, x);
  static double min(double a, double b) => a < b ? a : b;
  static double max(double a, double b) => a > b ? a : b;
  static const double pi = math.pi;
}