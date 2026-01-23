import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../../core/storage/secure_storage.dart';
import '../../../../../core/utils/api_constants.dart';
import '../models/trip_model.dart';

/// Service for handling trip-related API calls
class TripService {
  final SecureStorage _secureStorage = SecureStorage();

  /// Get headers with authentication token
  Future<Map<String, String>> _getHeaders() async {
    final token = await _secureStorage.getAccessToken();
    return {
      'Content-Type': ApiConstants.contentType,
      'Authorization': 'Bearer $token',
    };
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
      final headers = await _getHeaders();

      // Build query parameters
      final queryParams = <String, String>{};
      if (homeAddress != null) queryParams['homeAddress'] = homeAddress;
      if (schoolAddress != null) queryParams['schoolAddress'] = schoolAddress;
      if (departureTime != null) queryParams['departureTime'] = departureTime;
      if (childId != null) queryParams['childId'] = childId;

      final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.tripsSearch}')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: headers,
      ).timeout(ApiConstants.connectTimeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> tripsJson = jsonResponse['trips'] ?? [];

        return tripsJson
            .map((tripJson) => TripModel.fromJson(tripJson))
            .toList();
      } else if (response.statusCode == 401) {
        throw Exception('Session expirée. Veuillez vous reconnecter.');
      } else {
        throw Exception('Erreur lors de la recherche des trajets');
      }
    } catch (e) {
      throw Exception('Erreur réseau: ${e.toString()}');
    }
  }

  /// Get available filter options
  /// GET /api/parents/trips/filters
  Future<Map<String, dynamic>> getFilterOptions() async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.tripsFilters}');

      final response = await http.get(
        url,
        headers: headers,
      ).timeout(ApiConstants.connectTimeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Session expirée. Veuillez vous reconnecter.');
      } else {
        throw Exception('Erreur lors du chargement des filtres');
      }
    } catch (e) {
      throw Exception('Erreur réseau: ${e.toString()}');
    }
  }

  /// Get complete trip details
  /// GET /api/parents/trips/{tripId}/details
  Future<TripModel> getTripDetails(String tripId) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.tripDetails(tripId)}');

      final response = await http.get(
        url,
        headers: headers,
      ).timeout(ApiConstants.connectTimeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return TripModel.fromJson(jsonResponse['trip']);
      } else if (response.statusCode == 401) {
        throw Exception('Session expirée. Veuillez vous reconnecter.');
      } else {
        throw Exception('Erreur lors du chargement des détails');
      }
    } catch (e) {
      throw Exception('Erreur réseau: ${e.toString()}');
    }
  }

  /// Track a trip in real-time
  /// GET /api/parents/trips/{tripId}/realtime
  Future<Map<String, dynamic>> trackTripRealtime(String tripId) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.tripRealtime(tripId)}');

      final response = await http.get(
        url,
        headers: headers,
      ).timeout(ApiConstants.connectTimeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Session expirée. Veuillez vous reconnecter.');
      } else {
        throw Exception('Erreur lors du suivi du trajet');
      }
    } catch (e) {
      throw Exception('Erreur réseau: ${e.toString()}');
    }
  }

  /// Reserve a trip
  /// POST /api/parents/reservations
  Future<Map<String, dynamic>> reserveTrip({
    required String tripId,
    required String childId,
  }) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.reservations}');

      final body = json.encode({
        'tripId': tripId,
        'childId': childId,
      });

      final response = await http.post(
        url,
        headers: headers,
        body: body,
      ).timeout(ApiConstants.connectTimeout);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Session expirée. Veuillez vous reconnecter.');
      } else {
        final errorMessage = json.decode(response.body)['message'] ??
            'Erreur lors de la réservation';
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('Erreur réseau: ${e.toString()}');
    }
  }

  /// Get all reservations for the parent
  /// GET /api/parents/reservations
  Future<List<TripModel>> getMyReservations() async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.reservations}');

      final response = await http.get(
        url,
        headers: headers,
      ).timeout(ApiConstants.connectTimeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> reservationsJson = jsonResponse['reservations'] ?? [];

        return reservationsJson
            .map((resJson) => TripModel.fromJson(resJson))
            .toList();
      } else if (response.statusCode == 401) {
        throw Exception('Session expirée. Veuillez vous reconnecter.');
      } else {
        throw Exception('Erreur lors du chargement des réservations');
      }
    } catch (e) {
      throw Exception('Erreur réseau: ${e.toString()}');
    }
  }

  /// Cancel a reservation
  /// DELETE /api/parents/reservations/{tripId}/{childId}
  Future<void> cancelReservation({
    required String tripId,
    required String childId,
  }) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse(
          '${ApiConstants.baseUrl}${ApiConstants.cancelReservation(tripId, childId)}'
      );

      final response = await http.delete(
        url,
        headers: headers,
      ).timeout(ApiConstants.connectTimeout);

      if (response.statusCode == 200) {
        return;
      } else if (response.statusCode == 401) {
        throw Exception('Session expirée. Veuillez vous reconnecter.');
      } else {
        final errorMessage = json.decode(response.body)['message'] ??
            'Erreur lors de l\'annulation';
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('Erreur réseau: ${e.toString()}');
    }
  }

  /// Contact the driver
  /// POST /api/parents/trips/{tripId}/contact-driver
  Future<Map<String, dynamic>> contactDriver({
    required String tripId,
    required String message,
  }) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('${ApiConstants.baseUrl}/api/parents/trips/$tripId/contact-driver');

      final body = json.encode({
        'message': message,
      });

      final response = await http.post(
        url,
        headers: headers,
        body: body,
      ).timeout(ApiConstants.connectTimeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Session expirée. Veuillez vous reconnecter.');
      } else {
        final errorMessage = json.decode(response.body)['message'] ??
            'Erreur lors de l\'envoi du message';
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('Erreur réseau: ${e.toString()}');
    }
  }
}