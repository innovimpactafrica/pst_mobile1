import 'package:flutter/material.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/utils/api_constants.dart';
import '../models/trip_model.dart';

/// Service for driver trip operations
class TripService {
  final ApiClient _apiClient = ApiClient();

 Future<List<TripModel>> getDriverTrips() async {
  try {
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('🚗 [TripService] Fetching trips...');

    final response = await _apiClient.get(ApiConstants.driverTrips);

    debugPrint('✅ Response: ${response.statusCode}');

    List<dynamic> tripsJson = [];

    if (response.data is Map<String, dynamic>) {
      final map = response.data as Map<String, dynamic>;
      if (map.containsKey('data') && map['data'] is List) {
        tripsJson = map['data'] as List;
      } else if (map.containsKey('trips') && map['trips'] is List) {
        tripsJson = map['trips'] as List;
      }
    } else if (response.data is List) {
      tripsJson = response.data as List;
    }

    debugPrint('📊 Total trips reçus: ${tripsJson.length}');

    // ✅ LOG DÉTAILLÉ de chaque trajet brut
    for (int i = 0; i < tripsJson.length; i++) {
      final raw = tripsJson[i] as Map<String, dynamic>;
      debugPrint('──────────────────────────────────────');
      debugPrint('🚗 TRAJET[$i] ID: ${raw['id']}');
      debugPrint('   school_id: ${raw['school_id']}');
      debugPrint('   school_ids: ${raw['school_ids']}');
      debugPrint('   school_name: ${raw['school_name']}');
      debugPrint('   stops: ${raw['stops']}');
      debugPrint('   stops length: ${(raw['stops'] as List?)?.length ?? 0}');
      debugPrint('   passengers: ${(raw['passengers'] as List?)?.length ?? 0} passager(s)');
    }
    debugPrint('──────────────────────────────────────');

    final trips = tripsJson
        .map((json) => TripModel.fromJson(json as Map<String, dynamic>))
        .toList();

    // ✅ LOG après parsing Flutter
    for (int i = 0; i < trips.length; i++) {
      debugPrint('✅ TRAJET PARSÉ[$i] ID: ${trips[i].id}');
      debugPrint('   schools count: ${trips[i].schools.length}');
      debugPrint('   passengers count: ${trips[i].passengers.length}');
      for (var school in trips[i].schools) {
        debugPrint('   🏫 école: ${school.name} (ID: ${school.id})');
      }
      for (var p in trips[i].passengers) {
        debugPrint('   👤 passager: ${p.name}');
      }
    }

    // Filtrer les trajets passés
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final filteredTrips = trips.where((trip) {
      final tripDate = DateTime(trip.date.year, trip.date.month, trip.date.day);
      return !tripDate.isBefore(today);
    }).toList();

    debugPrint('🔍 ${filteredTrips.length} trip(s) après filtrage');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    return filteredTrips;
  } catch (e, stackTrace) {
    debugPrint('❌ [TripService] Error: $e');
    debugPrint('Stack: $stackTrace\n');
    rethrow;
  }
}

