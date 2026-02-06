import 'package:flutter/material.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/utils/api_constants.dart';
import '../models/trip_model.dart';

/// Service for handling trip-related API calls
class TripService {
  final ApiClient _apiClient = ApiClient();

  /// Get all available trips
  /// GET /api/trips (tous les trajets)
  Future<List<TripModel>> getAllTrips() async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🔵 [TripService] GET ALL TRIPS');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final response = await _apiClient.get('/api/trips');

      debugPrint('✅ [TripService] Response: ${response.statusCode}');
      debugPrint('📦 [TripService] Data: ${response.data}');

      final List<dynamic> tripsJson;

      if (response.data is Map<String, dynamic>) {
        tripsJson = response.data['trips'] ?? 
                   response.data['data'] ?? 
                   [];
      } else if (response.data is List) {
        tripsJson = response.data;
      } else {
        throw Exception('Format de réponse invalide');
      }

      debugPrint('✅ [TripService] ${tripsJson.length} trajet(s) trouvé(s)');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      return tripsJson
          .map((tripJson) => TripModel.fromJson(tripJson))
          .toList();
    } catch (e) {
      debugPrint('❌ [TripService] Error fetching trips: $e');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      rethrow;
    }
  }

  /// Search for available trips (optimized search)
  /// GET /api/parents/trips/search
  Future<List<TripModel>> searchTrips({
    String? homeAddress,
    String? schoolAddress,
    String? departureTime,
    String? childId,
  }) async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🔵 [TripService] SEARCH TRIPS');
      debugPrint('📤 Params: home=$homeAddress, school=$schoolAddress, time=$departureTime');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      // Build query parameters
      final queryParams = <String, dynamic>{};
      if (homeAddress != null) queryParams['homeAddress'] = homeAddress;
      if (schoolAddress != null) queryParams['schoolAddress'] = schoolAddress;
      if (departureTime != null) queryParams['departureTime'] = departureTime;
      if (childId != null) queryParams['childId'] = childId;

      final response = await _apiClient.get(
        ApiConstants.tripsSearch,
        queryParameters: queryParams,
      );

      debugPrint('✅ [TripService] Response: ${response.statusCode}');
      debugPrint('📦 [TripService] Data: ${response.data}');

      final List<dynamic> tripsJson;

      if (response.data is Map<String, dynamic>) {
        tripsJson = response.data['trips'] ?? 
                   response.data['data'] ?? 
                   [];
      } else if (response.data is List) {
        tripsJson = response.data;
      } else {
        throw Exception('Format de réponse invalide');
      }

      debugPrint('✅ [TripService] ${tripsJson.length} trajet(s) trouvé(s)');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      return tripsJson
          .map((tripJson) => TripModel.fromJson(tripJson))
          .toList();
    } catch (e) {
      debugPrint('❌ [TripService] Error searching trips: $e');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      rethrow;
    }
  }

  /// Get available filter options
  /// GET /api/parents/trips/filters
  Future<Map<String, dynamic>> getFilterOptions() async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🔵 [TripService] GET FILTERS');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final response = await _apiClient.get(ApiConstants.tripsFilters);

      debugPrint('✅ [TripService] Filters loaded');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      return response.data;
    } catch (e) {
      debugPrint('❌ [TripService] Error loading filters: $e');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      rethrow;
    }
  }

  /// Get complete trip details
  /// GET /api/parents/trips/{tripId}/details
  Future<TripModel> getTripDetails(String tripId) async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🔵 [TripService] GET TRIP DETAILS');
      debugPrint('📤 Trip ID: $tripId');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final response = await _apiClient.get(
        ApiConstants.tripDetails(tripId),
      );

      debugPrint('✅ [TripService] Details loaded');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      final tripData = response.data['trip'] ?? response.data;
      return TripModel.fromJson(tripData);
    } catch (e) {
      debugPrint('❌ [TripService] Error loading trip details: $e');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      rethrow;
    }
  }

  /// Track a trip in real-time
  /// GET /api/parents/trips/{tripId}/realtime
  Future<Map<String, dynamic>> trackTripRealtime(String tripId) async {
    try {
      debugPrint('🔵 [TripService] TRACK REALTIME: $tripId');

      final response = await _apiClient.get(
        ApiConstants.tripRealtime(tripId),
      );

      debugPrint('✅ [TripService] Realtime data loaded');
      return response.data;
    } catch (e) {
      debugPrint('❌ [TripService] Error tracking trip: $e');
      rethrow;
    }
  }

  /// Reserve a trip
  /// POST /api/parents/reservations
  Future<Map<String, dynamic>> reserveTrip({
    required String tripId,
    required String childId,
  }) async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🟢 [TripService] RESERVE TRIP');
      debugPrint('📤 Trip: $tripId, Child: $childId');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final response = await _apiClient.post(
        ApiConstants.reservations,
        data: {
          'tripId': tripId,
          'childId': childId,
        },
      );

      debugPrint('✅ [TripService] Reservation successful');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      return response.data;
    } catch (e) {
      debugPrint('❌ [TripService] Error reserving trip: $e');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      rethrow;
    }
  }

  /// Get all reservations for the parent
  /// GET /api/parents/reservations
  Future<List<TripModel>> getMyReservations() async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🔵 [TripService] GET MY RESERVATIONS');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final response = await _apiClient.get(ApiConstants.reservations);

      debugPrint('✅ [TripService] Response: ${response.statusCode}');
      debugPrint('📦 [TripService] Data: ${response.data}');

      final List<dynamic> reservationsJson;

      if (response.data is Map<String, dynamic>) {
        reservationsJson = response.data['reservations'] ?? 
                          response.data['data'] ?? 
                          [];
      } else if (response.data is List) {
        reservationsJson = response.data;
      } else {
        throw Exception('Format de réponse invalide');
      }

      debugPrint('✅ [TripService] ${reservationsJson.length} réservation(s) trouvée(s)');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      return reservationsJson
          .map((resJson) => TripModel.fromJson(resJson))
          .toList();
    } catch (e) {
      debugPrint('❌ [TripService] Error loading reservations: $e');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      rethrow;
    }
  }

  /// Cancel a reservation
  /// DELETE /api/parents/reservations/{tripId}/{childId}
  Future<void> cancelReservation({
    required String tripId,
    required String childId,
  }) async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🔴 [TripService] CANCEL RESERVATION');
      debugPrint('📤 Trip: $tripId, Child: $childId');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      await _apiClient.delete(
        ApiConstants.cancelReservation(tripId, childId),
      );

      debugPrint('✅ [TripService] Reservation cancelled');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
    } catch (e) {
      debugPrint('❌ [TripService] Error cancelling reservation: $e');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      rethrow;
    }
  }

  /// Contact the driver
  /// POST /api/parents/trips/{tripId}/contact-driver
  Future<Map<String, dynamic>> contactDriver({
    required String tripId,
    required String message,
  }) async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🟢 [TripService] CONTACT DRIVER');
      debugPrint('📤 Trip: $tripId');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final response = await _apiClient.post(
        ApiConstants.contactDriver(tripId),
        data: {'message': message},
      );

      debugPrint('✅ [TripService] Message sent');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      return response.data;
    } catch (e) {
      debugPrint('❌ [TripService] Error contacting driver: $e');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      rethrow;
    }
  }
}