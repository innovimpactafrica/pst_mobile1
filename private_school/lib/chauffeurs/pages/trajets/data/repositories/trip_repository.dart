import 'package:flutter/material.dart';
import '../services/trip_service.dart';
import '../models/trip_model.dart';

/// Repository for managing driver trip data
class TripRepository {
  final TripService _tripService = TripService();

  /// Get all trips for the driver
  Future<List<TripModel>> getDriverTrips() async {
    try {
      debugPrint('🔍 [TripRepository] GET DRIVER TRIPS');
      return await _tripService.getDriverTrips();
    } catch (e) {
      debugPrint('❌ [TripRepository] Error: $e\n');
      rethrow;
    }
  }

  /// Create a new trip
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
      debugPrint('🟢 [TripRepository] CREATE TRIP');
      
      return await _tripService.createTrip(
        startPoint: startPoint,
        endPoint: endPoint,
        departureTime: departureTime,
        returnTime: returnTime,
        capacityMax: capacityMax,
        schoolId: schoolId,
        isRecurring: isRecurring,
        startLatitude: startLatitude,
        startLongitude: startLongitude,
        endLatitude: endLatitude,
        endLongitude: endLongitude,
      );
    } catch (e) {
      debugPrint('❌ [TripRepository] Error: $e\n');
      rethrow;
    }
  }

  /// Start a trip
  Future<Map<String, dynamic>> startTrip(String tripId, {String? direction}) async {
    try {
      debugPrint('🚀 [TripRepository] START TRIP: $tripId (${direction ?? "aller"})');
      return await _tripService.startTrip(tripId, direction: direction);
    } catch (e) {
      debugPrint('❌ [TripRepository] Error: $e\n');
      rethrow;
    }
  }

  /// Complete a trip
  Future<Map<String, dynamic>> completeTrip(String tripId, {String? direction}) async {
    try {
      debugPrint('✅ [TripRepository] COMPLETE TRIP: $tripId (${direction ?? "aller"})');
      return await _tripService.completeTrip(tripId, direction: direction);
    } catch (e) {
      debugPrint('❌ [TripRepository] Error: $e\n');
      rethrow;
    }
  }

  /// Cancel a trip
  Future<Map<String, dynamic>> cancelTrip(String tripId, String reason) async {
    try {
      debugPrint('🔴 [TripRepository] CANCEL TRIP: $tripId');
      return await _tripService.cancelTrip(tripId, reason);
    } catch (e) {
      debugPrint('❌ [TripRepository] Error: $e\n');
      rethrow;
    }
  }
}