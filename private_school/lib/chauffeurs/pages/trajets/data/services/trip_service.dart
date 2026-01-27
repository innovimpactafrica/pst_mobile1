

import '../../../../../core/network/api_client.dart';
import '../models/trip_model.dart';

class TripService {
  final ApiClient _apiClient = ApiClient();

  Future<List<TripModel>> fetchTrips() async {
    try {
      final response = await _apiClient.get('/api/drivers/trips');

      final List<dynamic> tripsData = response.data is List
          ? response.data
          : response.data['data'] ?? response.data['trips'] ?? [];

      return tripsData
          .map((json) => TripModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
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

      final tripData = response.data is Map
          ? (response.data['data'] ?? response.data)
          : response.data;

      return TripModel.fromJson(tripData as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to create trip: $e');
    }
  }

  Future<TripModel> startTrip(String tripId) async {
    try {
      final response = await _apiClient.put('/api/drivers/trips/$tripId/start');

      final tripData = response.data is Map
          ? (response.data['data'] ?? response.data)
          : response.data;

      return TripModel.fromJson(tripData as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to start trip: $e');
    }
  }

  Future<TripModel> completeTrip(String tripId) async {
    try {
      final response = await _apiClient.put('/api/drivers/trips/$tripId/completed');

      final tripData = response.data is Map
          ? (response.data['data'] ?? response.data)
          : response.data;

      return TripModel.fromJson(tripData as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to complete trip: $e');
    }
  }

  Future<void> cancelTrip(String tripId, String reason) async {
    try {
      await _apiClient.put(
        '/api/drivers/trips/$tripId/canceled',
        data: {'reason': reason},
      );
    } catch (e) {
      throw Exception('Failed to cancel trip: $e');
    }
  }
}