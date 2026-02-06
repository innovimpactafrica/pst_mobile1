import '../models/trip_model.dart';
import '../services/trip_service.dart';

class TripRepository {
  final TripService _tripService = TripService();

  /// Get all trips from the API
  /// This is what "Trajets disponibles" should call
  Future<List<TripModel>> getAllTrips() async {
    return await _tripService.getAllTrips();
  }

  /// Get only available trips (for "Trajets disponibles" tab)
  /// For now, same as getAllTrips, but can be filtered later
  Future<List<TripModel>> getAvailableTrips() async {
    // Pour l'instant, on récupère tous les trajets
    // Plus tard, on peut filtrer par statut "disponible" ou "en_attente"
    return await _tripService.getAllTrips();
  }

  /// Search for available trips with filters
  Future<List<TripModel>> searchTrips({
    String? homeAddress,
    String? schoolAddress,
    String? departureTime,
    String? childId,
  }) async {
    return await _tripService.searchTrips(
      homeAddress: homeAddress,
      schoolAddress: schoolAddress,
      departureTime: departureTime,
      childId: childId,
    );
  }

  /// Get my reservations
  Future<List<TripModel>> getMyReservations() async {
    return await _tripService.getMyReservations();
  }

  /// Get trip details by ID
  Future<TripModel> getTripDetails(String tripId) async {
    return await _tripService.getTripDetails(tripId);
  }

  /// DEPRECATED: Use getTripDetails() instead
  Future<TripModel?> getTripById(String id) async {
    try {
      return await _tripService.getTripDetails(id);
    } catch (e) {
      return null;
    }
  }

  /// Reserve a trip
  Future<Map<String, dynamic>> reserveTrip({
    required String tripId,
    required String childId,
  }) async {
    return await _tripService.reserveTrip(
      tripId: tripId,
      childId: childId,
    );
  }

  /// Cancel a reservation
  Future<void> cancelReservation({
    required String tripId,
    required String childId,
  }) async {
    await _tripService.cancelReservation(
      tripId: tripId,
      childId: childId,
    );
  }

  /// Get filter options
  Future<Map<String, dynamic>> getFilterOptions() async {
    return await _tripService.getFilterOptions();
  }

  /// Track trip in real-time
  Future<Map<String, dynamic>> trackTripRealtime(String tripId) async {
    return await _tripService.trackTripRealtime(tripId);
  }

  /// Contact the driver
  Future<Map<String, dynamic>> contactDriver({
    required String tripId,
    required String message,
  }) async {
    return await _tripService.contactDriver(
      tripId: tripId,
      message: message,
    );
  }
}