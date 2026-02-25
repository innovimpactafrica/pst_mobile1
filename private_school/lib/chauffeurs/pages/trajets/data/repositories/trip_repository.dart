
import '../services/trip_service.dart';
import '../models/trip_model.dart';


class TripRepository {
  final TripService _tripService = TripService();

 
  Future<List<TripModel>> getDriverTrips() async {
    try {
      
      return await _tripService.getDriverTrips();
    } catch (e) {
   
      rethrow;
    }
  }

  /// Create a new trip
  Future<Map<String, dynamic>> createTrip({
    required String startPoint,
    required String endPoint,
    DateTime? departureTime,
    DateTime? returnTime,
    required int capacityMax,
    required List<int> schoolIds,
    required bool isRecurring,
    double? startLatitude,
    double? startLongitude,
    double? endLatitude,
    double? endLongitude,
  }) async {
    try {
      
      
      return await _tripService.createTrip(
        startPoint: startPoint,
        endPoint: endPoint,
        departureTime: departureTime,
        returnTime: returnTime,
        capacityMax: capacityMax,
        schoolIds: schoolIds,
        isRecurring: isRecurring,
        startLatitude: startLatitude,
        startLongitude: startLongitude,
        endLatitude: endLatitude,
        endLongitude: endLongitude,
      );
    } catch (e) {
      
      rethrow;
    }
  }

  /// Start a trip
  Future<Map<String, dynamic>> startTrip(String tripId, {String? direction}) async {
    try {
      
      return await _tripService.startTrip(tripId, direction: direction);
    } catch (e) {
      
      rethrow;
    }
  }

  /// Complete a trip
  Future<Map<String, dynamic>> completeTrip(String tripId, {String? direction}) async {
    try {
   
      return await _tripService.completeTrip(tripId, direction: direction);
    } catch (e) {
     
      rethrow;
    }
  }

  /// Cancel a trip
  Future<Map<String, dynamic>> cancelTrip(String tripId, String reason) async {
    try {
    
      return await _tripService.cancelTrip(tripId, reason);
    } catch (e) {
      
      rethrow;
    }
  }
}