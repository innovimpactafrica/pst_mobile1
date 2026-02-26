import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/api_client.dart';

class LocationService {
  final ApiClient _apiClient = ApiClient();
  Timer? _locationTimer;
  StreamSubscription<Position>? _positionStream;
  static const String _cachedLocationsKey = 'cached_locations';

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
      debugPrint(' Mode offline activé (cache local)');
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

  /// Envoyer la position actuelle au serveur (avec cache offline)
  Future<void> _sendCurrentLocation(String tripId) async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final locationData = {
        'trip_id': tripId,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'speed': position.speed * 3.6, // m/s -> km/h
        'accuracy': position.accuracy,
        'heading': position.heading,
        'timestamp': DateTime.now().toIso8601String(),
      };

      // Essayer d'envoyer immédiatement
      try {
        await _apiClient.post(
          '/api/drivers/trips/$tripId/location',
          data: locationData,
        );

        debugPrint(
          ' Position envoyée: ${position.latitude}, ${position.longitude}',
        );

        // Si succès, envoyer les positions en cache
        await _sendCachedLocations(tripId);
      } catch (e) {
        // Pas de connexion → sauvegarder en cache
        debugPrint(' Pas de connexion, mise en cache...');
        await _cacheLocation(locationData);
        debugPrint(
          ' Position mise en cache: ${position.latitude}, ${position.longitude}',
        );
      }
    } catch (e) {
      debugPrint(' Erreur récupération position: $e');
    }
  }

  /// Sauvegarder une position en cache local
  Future<void> _cacheLocation(Map<String, dynamic> locationData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(_cachedLocationsKey) ?? '[]';
      final List<dynamic> cached = json.decode(cachedJson);

      cached.add(locationData);

      // Limiter à 100 positions max en cache
      if (cached.length > 100) {
        cached.removeAt(0);
      }

      await prefs.setString(_cachedLocationsKey, json.encode(cached));
      debugPrint(' ${cached.length} position(s) en cache');
    } catch (e) {
      debugPrint(' Erreur sauvegarde cache: $e');
    }
  }

  /// Envoyer toutes les positions en cache
 Future<void> _sendCachedLocations(String tripId) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final cachedJson = prefs.getString(_cachedLocationsKey);

    if (cachedJson == null || cachedJson == '[]') return;

    final List<dynamic> cached = json.decode(cachedJson);
    if (cached.isEmpty) return;

    debugPrint(' Envoi de ${cached.length} position(s) en cache une par une...');

    // Envoyer une par une au lieu du batch (batch endpoint n'existe pas)
    int sent = 0;
    for (final location in cached) {
      try {
        await _apiClient.post(
          '/api/drivers/trips/$tripId/location',
          data: location,
        );
        sent++;
      } catch (e) {
        debugPrint(' Erreur envoi position cache: $e');
        break; // Arrêter si pas de connexion
      }
    }

    if (sent > 0) {
      await prefs.remove(_cachedLocationsKey);
      debugPrint(' $sent position(s) envoyée(s), cache vidé');
    }
  } catch (e) {
    debugPrint(' Erreur envoi cache: $e');
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

  /// Obtenir le nombre de positions en cache
  Future<int> getCachedLocationsCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(_cachedLocationsKey) ?? '[]';
      final List<dynamic> cached = json.decode(cachedJson);
      return cached.length;
    } catch (e) {
      return 0;
    }
  }
}
