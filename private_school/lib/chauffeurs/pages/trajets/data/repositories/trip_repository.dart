

import '../models/trip_model.dart';
import '../services/trip_service.dart';

class TripRepository {
  final TripService _service = TripService();

  Future<List<TripModel>> getTrips() async {
    try {
      return await _service.fetchTrips();
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
      return await _service.createTrip(
        destination: destination,
        startLocation: startLocation,
        date: date,
        time: time,
        totalSeats: totalSeats,
        price: price,
      );
    } catch (e) {
      throw Exception('Failed to create trip: $e');
    }
  }

  Future<TripModel> startTrip(String tripId) async {
    try {
      return await _service.startTrip(tripId);
    } catch (e) {
      throw Exception('Failed to start trip: $e');
    }
  }

  Future<TripModel> completeTrip(String tripId) async {
    try {
      return await _service.completeTrip(tripId);
    } catch (e) {
      throw Exception('Failed to complete trip: $e');
    }
  }

  Future<void> cancelTrip(String tripId, String reason) async {
    try {
      await _service.cancelTrip(tripId, reason);
    } catch (e) {
      throw Exception('Failed to cancel trip: $e');
    }
  }
}