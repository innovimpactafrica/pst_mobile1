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
      debugPrint('🔵 [TripService PARENT] GET ALL TRIPS');
      debugPrint('📍 Endpoint: /api/trips');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final response = await _apiClient.get('/api/trips');

      debugPrint('✅ [TripService] Response Status: ${response.statusCode}');
      debugPrint('📦 [TripService] Response Type: ${response.data.runtimeType}');
      debugPrint('📦 [TripService] Full Response:');
      debugPrint('$response.data');
      debugPrint('');

      final List<dynamic> tripsJson;

      // ✅ PARSER LA RÉPONSE
      if (response.data is Map<String, dynamic>) {
        final map = response.data as Map<String, dynamic>;
        debugPrint('📋 Map keys: ${map.keys.toList()}');
        
        // Essayer plusieurs clés possibles
        if (map.containsKey('trips')) {
          tripsJson = map['trips'] as List;
          debugPrint('✅ Found trips in "trips" key');
        } else if (map.containsKey('data')) {
          final data = map['data'];
          if (data is List) {
            tripsJson = data;
            debugPrint('✅ Found trips in "data" key (List)');
          } else if (data is Map && data.containsKey('trips')) {
            tripsJson = data['trips'];
            debugPrint('✅ Found trips in "data.trips" key');
          } else {
            tripsJson = [];
            debugPrint('⚠️ "data" key exists but format unknown');
          }
        } else if (map.containsKey('success')) {
          // Format { success: true, data: [...] }
          if (map['data'] is List) {
            tripsJson = map['data'];
            debugPrint('✅ Found trips in success response');
          } else {
            tripsJson = [];
            debugPrint('⚠️ Success response but no data array');
          }
        } else {
          tripsJson = [];
          debugPrint('⚠️ Unknown map structure');
        }
      } else if (response.data is List) {
        tripsJson = response.data;
        debugPrint('✅ Response is directly a List');
      } else {
        debugPrint('❌ Unknown response format');
        throw Exception('Format de réponse invalide: ${response.data.runtimeType}');
      }

      debugPrint('');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('📊 RÉSULTAT: ${tripsJson.length} trajet(s) trouvé(s)');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      // ✅ PARSER CHAQUE TRAJET AVEC LOGS
      final trips = <TripModel>[];
      for (int i = 0; i < tripsJson.length; i++) {
        try {
          debugPrint('');
          debugPrint('🚗 Parsing trip ${i + 1}/${tripsJson.length}:');
          debugPrint('   Raw data: ${tripsJson[i]}');
          
          final trip = TripModel.fromJson(tripsJson[i]);
          
          debugPrint('   ✅ Trip parsed successfully:');
          debugPrint('      ID: ${trip.id}');
          debugPrint('      Start: ${trip.startLocation}');
          debugPrint('      End: ${trip.destination}');
          debugPrint('      Date: ${trip.date}');
          debugPrint('      Status: ${trip.status}');
          debugPrint('      Schools: ${trip.schools.length}');
          
          trips.add(trip);
        } catch (e, stackTrace) {
          debugPrint('   ❌ Error parsing trip ${i + 1}:');
          debugPrint('   Error: $e');
          debugPrint('   Stack: $stackTrace');
          // Continue parsing other trips
        }
      }

      debugPrint('');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('✅ FINAL: ${trips.length}/${tripsJson.length} trajets parsés');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      return trips;
    } catch (e, stackTrace) {
      debugPrint('');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('❌ [TripService] ERREUR CRITIQUE');
      debugPrint('Error: $e');
      debugPrint('Stack trace:');
      debugPrint('$stackTrace');
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
      debugPrint('🔍 [TripService] SEARCH TRIPS');
      debugPrint('📤 Params:');
      debugPrint('   Home: $homeAddress');
      debugPrint('   School: $schoolAddress');
      debugPrint('   Time: $departureTime');
      debugPrint('   Child: $childId');
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

      debugPrint('✅ Response: ${response.statusCode}');

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

      debugPrint('✅ ${tripsJson.length} trajet(s) trouvé(s)');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      return tripsJson
          .map((tripJson) => TripModel.fromJson(tripJson))
          .toList();
    } catch (e) {
      debugPrint('❌ Error searching trips: $e\n');
      rethrow;
    }
  }

  /// Get available filter options
  /// GET /api/parents/trips/filters
  Future<Map<String, dynamic>> getFilterOptions() async {
    try {
      debugPrint('🔍 [TripService] GET FILTERS');
      final response = await _apiClient.get(ApiConstants.tripsFilters);
      debugPrint('✅ Filters loaded\n');
      return response.data;
    } catch (e) {
      debugPrint('❌ Error loading filters: $e\n');
      rethrow;
    }
  }

  /// Get complete trip details
  /// GET /api/parents/trips/{tripId}/details
  Future<TripModel> getTripDetails(String tripId) async {
    try {
      debugPrint('🔍 [TripService] GET TRIP DETAILS: $tripId');
      
      final response = await _apiClient.get(
        ApiConstants.tripDetails(tripId),
      );

      debugPrint('✅ Details loaded\n');

      final tripData = response.data['trip'] ?? response.data;
      return TripModel.fromJson(tripData);
    } catch (e) {
      debugPrint('❌ Error loading trip details: $e\n');
      rethrow;
    }
  }

  /// Track a trip in real-time
  /// GET /api/parents/trips/{tripId}/realtime
  Future<Map<String, dynamic>> trackTripRealtime(String tripId) async {
    try {
      debugPrint('📍 [TripService] TRACK REALTIME: $tripId');

      final response = await _apiClient.get(
        ApiConstants.tripRealtime(tripId),
      );

      debugPrint('✅ Realtime data loaded\n');
      return response.data;
    } catch (e) {
      debugPrint('❌ Error tracking trip: $e\n');
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

      debugPrint('✅ Reservation successful');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      return response.data;
    } catch (e) {
      debugPrint('❌ Error reserving trip: $e\n');
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

      debugPrint('✅ Response: ${response.statusCode}');
      debugPrint('📦 Data: ${response.data}');

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

      debugPrint('✅ ${reservationsJson.length} réservation(s) trouvée(s)');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      return reservationsJson
          .map((resJson) => TripModel.fromJson(resJson))
          .toList();
    } catch (e) {
      debugPrint('❌ Error loading reservations: $e\n');
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
      debugPrint('🔴 [TripService] CANCEL RESERVATION');
      debugPrint('📤 Trip: $tripId, Child: $childId');

      await _apiClient.delete(
        ApiConstants.cancelReservation(tripId, childId),
      );

      debugPrint('✅ Reservation cancelled\n');
    } catch (e) {
      debugPrint('❌ Error cancelling reservation: $e\n');
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
      debugPrint('🟢 [TripService] CONTACT DRIVER');
      debugPrint('📤 Trip: $tripId');

      final response = await _apiClient.post(
        ApiConstants.contactDriver(tripId),
        data: {'message': message},
      );

      debugPrint('✅ Message sent\n');

      return response.data;
    } catch (e) {
      debugPrint('❌ Error contacting driver: $e\n');
      rethrow;
    }
  }
}