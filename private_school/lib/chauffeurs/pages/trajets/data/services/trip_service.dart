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
      debugPrint('🚗 [TripService] Fetching trips from ${ApiConstants.driverTrips}...');
      
      final response = await _apiClient.get(ApiConstants.driverTrips);
      
      debugPrint('✅ Response: ${response.statusCode}');
      debugPrint('📦 Data type: ${response.data.runtimeType}');
      
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
      
      debugPrint('📊 Total trips: ${tripsJson.length}');
      
      final trips = tripsJson
          .map((json) => TripModel.fromJson(json as Map<String, dynamic>))
          .toList();
      
      // ✅ FILTRER les trajets passés (garder seulement aujourd'hui et futurs)
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      final filteredTrips = trips.where((trip) {
        final tripDate = DateTime(trip.date.year, trip.date.month, trip.date.day);
        return !tripDate.isBefore(today); // Garder aujourd'hui et futurs
      }).toList();
      
      debugPrint('✅ ${trips.length} trip(s) parsed successfully');
      debugPrint('🔍 ${filteredTrips.length} trip(s) after filtering past dates');
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
    required DateTime departureTime,
    required DateTime returnTime,
    required int capacityMax,
    required int schoolId,
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
        'departure_time': departureTime.toIso8601String(),
        'return_departure_time': returnTime.toIso8601String(),
        'capacity_max': capacityMax,
        'school_id': schoolId,
        'is_recurring': isRecurring,
        if (startLatitude != null) 'start_latitude': startLatitude,
        if (startLongitude != null) 'start_longitude': startLongitude,
        if (endLatitude != null) 'end_latitude': endLatitude,
        if (endLongitude != null) 'end_longitude': endLongitude,
      };
      
      debugPrint('📤 REQUEST BODY:');
      debugPrint('   start_point: $startPoint');
      debugPrint('   end_point: $endPoint');
      debugPrint('   departure_time: ${departureTime.toIso8601String()}');
      debugPrint('   return_departure_time: ${returnTime.toIso8601String()}');
      debugPrint('   capacity_max: $capacityMax');
      debugPrint('   school_id: $schoolId');
      debugPrint('   is_recurring: $isRecurring');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      
      final response = await _apiClient.post(
        ApiConstants.driverTrips,
        data: requestBody,
      );
      
      debugPrint('✅ Response Status: ${response.statusCode}');
      debugPrint('📦 Response Data: ${response.data}');
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
  /// ✅ CORRIGÉ : PUT au lieu de POST
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