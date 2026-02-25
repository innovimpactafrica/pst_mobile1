import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import '../network/api_client.dart';
class LocationService {
  final ApiClient _apiClient = ApiClient();
  Timer? _locationTimer;
  StreamSubscription<Position>? _positionStream;
  
  /// Démarrer le suivi GPS et l'envoi automatique
  Future<void> startLocationTracking(String tripId) async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint(' [LocationService] Démarrage du suivi GPS');
      debugPrint('   Trip ID: $tripId');
      
      // Vérifier les permissions
      final permission = await _checkPermissions();
      if (!permission) {
        throw Exception('Permission de géolocalisation refusée');
      }
      
      // Envoyer la position immédiatement
      await _sendCurrentLocation(tripId);
      
      // Configurer l'envoi automatique toutes les 30 secondes
      _locationTimer = Timer.periodic(
        const Duration(seconds: 30),
        (_) => _sendCurrentLocation(tripId),
      );
      
      debugPrint(' Suivi GPS démarré (envoi toutes les 30s)');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
    } catch (e) {
      debugPrint(' Erreur démarrage suivi GPS: $e\n');
      rethrow;
    }
  }
  
  /// Arrêter le suivi GPS
  void stopLocationTracking() {
    _locationTimer?.cancel();
    _locationTimer = null;
    _positionStream?.cancel();
    _positionStream = null;
    debugPrint(' Suivi GPS arrêté\n');
  }
  
  /// Vérifier et demander les permissions
  Future<bool> _checkPermissions() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint(' Service de localisation désactivé');
      return false;
    }
    
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint(' Permission de localisation refusée');
        return false;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      debugPrint(' Permission de localisation refusée définitivement');
      return false;
    }
    
    return true;
  }
  
  /// Envoyer la position actuelle au serveur
  Future<void> _sendCurrentLocation(String tripId) async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      final locationData = {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'speed': position.speed * 3.6, // m/s -> km/h
        'accuracy': position.accuracy,
        'heading': position.heading,
      };
      
      await _apiClient.post(
        '/api/drivers/trips/$tripId/location',
        data: locationData,
      );
      
      debugPrint(' Position envoyée: ${position.latitude}, ${position.longitude}');
    } catch (e) {
      debugPrint(' Erreur envoi position: $e');
    }
  }
  
  /// Obtenir la position actuelle (une seule fois)
  Future<Position> getCurrentPosition() async {
    final permission = await _checkPermissions();
    if (!permission) {
      throw Exception('Permission de géolocalisation refusée');
    }
    
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }
}
