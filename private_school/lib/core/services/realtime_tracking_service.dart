import 'package:flutter/material.dart';
import 'dart:async';
import '../network/api_client.dart';

/// Modèle de données de suivi en temps réel
class RealtimeTripData {
  final int tripId;
  final String tripType;
  final String? activeDirection;
  final CurrentLocation? currentLocation;
  final TrackingInfo tracking;
  final CurrentLeg? currentLeg;

  RealtimeTripData({
    required this.tripId,
    required this.tripType,
    this.activeDirection,
    this.currentLocation,
    required this.tracking,
    this.currentLeg,
  });

  factory RealtimeTripData.fromJson(Map<String, dynamic> json) {
    return RealtimeTripData(
      tripId: json['trip_id'],
      tripType: json['trip_type'] ?? 'aller',
      activeDirection: json['active_direction'],
      currentLocation: json['current_location'] != null
          ? CurrentLocation.fromJson(json['current_location'])
          : null,
      tracking: TrackingInfo.fromJson(json['tracking']),
      currentLeg: json['current_leg'] != null
          ? CurrentLeg.fromJson(json['current_leg'])
          : null,
    );
  }
}

class CurrentLocation {
  final double latitude;
  final double longitude;
  final String direction;
  final double? speed;
  final double? accuracy;
  final double? heading;
  final DateTime timestamp;

  CurrentLocation({
    required this.latitude,
    required this.longitude,
    required this.direction,
    this.speed,
    this.accuracy,
    this.heading,
    required this.timestamp,
  });

  factory CurrentLocation.fromJson(Map<String, dynamic> json) {
    return CurrentLocation(
      latitude: double.parse(json['latitude'].toString()),
      longitude: double.parse(json['longitude'].toString()),
      direction: json['direction'] ?? 'aller',
      speed: json['speed'] != null
          ? double.parse(json['speed'].toString())
          : null,
      accuracy: json['accuracy'] != null
          ? double.parse(json['accuracy'].toString())
          : null,
      heading: json['heading'] != null
          ? double.parse(json['heading'].toString())
          : null,
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class TrackingInfo {
  final bool isActive;
  final String activeDirection;
  final int? minutesSinceStart;
  final String? estimatedArrival;
  final double progressPercentage;

  TrackingInfo({
    required this.isActive,
    required this.activeDirection,
    this.minutesSinceStart,
    this.estimatedArrival,
    required this.progressPercentage,
  });

  factory TrackingInfo.fromJson(Map<String, dynamic> json) {
    return TrackingInfo(
      isActive: json['is_active'] ?? false,
      activeDirection: json['active_direction'] ?? 'aller',
      minutesSinceStart: json['minutes_since_start'],
      estimatedArrival: json['estimated_arrival'],
      progressPercentage: (json['progress_percentage'] ?? 0).toDouble(),
    );
  }
}

class CurrentLeg {
  final String direction;
  final String startPoint;
  final String endPoint;
  final Coordinates startCoordinates;
  final Coordinates endCoordinates;

  CurrentLeg({
    required this.direction,
    required this.startPoint,
    required this.endPoint,
    required this.startCoordinates,
    required this.endCoordinates,
  });

  factory CurrentLeg.fromJson(Map<String, dynamic> json) {
    return CurrentLeg(
      direction: json['direction'] ?? 'aller',
      startPoint: json['start_point'] ?? '',
      endPoint: json['end_point'] ?? '',
      startCoordinates: Coordinates.fromJson(json['start_coordinates']),
      endCoordinates: Coordinates.fromJson(json['end_coordinates']),
    );
  }
}

class Coordinates {
  final double latitude;
  final double longitude;

  Coordinates({required this.latitude, required this.longitude});

  factory Coordinates.fromJson(Map<String, dynamic> json) {
    return Coordinates(
      latitude: json['latitude'] != null
          ? double.parse(json['latitude'].toString())
          : 0.0,
      longitude: json['longitude'] != null
          ? double.parse(json['longitude'].toString())
          : 0.0,
    );
  }
}

/// Service de suivi en temps réel
class RealtimeTrackingService {
  final ApiClient _apiClient = ApiClient();
  Timer? _pollingTimer;
  final _trackingController = StreamController<RealtimeTripData>.broadcast();

  Stream<RealtimeTripData> get trackingStream => _trackingController.stream;

  /// Récupérer les données de suivi en temps réel
  Future<RealtimeTripData> getRealtimeData(String tripId) async {
    try {
      final response = await _apiClient.get(
        '/api/parents/trips/$tripId/realtime',
      );

      if (response.data['success'] == true) {
        final data = RealtimeTripData.fromJson(response.data['data']);
        _trackingController.add(data);
        return data;
      }

      throw Exception('Erreur récupération données');
    } catch (e) {
      debugPrint(' Erreur récupération suivi: $e');
      rethrow;
    }
  }

  /// Démarrer le polling automatique (toutes les 5 secondes)
  void startPolling(String tripId) {
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint(' [RealtimeTracking] Démarrage du polling');
    debugPrint('   Trip ID: $tripId');
    debugPrint('   Intervalle: 5 secondes');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    // Récupérer immédiatement
    getRealtimeData(tripId);

    // Puis toutes les 5 secondes
    _pollingTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => getRealtimeData(tripId),
    );
  }

  /// Arrêter le polling
  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    debugPrint('Polling arrêté\n');
  }

  void dispose() {
    stopPolling();
    _trackingController.close();
  }
}
