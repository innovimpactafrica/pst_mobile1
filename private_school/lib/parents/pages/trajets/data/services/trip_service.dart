import 'package:flutter/material.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/utils/api_constants.dart';
import '../models/trip_model.dart';

class TripService {
  final ApiClient _apiClient = ApiClient();

  /// all AVAILABLE trips (trajets disponibles pour réserver)

  Future<List<TripModel>> getAllTrips() async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint(' [TripService] GET AVAILABLE TRIPS');
      debugPrint(' Endpoint: /api/parents/trips/available');
      debugPrint(' Récupère les trajets disponibles pour réservation');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final response = await _apiClient.get('/api/parents/trips/available');

      debugPrint(' Response Status: ${response.statusCode}');
      debugPrint(' Response Type: ${response.data.runtimeType}');

      // Parser la réponse
      List<dynamic> tripsJson = [];

      if (response.data is List) {
        tripsJson = response.data as List;
        debugPrint(' Direct List format');
      } else if (response.data is Map<String, dynamic>) {
        final map = response.data as Map<String, dynamic>;

        if (map.containsKey('data') && map['data'] is List) {
          tripsJson = map['data'] as List;
          debugPrint(' Found in "data" key');
        } else if (map.containsKey('trips') && map['trips'] is List) {
          tripsJson = map['trips'] as List;
          debugPrint(' Found in "trips" key');
        } else {
          debugPrint(' Keys found: ${map.keys.toList()}');
        }
      }

      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint(' TRAJETS DISPONIBLES: ${tripsJson.length}');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      // Parser chaque trajet
      final trips = <TripModel>[];
      for (int i = 0; i < tripsJson.length; i++) {
        try {
          final tripJson = tripsJson[i];
          debugPrint('');
          debugPrint(' Trajet ${i + 1}/${tripsJson.length}:');
          debugPrint('   ID: ${tripJson['id']}');
          debugPrint('   Status: ${tripJson['status']}');
          debugPrint('   Start: ${tripJson['start_point']}');
          debugPrint('   End: ${tripJson['end_point']}');

          final trip = TripModel.fromJson(tripJson);
          trips.add(trip);
          debugPrint('    Parsé avec succès');
        } catch (e) {
          debugPrint('    Error parsing trip ${i + 1}: $e');
        }
      }