  /// Create a new trip
  /// POST /api/drivers/trips
 Future<Map<String, dynamic>> createTrip({
  required String startPoint,
  required String endPoint,
  DateTime? departureTime,
  DateTime? returnTime,
  required int capacityMax,
  required List<int> schoolIds,
  required bool isRecurring,
  double? startLatitude,
  double? startLongitude,
  double? endLatitude,
  double? endLongitude,
}) async {
  try {
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('🟢 [TripService] CREATE TRIP');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    final requestBody = {
      'start_point': startPoint,
      'end_point': endPoint,
      if (departureTime != null) 'departure_time': departureTime.toIso8601String(),
      if (returnTime != null) 'return_departure_time': returnTime.toIso8601String(),
      'capacity_max': capacityMax,
      'school_ids': schoolIds,
      'is_recurring': isRecurring,
      if (startLatitude != null) 'start_latitude': startLatitude,
      if (startLongitude != null) 'start_longitude': startLongitude,
      if (endLatitude != null) 'end_latitude': endLatitude,
      if (endLongitude != null) 'end_longitude': endLongitude,
    };

    debugPrint('📤 CE QU ON ENVOIE AU SERVEUR:');
    debugPrint('   start_point: $startPoint');
    debugPrint('   end_point: $endPoint');
    debugPrint('   capacity_max: $capacityMax');
    debugPrint('   school_ids: $schoolIds');
    debugPrint('   school_ids type: ${schoolIds.runtimeType}');
    debugPrint('   school_ids length: ${schoolIds.length}');
    for (int i = 0; i < schoolIds.length; i++) {
      debugPrint('   school_ids[$i]: ${schoolIds[i]} (type: ${schoolIds[i].runtimeType})');
    }
    debugPrint('   is_recurring: $isRecurring');
    if (departureTime != null) debugPrint('   departure_time: ${departureTime.toIso8601String()}');
    if (returnTime != null) debugPrint('   return_departure_time: ${returnTime.toIso8601String()}');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    final response = await _apiClient.post(
      ApiConstants.driverTrips,
      data: requestBody,
    );

    debugPrint('📥 CE QUE LE SERVEUR RETOURNE:');
    debugPrint('   Status: ${response.statusCode}');

    final responseData = response.data;
    if (responseData is Map) {
      final data = responseData['data'];
      if (data is Map) {
        debugPrint('   ── Champs retournés par le serveur ──');
        data.forEach((key, value) {
          debugPrint('   $key: $value');
        });
        debugPrint('   ─────────────────────────────────────');
        debugPrint('   school_id: ${data['school_id']}');
        debugPrint('   school_ids: ${data['school_ids']}');
        debugPrint('   stops: ${data['stops']}');
        debugPrint('   schools: ${data['schools']}');
      } else {
        debugPrint('   data brut: $data');
      }
    }
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    return response.data as Map<String, dynamic>;
  } catch (e, stackTrace) {
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('❌ [TripService] CREATE TRIP ERROR');
    debugPrint('Error: $e');
    debugPrint('Stack: $stackTrace');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
    rethrow;
  }
}

  /// Start a trip
  /// PUT /api/drivers/trips/{id}/start
  Future<Map<String, dynamic>> startTrip(String tripId, {String? direction}) async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🚀 [TripService] START TRIP: $tripId (${direction ?? "aller"})');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      
      String url = ApiConstants.driverTripStart(tripId);
      if (direction != null) {
        url += '?direction=$direction';
      }
      
      final response = await _apiClient.put(url);
      
      debugPrint('✅ Trip started successfully');
      debugPrint('📦 Response: ${response.data}');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      
      return response.data as Map<String, dynamic>;
    } catch (e) {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('❌ [TripService] Error starting trip: $e');
      
      if (e.toString().contains('400')) {
        debugPrint('⚠️ Erreur 400: Pas d\'enfants inscrits ou date passée');
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
        throw Exception('Impossible de démarrer: aucun passager inscrit');
      }
      
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      rethrow;
    }
  }

  /// Complete a trip
  /// ✅ CORRIGÉ : PUT au lieu de POST
  /// PUT /api/drivers/trips/{id}/completed
  Future<Map<String, dynamic>> completeTrip(String tripId, {String? direction}) async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('✅ [TripService] COMPLETE TRIP: $tripId (${direction ?? "aller"})');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      
      String url = ApiConstants.driverTripCompleted(tripId);
      if (direction != null) {
        url += '?direction=$direction';
      }
      
      // ✅ CORRIGÉ : Utiliser PUT au lieu de POST
      final response = await _apiClient.put(url);
      
      debugPrint('✅ Trip completed successfully');
      debugPrint('📦 Response: ${response.data}');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      
      return response.data as Map<String, dynamic>;
    } catch (e) {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('❌ [TripService] Error completing trip: $e');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      rethrow;
    }
  }

  /// Cancel a trip
  /// ✅ CORRIGÉ : PUT au lieu de POST
  /// PUT /api/drivers/trips/{id}/canceled
  Future<Map<String, dynamic>> cancelTrip(String tripId, String reason) async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🔴 [TripService] CANCEL TRIP: $tripId');
      debugPrint('📝 Reason: $reason');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      
      // ✅ CORRIGÉ : Utiliser PUT au lieu de POST
      final response = await _apiClient.put(
        ApiConstants.driverTripCanceled(tripId),
        data: {'reason': reason},
      );
      
      debugPrint('✅ Trip canceled successfully');
      debugPrint('📦 Response: ${response.data}');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      
      return response.data as Map<String, dynamic>;
    } catch (e) {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('❌ [TripService] Error canceling trip: $e');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      rethrow;
    }
  }
}