import 'package:flutter/material.dart';
import '../services/trip_service.dart';
import '../models/trip_model.dart';

class TripRepository {
  final TripService _service = TripService();

  /// Récupère les trajets disponibles (pas encore réservés)
  Future<List<TripModel>> getAvailableTrips() async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint(' [TripRepository] GET AVAILABLE TRIPS');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final trips = await _service.getAllTrips();

      debugPrint(' [TripRepository] ${trips.length} trajets disponibles');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      return trips;
    } catch (e, stackTrace) {
      debugPrint('');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint(' [TripRepository] ERROR');
      debugPrint('Error: $e');
      debugPrint('Stack: $stackTrace');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      rethrow;
    }
  }

  /// Récupère les trajets déjà réservés par le parent
  Future<List<TripModel>> getMyReservations() async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint(' [TripRepository] GET MY RESERVATIONS');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final reservations = await _service.getMyReservations();

      debugPrint(' [TripRepository] ${reservations.length} réservations');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      return reservations;
    } catch (e, stackTrace) {
      debugPrint('');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint(' [TripRepository] ERROR');
      debugPrint('Error: $e');
      debugPrint('Stack: $stackTrace');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      rethrow;
    }
  }

  /// Réserver un trajet pour un ou plusieurs enfants
  Future<Map<String, dynamic>> reserveTrip({
    required String tripId,
    required List<String> childIds,
  }) async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint(' [TripRepository] RESERVE TRIP');
      debugPrint('   Trip: $tripId');
      debugPrint('   Children: ${childIds.length}');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final result = await _service.reserveTripForMultipleChildren(
        tripId: tripId,
        childIds: childIds,
      );

      debugPrint(' [TripRepository] Reservation successful');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      return result;
    } catch (e, stackTrace) {
      debugPrint('');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint(' [TripRepository] RESERVATION ERROR');
      debugPrint('Error: $e');
      debugPrint('Stack: $stackTrace');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      rethrow;
    }
  }

  /// Annuler une réservation
  Future<void> cancelReservation({
    required String tripId,
    required String childId,
  }) async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint(' [TripRepository] CANCEL RESERVATION');
      debugPrint('   Trip: $tripId');
      debugPrint('   Child: $childId');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      await _service.cancelReservation(tripId: tripId, childId: childId);

      debugPrint(' [TripRepository] Cancellation successful');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
    } catch (e, stackTrace) {
      debugPrint('');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint(' [TripRepository] CANCEL ERROR');
      debugPrint('Error: $e');
      debugPrint('Stack: $stackTrace');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      rethrow;
    }
  }

  /// Rechercher des trajets
  Future<List<TripModel>> searchTrips({
    String? homeAddress,
    String? schoolAddress,
    String? departureTime,
    String? childId,
  }) async {
    return await _service.searchTrips(
      homeAddress: homeAddress,
      schoolAddress: schoolAddress,
      departureTime: departureTime,
      childId: childId,
    );
  }

  /// Obtenir les détails d'un trajet
  Future<TripModel> getTripDetails(String tripId) async {
    return await _service.getTripDetails(tripId);
  }

  /// Suivre un trajet en temps réel
  Future<Map<String, dynamic>> trackTripRealtime(String tripId) async {
    return await _service.trackTripRealtime(tripId);
  }

  /// Contacter le chauffeur
  Future<Map<String, dynamic>> contactDriver({
    required String tripId,
    required String message,
  }) async {
    return await _service.contactDriver(tripId: tripId, message: message);
  }

  /// Obtenir les options de filtres disponibles
  Future<Map<String, dynamic>> getFilterOptions() async {
    return await _service.getFilterOptions();
  }
}
