import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:http/http.dart' as http;
import 'package:easy_localization/easy_localization.dart' as easy;
import 'package:private_school/core/utils/app_colors.dart';
import 'package:private_school/core/utils/app_constants.dart';

/// Widget pour afficher une carte Google Maps avec le trajet
/// ✅ AMÉLIORÉ: Utilise Google Geocoding API pour toutes les adresses du Sénégal
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
  
  // ✅ Clé API Google (la même que dans votre code)
  static const String _googleApiKey = 'AIzaSyAGd7ZK7kkDEr9NOWcQOzkbDL8ddUStX9A';
  
  // Coordonnées par défaut (Dakar, Sénégal)
  static const LatLng _defaultCenter = LatLng(14.6928, -17.4467);
  
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  LatLng? _startLatLng;
  LatLng? _destinationLatLng;
  
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🗺️ [TripMapWidget] Initialisation de la carte');
      debugPrint('📍 Départ: ${widget.startLocation}');
      debugPrint('📍 Destination: ${widget.destination}');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      // ✅ Géocoder les adresses avec Google Geocoding API
      _startLatLng = await _geocodeAddressWithGoogle(widget.startLocation);
      _destinationLatLng = await _geocodeAddressWithGoogle(widget.destination);

      if (_startLatLng != null && _destinationLatLng != null) {
        debugPrint('✅ Coordonnées trouvées:');
        debugPrint('   Départ: ${_startLatLng!.latitude}, ${_startLatLng!.longitude}');
        debugPrint('   Arrivée: ${_destinationLatLng!.latitude}, ${_destinationLatLng!.longitude}');
        
        // Créer les markers
        _createMarkers();
        
        // Tracer le trajet
        await _drawRoute();
      } else {
        _errorMessage = 'unable_locate_addresses'.tr();
        debugPrint('❌ Échec du géocodage');
      }

      setState(() {
        _isLoading = false;
      });
      
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
    } catch (e) {
      debugPrint('❌ [TripMapWidget] Erreur initialisation: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'error_loading_map'.tr();
      });
    }
  }

  /// ✅ NOUVEAU: Géocoder une adresse avec Google Geocoding API
  /// Permet de trouver TOUTES les adresses du Sénégal (quartiers Dakar + régions)
  Future<LatLng?> _geocodeAddressWithGoogle(String address) async {
    try {
      debugPrint('🔍 Géocodage de: "$address"');

      // ✅ Ajouter ", Sénégal" pour améliorer la précision
      final searchQuery = address.contains('Sénégal') || address.contains('Senegal')
          ? address
          : '$address, Sénégal';

      // ✅ Appel à Google Geocoding API
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json'
        '?address=${Uri.encodeComponent(searchQuery)}'
        '&region=sn' // ✅ Priorité au Sénégal
        '&key=$_googleApiKey',
      );

      debugPrint('📡 Requête Geocoding: $url');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          final location = data['results'][0]['geometry']['location'];
          final lat = location['lat'];
          final lng = location['lng'];
          final formattedAddress = data['results'][0]['formatted_address'];

          debugPrint('✅ Géocodage réussi:');
          debugPrint('   Adresse trouvée: $formattedAddress');
          debugPrint('   Coordonnées: $lat, $lng');

          return LatLng(lat, lng);
        } else {
          debugPrint('⚠️ Aucun résultat pour "$address"');
          debugPrint('   Status: ${data['status']}');
          
          // ✅ Fallback sur coordonnées connues
          return _getFallbackCoordinates(address);
        }
      } else {
        debugPrint('❌ Erreur API Geocoding: ${response.statusCode}');
        return _getFallbackCoordinates(address);
      }
    } catch (e) {
      debugPrint('❌ Exception géocodage: $e');
      return _getFallbackCoordinates(address);
    }
  }

  /// ✅ Fallback: Coordonnées connues pour les lieux communs
  LatLng? _getFallbackCoordinates(String address) {
    debugPrint('🔄 Utilisation du fallback pour: "$address"');

    final Map<String, LatLng> commonLocations = {
      // ========== DAKAR - QUARTIERS ==========
      'plateau': LatLng(14.6708, -17.4369),
      'medina': LatLng(14.6878, -17.4478),
      'fann': LatLng(14.6883, -17.4558),
      'mermoz': LatLng(14.7031, -17.4486),
      'sacre coeur': LatLng(14.7031, -17.4556),
      'sacré-coeur': LatLng(14.7031, -17.4556),
      'almadies': LatLng(14.7353, -17.5197),
      'ouakam': LatLng(14.7123, -17.4899),
      'ngor': LatLng(14.7481, -17.5189),
      'yoff': LatLng(14.7389, -17.4764),
      'mamelles': LatLng(14.7139, -17.4994),
      'liberte6': LatLng(14.7094, -17.4575),
      'liberté 6': LatLng(14.7094, -17.4575),
      'liberté6': LatLng(14.7094, -17.4575),
      'parcelles assainies': LatLng(14.7711, -17.4144),
      'parcelles': LatLng(14.7711, -17.4144),
      'grand dakar': LatLng(14.7194, -17.4633),
      'hann': LatLng(14.7244, -17.4219),
      'bel air': LatLng(14.7033, -17.4494),
      'point e': LatLng(14.7089, -17.4511),
      'grand yoff': LatLng(14.7553, -17.4764),
      
      // ========== BANLIEUE DAKAR ==========
      'pikine': LatLng(14.7549, -17.3959),
      'guediawaye': LatLng(14.7722, -17.4078),
      'guédiawaye': LatLng(14.7722, -17.4078),
      'yeumbeul': LatLng(14.7678, -17.3750),
      'thiaroye': LatLng(14.7656, -17.3483),
      'rufisque': LatLng(14.7167, -17.2733),
      'bargny': LatLng(14.7019, -17.2133),
      'cambérène': LatLng(14.7808, -17.4614),
      'camberene': LatLng(14.7808, -17.4614),
      'keur massar': LatLng(14.7875, -17.3175),
      'malika': LatLng(14.7914, -17.3961),
      
      // ========== RÉGIONS DU SÉNÉGAL ==========
      'thiès': LatLng(14.7886, -16.9262),
      'thies': LatLng(14.7886, -16.9262),
      'diourbel': LatLng(14.6553, -16.2297),
      'kaolack': LatLng(14.1503, -16.0769),
      'saint-louis': LatLng(16.0178, -16.5119),
      'saint louis': LatLng(16.0178, -16.5119),
      'ziguinchor': LatLng(12.5833, -16.2733),
      'louga': LatLng(15.6169, -16.2281),
      'fatick': LatLng(14.3389, -16.4111),
      'tambacounda': LatLng(13.7719, -13.6689),
      'kolda': LatLng(12.8833, -14.95),
      'matam': LatLng(15.6558, -13.2558),
      'kaffrine': LatLng(14.1061, -15.5508),
      'kédougou': LatLng(12.5608, -12.1842),
      'kedougou': LatLng(12.5608, -12.1842),
      'sédhiou': LatLng(12.7083, -15.5567),
      'sedhiou': LatLng(12.7083, -15.5567),
      
      // ========== ÉCOLES CONNUES ==========
      'saint gabriel': LatLng(14.6928, -17.4467),
      'saint-gabriel': LatLng(14.6928, -17.4467),
      'cours sainte marie': LatLng(14.7267, -17.4247),
      'institution sainte jeanne': LatLng(14.6975, -17.4558),
      'lycée delafosse': LatLng(14.7031, -17.4556),
      'prytanée militaire': LatLng(16.0247, -16.5142),
    };

    // Normaliser l'adresse
    final normalized = address.toLowerCase().trim();
    
    // Chercher dans les lieux communs
    for (var entry in commonLocations.entries) {
      if (normalized.contains(entry.key)) {
        debugPrint('✅ Fallback trouvé: ${entry.key}');
        return entry.value;
      }
    }

    // Si rien trouvé, retourner le centre de Dakar
    debugPrint('⚠️ Aucun fallback trouvé, utilisation du centre de Dakar');
    return _defaultCenter;
  }

  /// Créer les marqueurs de départ et d'arrivée
  void _createMarkers() {
    _markers = {
      Marker(
        markerId: const MarkerId('start'),
        position: _startLatLng!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(
          title: 'departure'.tr(),
          snippet: widget.startLocation,
        ),
      ),
      Marker(
        markerId: const MarkerId('destination'),
        position: _destinationLatLng!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(
          title: 'arrival'.tr(),
          snippet: widget.destination,
        ),
      ),
    };
  }

  /// Tracer le trajet entre départ et arrivée
  Future<void> _drawRoute() async {
    try {
      debugPrint('🛣️ Tracé du trajet...');
      
      final polylinePoints = PolylinePoints();
      
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleApiKey: _googleApiKey,
        request: PolylineRequest(
          origin: PointLatLng(_startLatLng!.latitude, _startLatLng!.longitude),
          destination: PointLatLng(_destinationLatLng!.latitude, _destinationLatLng!.longitude),
          mode: TravelMode.driving,
        ),
      );

      if (result.points.isNotEmpty) {
        List<LatLng> polylineCoordinates = result.points
            .map((point) => LatLng(point.latitude, point.longitude))
            .toList();

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
        
        debugPrint('📏 Distance: ${distance.toStringAsFixed(2)} km');
        debugPrint('⏱️ Durée estimée: $duration min');
        
        if (widget.onRouteCalculated != null) {
          widget.onRouteCalculated!(distance, duration);
        }

        _fitBounds();
      } else {
        debugPrint('❌ Aucun point de trajet trouvé');
      }
    } catch (e) {
      debugPrint('❌ Erreur lors du tracé du trajet: $e');
    }
  }

  double _calculateDistance(LatLng start, LatLng end) {
    const double earthRadius = 6371;
    
    final dLat = _toRadians(end.latitude - start.latitude);
    final dLon = _toRadians(end.longitude - start.longitude);
    
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(start.latitude)) *
            math.cos(_toRadians(end.latitude)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    
    return earthRadius * c;
  }

  double _toRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  int _estimateDuration(double distanceKm) {
    const double avgSpeedKmPerHour = 30;
    final durationHours = distanceKm / avgSpeedKmPerHour;
    return (durationHours * 60).round();
  }

  Future<void> _fitBounds() async {
    if (_startLatLng == null || _destinationLatLng == null) return;

    final GoogleMapController controller = await _controller.future;
    
    final double minLat = math.min(_startLatLng!.latitude, _destinationLatLng!.latitude);
    final double maxLat = math.max(_startLatLng!.latitude, _destinationLatLng!.latitude);
    final double minLng = math.min(_startLatLng!.longitude, _destinationLatLng!.longitude);
    final double maxLng = math.max(_startLatLng!.longitude, _destinationLatLng!.longitude);

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
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (_errorMessage != null) {
      return Container(
        height: 280,
        decoration: BoxDecoration(
          color: AppColors.grey200,
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                style: const TextStyle(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
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
          zoomControlsEnabled: true,
          zoomGesturesEnabled: true,
          scrollGesturesEnabled: true,
          tiltGesturesEnabled: true,
          rotateGesturesEnabled: true,
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