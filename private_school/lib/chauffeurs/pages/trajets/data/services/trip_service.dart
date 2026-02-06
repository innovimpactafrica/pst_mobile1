import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:private_school/chauffeurs/pages/trajets/data/models/trip_model.dart';
import 'package:private_school/core/network/api_client.dart';

class TripService {
  final ApiClient _apiClient = ApiClient();

  Future<List<TripModel>> fetchTrips() async {
    try {
      debugPrint('🚗 [TripService] Fetching trips from /api/drivers/trips...');
      
      final response = await _apiClient.get('/api/drivers/trips');
      
      debugPrint('🚗 [TripService] ========================================');
      debugPrint('🚗 [TripService] RESPONSE RECEIVED');
      debugPrint('🚗 [TripService] ========================================');
      debugPrint('🚗 [TripService] Response type: ${response.data.runtimeType}');
      
      // Afficher la réponse complète formatée
      try {
        final prettyJson = JsonEncoder.withIndent('  ').convert(response.data);
        debugPrint('🚗 [TripService] Full response:\n$prettyJson');
      } catch (e) {
        debugPrint('🚗 [TripService] Response data: ${response.data}');
      }
      
      // Extraire les données selon la structure de la réponse
      final List<dynamic> tripsData = response.data is List
          ? response.data
          : response.data['data'] ?? response.data['trips'] ?? [];
      
      debugPrint('🚗 [TripService] Total trips count: ${tripsData.length}');
      
      final trips = tripsData
          .map((json) => TripModel.fromJson(json as Map<String, dynamic>))
          .toList();
      
      debugPrint('✅ [TripService] ${trips.length} trips parsed successfully');
      
      return trips;
    } catch (e, stackTrace) {
      debugPrint('❌ [TripService] ERROR FETCHING TRIPS');
      debugPrint('❌ [TripService] Error: $e');
      debugPrint('❌ [TripService] Stack trace: $stackTrace');
      throw Exception('Failed to load trips: $e');
    }
  }

  /// ✅ SIMPLIFIÉ : Accepte UN SEUL school_id
  Future<TripModel> createTrip({
    required String startPoint,
    required String endPoint,
    required DateTime departureTime,
    required int capacityMax,
    required int schoolId, // ✅ Un seul ID
    bool isRecurring = false,
  }) async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🚗 [TripService] CREATING TRIP');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('📍 Start point: $startPoint');
      debugPrint('📍 End point: $endPoint');
      debugPrint('🕐 Departure time: ${departureTime.toIso8601String()}');
      debugPrint('👥 Capacity max: $capacityMax');
      debugPrint('🏫 School ID: $schoolId'); // ✅ Un seul ID
      debugPrint('🔁 Is recurring: $isRecurring');
      
      final requestData = {
        'start_point': startPoint,
        'end_point': endPoint,
        'departure_time': departureTime.toIso8601String(),
        'capacity_max': capacityMax,
        'school_id': schoolId, // ✅ Un seul school_id
        'is_recurring': isRecurring,
      };
      
      debugPrint('📤 Request data: $requestData');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      
      final response = await _apiClient.post(
        '/api/drivers/trips',
        data: requestData,
      );
      
      debugPrint('✅ [TripService] Trip created successfully');
      debugPrint('📦 Response: ${response.data}');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      
      final tripData = response.data is Map
          ? (response.data['data'] ?? response.data)
          : response.data;
      
      return TripModel.fromJson(tripData as Map<String, dynamic>);
    } catch (e, stackTrace) {
      debugPrint('❌ [TripService] Error creating trip: $e');
      debugPrint('📚 Stack trace: $stackTrace');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      throw Exception('Failed to create trip: $e');
    }
  }

  Future<TripModel> startTrip(String tripId) async {
    try {
      debugPrint('🚗 [TripService] Starting trip $tripId...');
      
      final response = await _apiClient.put('/api/drivers/trips/$tripId/start');
      
      debugPrint('✅ [TripService] Trip $tripId started');
      
      final tripData = response.data is Map
          ? (response.data['data'] ?? response.data)
          : response.data;
      
      return TripModel.fromJson(tripData as Map<String, dynamic>);
    } catch (e) {
      debugPrint('❌ [TripService] Error starting trip: $e');
      throw Exception('Failed to start trip: $e');
    }
  }

  Future<TripModel> completeTrip(String tripId) async {
    try {
      debugPrint('🚗 [TripService] Completing trip $tripId...');
      
      final response = await _apiClient.put('/api/drivers/trips/$tripId/completed');
      
      debugPrint('✅ [TripService] Trip $tripId completed');
      
      final tripData = response.data is Map
          ? (response.data['data'] ?? response.data)
          : response.data;
      
      return TripModel.fromJson(tripData as Map<String, dynamic>);
    } catch (e) {
      debugPrint('❌ [TripService] Error completing trip: $e');
      throw Exception('Failed to complete trip: $e');
    }
  }

  Future<void> cancelTrip(String tripId, String reason) async {
    try {
      debugPrint('🚗 [TripService] Canceling trip $tripId...');
      debugPrint('🚗 [TripService] Reason: $reason');
      
      await _apiClient.put(
        '/api/drivers/trips/$tripId/canceled',
        data: {'reason': reason},
      );
      
      debugPrint('✅ [TripService] Trip $tripId canceled');
    } catch (e) {
      debugPrint('❌ [TripService] Error canceling trip: $e');
      throw Exception('Failed to cancel trip: $e');
    }
  }
}