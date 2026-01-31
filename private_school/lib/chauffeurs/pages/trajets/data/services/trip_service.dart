import 'package:flutter/foundation.dart';
import 'package:private_school/chauffeurs/pages/trajets/data/models/trip_model.dart';
import 'package:private_school/core/network/api_client.dart';

class TripService {
  final ApiClient _apiClient = ApiClient();

  Future<List<TripModel>> fetchTrips() async {
    try {
      debugPrint('🚗 [TripService] Fetching trips from /api/drivers/trips...');
      
      final response = await _apiClient.get('/api/drivers/trips');
      
      debugPrint('🚗 [TripService] Response received');
      debugPrint('🚗 [TripService] Response type: ${response.data.runtimeType}');
      debugPrint('🚗 [TripService] Response data: ${response.data}');
      
      // Extraire les données selon la structure de la réponse
      final List<dynamic> tripsData = response.data is List
          ? response.data
          : response.data['data'] ?? response.data['trips'] ?? [];
      
      debugPrint('🚗 [TripService] Trips count: ${tripsData.length}');
      
      final trips = tripsData
          .map((json) => TripModel.fromJson(json as Map<String, dynamic>))
          .toList();
      
      debugPrint('✅ [TripService] ${trips.length} trips parsed successfully');
      
      return trips;
    } catch (e) {
      debugPrint('❌ [TripService] Error fetching trips: $e');
      throw Exception('Failed to load trips: $e');
    }
  }

  Future<TripModel> createTrip({
    required String destination,
    String? startLocation,
    required DateTime date,
    required String time,
    required int totalSeats,
    double? price,
  }) async {
    try {
      debugPrint('🚗 [TripService] Creating trip...');
      debugPrint('🚗 [TripService] Destination: $destination');
      debugPrint('🚗 [TripService] Date: ${date.toIso8601String()}');
      debugPrint('🚗 [TripService] Time: $time');
      debugPrint('🚗 [TripService] Total seats: $totalSeats');
      
      final response = await _apiClient.post(
        '/api/drivers/trips',
        data: {
          'destination': destination,
          if (startLocation != null) 'startLocation': startLocation,
          'date': date.toIso8601String(),
          'time': time,
          'totalSeats': totalSeats,
          if (price != null) 'price': price,
        },
      );
      
      debugPrint('✅ [TripService] Trip created successfully');
      
      final tripData = response.data is Map
          ? (response.data['data'] ?? response.data)
          : response.data;
      
      return TripModel.fromJson(tripData as Map<String, dynamic>);
    } catch (e) {
      debugPrint('❌ [TripService] Error creating trip: $e');
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