      debugPrint('');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint(' RÉSULTAT:');
      debugPrint('   Trajets disponibles: ${trips.length}');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      return trips;
    } catch (e, stackTrace) {
      debugPrint('');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint(' ERROR GETTING AVAILABLE TRIPS');
      debugPrint('Error: $e');
      debugPrint('Stack: $stackTrace');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      rethrow;
    }
  }

  ///  trajets déjà réservés par le parent

  Future<List<TripModel>> getMyReservations() async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint(' [TripService] GET MY RESERVATIONS');
      debugPrint(' Endpoint: /api/parents/trips');
      debugPrint(' Récupère les trajets déjà réservés');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final response = await _apiClient.get(ApiConstants.parentAllTrips);

      debugPrint(' Response: ${response.statusCode}');

      final List<dynamic> tripsJson;

      if (response.data is Map<String, dynamic>) {
        tripsJson = response.data['trips'] ?? response.data['data'] ?? [];
      } else if (response.data is List) {
        tripsJson = response.data;
      } else {
        throw Exception('Format de réponse invalide');
      }

      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint(' MES RÉSERVATIONS: ${tripsJson.length}');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      // Parser les réservations avec logs détaillés
      final reservations = <TripModel>[];
      for (int i = 0; i < tripsJson.length; i++) {
        try {
          final tripJson = tripsJson[i];
          debugPrint('');
          debugPrint(' Réservation ${i + 1}/${tripsJson.length}:');
          debugPrint('   Trip ID: ${tripJson['id']}');
          debugPrint('   Driver ID: ${tripJson['driver_id']}');
          debugPrint('   Status: ${tripJson['status']}');

          //  LOGS DÉTAILLÉS DES DONNÉES CHAUFFEUR
          debugPrint('');
          debugPrint('    DONNÉES CHAUFFEUR REÇUES:');
          debugPrint('   - driver_name: ${tripJson['driver_name']}');
          debugPrint('   - driver_phone: ${tripJson['driver_phone']}');
          debugPrint('   - driver_rating: ${tripJson['driver_rating']}');
          debugPrint('   - driver_photo: ${tripJson['driver_photo']}');
          debugPrint('   - vehicle_plate: ${tripJson['vehicle_plate']}');
          debugPrint('   - vehicle_photo: ${tripJson['vehicle_photo']}');
          debugPrint('');

          final trip = TripModel.fromJson(tripJson);
          reservations.add(trip);

          debugPrint('    APRÈS PARSING TripModel:');
          debugPrint('   - driverName: ${trip.driverName}');
          debugPrint('   - driverPhoto: ${trip.driverPhoto}');
          debugPrint('   - vehiclePhoto: ${trip.vehiclePhoto}');
          debugPrint('   - hasDriverPhoto: ${trip.hasDriverPhoto}');
          debugPrint('   - hasVehiclePhoto: ${trip.hasVehiclePhoto}');
          debugPrint('   - driverPhotoUrl: ${trip.driverPhotoUrl}');
          debugPrint('   - vehiclePhotoUrl: ${trip.vehiclePhotoUrl}');
          debugPrint('    Parsé avec succès');
        } catch (e, stack) {
          debugPrint('    Error: $e');
          debugPrint('   Stack: $stack');
        }
      }

      debugPrint('');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint(' RÉSULTAT:');
      debugPrint('   Réservations: ${reservations.length}');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      return reservations;
    } catch (e, stackTrace) {
      debugPrint('');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint(' ERROR GETTING RESERVATIONS');
      debugPrint('Error: $e');
      debugPrint('Stack: $stackTrace');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      rethrow;
    }
  }

  /// Search for available trips

  Future<List<TripModel>> searchTrips({
    String? homeAddress,
    String? schoolAddress,
    String? departureTime,
    String? childId,
  }) async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint(' [TripService] SEARCH TRIPS');
      debugPrint(' Params:');
      debugPrint('   Home: $homeAddress');
      debugPrint('   School: $schoolAddress');
      debugPrint('   Time: $departureTime');
      debugPrint('   Child: $childId');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final queryParams = <String, dynamic>{};
      if (homeAddress != null) queryParams['homeAddress'] = homeAddress;
      if (schoolAddress != null) queryParams['schoolAddress'] = schoolAddress;
      if (departureTime != null) queryParams['departureTime'] = departureTime;
      if (childId != null) queryParams['childId'] = childId;

      final response = await _apiClient.get(
        ApiConstants.tripsSearch,
        queryParameters: queryParams,
      );

      debugPrint(' Response: ${response.statusCode}');

      final List<dynamic> tripsJson;

      if (response.data is Map<String, dynamic>) {
        tripsJson = response.data['trips'] ?? response.data['data'] ?? [];
      } else if (response.data is List) {
        tripsJson = response.data;
      } else {
        throw Exception('Format de réponse invalide');
      }

      debugPrint(' ${tripsJson.length} trajet(s) trouvé(s)');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      return tripsJson.map((tripJson) => TripModel.fromJson(tripJson)).toList();
    } catch (e) {
      debugPrint(' Error searching trips: $e\n');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getFilterOptions() async {
    try {
      debugPrint('🔍 [TripService] GET FILTERS');
      final response = await _apiClient.get(ApiConstants.tripsFilters);
      debugPrint(' Filters loaded\n');
      return response.data;
    } catch (e) {
      debugPrint(' Error loading filters: $e\n');
      rethrow;
    }
  }

  /// details trajets
  Future<TripModel> getTripDetails(String tripId) async {
    try {
      debugPrint('🔍 [TripService] GET TRIP DETAILS: $tripId');

      final response = await _apiClient.get(ApiConstants.tripDetails(tripId));

      debugPrint(' Details loaded\n');

      final tripData = response.data['trip'] ?? response.data;
      return TripModel.fromJson(tripData);
    } catch (e) {
      debugPrint(' Error loading trip details: $e\n');
      rethrow;
    }
  }

  /// Track a trip in real-time
  Future<Map<String, dynamic>> trackTripRealtime(String tripId) async {
    try {
      debugPrint(' [TripService] TRACK REALTIME: $tripId');

      final response = await _apiClient.get(ApiConstants.tripRealtime(tripId));

      debugPrint(' Realtime data loaded\n');
      return response.data;
    } catch (e) {
      debugPrint(' Error tracking trip: $e\n');
      rethrow;
    }
  }

  /// Reserve a trip

  Future<Map<String, dynamic>> reserveTrip({
    required String tripId,
    required String childId,
  }) async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint(' [TripService] RESERVE TRIP');
      debugPrint(' Trip ID: $tripId');
      debugPrint(' Child ID: $childId');
      debugPrint(' Endpoint: ${ApiConstants.reservations}');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final requestBody = {
        'trip_id': tripId,
        'child_ids': [childId],
        'is_recurring': false,
      };

      debugPrint(' Request Body:');
      debugPrint('   $requestBody');

      final response = await _apiClient.post(
        ApiConstants.reservations,
        data: requestBody,
      );

      debugPrint(' Response Status: ${response.statusCode}');
      debugPrint(' Response Data: ${response.data}');
      debugPrint(' Reservation successful');
      debugPrint('e trajet apparaîtra maintenant dans "Mes réservations"');
      debugPrint(' Le statut sera synchronisé avec le chauffeur/admin');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      return response.data;
    } catch (e, stackTrace) {
      debugPrint('');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint(' [TripService] ERREUR RÉSERVATION');
      debugPrint('Error: $e');
      debugPrint('Stack: $stackTrace');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      rethrow;
    }
  }

  /// Reserve for multiple children

  Future<Map<String, dynamic>> reserveTripForMultipleChildren({
    required String tripId,
    required List<String> childIds,
    bool isRecurring = false,
  }) async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint(' [TripService] RESERVE TRIP (MULTIPLE CHILDREN)');
      debugPrint(' Trip ID: $tripId');
      debugPrint(' Children IDs: $childIds');
      debugPrint(' Is Recurring: $isRecurring');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final requestBody = {
        'trip_id': tripId,
        'child_ids': childIds,
        'is_recurring': isRecurring,
      };

      final response = await _apiClient.post(
        ApiConstants.reservations,
        data: requestBody,
      );

      debugPrint(' Reservation successful for ${childIds.length} children');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      return response.data;
    } catch (e) {
      debugPrint(' Error: $e\n');
      rethrow;
    }
  }

  /// Cancel a reservation
  Future<void> cancelReservation({
    required String tripId,
    required String childId,
  }) async {
    try {
      debugPrint(' [TripService] CANCEL RESERVATION');
      debugPrint(' Trip: $tripId, Child: $childId');

      await _apiClient.delete(ApiConstants.cancelReservation(tripId, childId));

      debugPrint(' Reservation cancelled\n');
    } catch (e) {
      debugPrint(' Error cancelling reservation: $e\n');
      rethrow;
    }
  }

  /// Contact the driver

  Future<Map<String, dynamic>> contactDriver({
    required String tripId,
    required String message,
  }) async {
    try {
      debugPrint(' [TripService] CONTACT DRIVER');
      debugPrint(' Trip: $tripId');

      final response = await _apiClient.post(
        ApiConstants.contactDriver(tripId),
        data: {'message': message},
      );

      debugPrint(' Message sent\n');

      return response.data;
    } catch (e) {
      debugPrint(' Error contacting driver: $e\n');
      rethrow;
    }
  }
}
