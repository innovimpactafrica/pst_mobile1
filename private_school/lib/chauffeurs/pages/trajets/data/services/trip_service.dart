
import '../../../../../core/network/api_client.dart';
import '../../../../../core/utils/api_constants.dart';
import '../models/trip_model.dart';


class TripService {
  final ApiClient _apiClient = ApiClient();

Future<List<TripModel>> getDriverTrips() async {
  try {
    
    final response = await _apiClient.get(ApiConstants.driverTrips);

    List<dynamic> tripsJson = [];

    if (response.data is Map<String, dynamic>) {
      final map = response.data as Map<String, dynamic>;
      if (map.containsKey('data') && map['data'] is List) {
        tripsJson = map['data'] as List;
      } else if (map.containsKey('trips') && map['trips'] is List) {
        tripsJson = map['trips'] as List;
      }
    } else if (response.data is List) {
      tripsJson = response.data as List;
    }

    for (int i = 0; i < tripsJson.length; i++) {
      final raw = tripsJson[i] as Map<String, dynamic>;
    }
    

    final trips = tripsJson
        .map((json) => TripModel.fromJson(json as Map<String, dynamic>))
        .toList();

   
    for (int i = 0; i < trips.length; i++) {
 
      for (var school in trips[i].schools) {
       
      }
      for (var p in trips[i].passengers) {
        
      }
    }

    // Filtrer les trajets passés
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final filteredTrips = trips.where((trip) {
      final tripDate = DateTime(trip.date.year, trip.date.month, trip.date.day);
      return !tripDate.isBefore(today);
    }).toList();

    return filteredTrips;
  } catch (e, stackTrace) {

    rethrow;
  }
}

 
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
  
   final requestBody = {
  'start_point': startPoint,
  'end_point': endPoint,
  if (departureTime != null) 'departure_time': departureTime.toIso8601String(),
  if (returnTime != null) 'return_departure_time': returnTime.toIso8601String(),
  'capacity_max': capacityMax,
  'is_recurring': isRecurring,
  if (startLatitude != null) 'start_latitude': startLatitude,
  if (startLongitude != null) 'start_longitude': startLongitude,
  if (endLatitude != null) 'end_latitude': endLatitude,
  if (endLongitude != null) 'end_longitude': endLongitude,
  

  if (schoolIds.length == 1)
    'school_id': schoolIds.first
  else
    'stops': schoolIds.asMap().entries.map((entry) => {
      'school_id': entry.value,
      'stop_order': entry.key + 1,
    }).toList(),
};


    for (int i = 0; i < schoolIds.length; i++) {
    
    }
    
    if (departureTime != null) ;
    if (returnTime != null) ;


    final response = await _apiClient.post(
      ApiConstants.driverTrips,
      data: requestBody,
    );

    final responseData = response.data;
    if (responseData is Map) {
      final data = responseData['data'];
      if (data is Map) {
        
        data.forEach((key, value) {
         
        });
       
      } else {
        
      }
    }
    

    return response.data as Map<String, dynamic>;
  } catch (e, stackTrace) {
    
    rethrow;
  }
}


  Future<Map<String, dynamic>> startTrip(String tripId, {String? direction}) async {
    try {
      
      String url = ApiConstants.driverTripStart(tripId);
      if (direction != null) {
        url += '?direction=$direction';
      }
      
      final response = await _apiClient.put(url);
      
      
      return response.data as Map<String, dynamic>;
    } catch (e) {
     
      if (e.toString().contains('400')) {
       
        throw Exception('Impossible de démarrer: aucun passager inscrit');
      }
      rethrow;
    }
  }

 
  Future<Map<String, dynamic>> completeTrip(String tripId, {String? direction}) async {
    try {
     
      String url = ApiConstants.driverTripCompleted(tripId);
      if (direction != null) {
        url += '?direction=$direction';
      }
      
      final response = await _apiClient.put(url);
      
      
      return response.data as Map<String, dynamic>;
    } catch (e) {
      
      rethrow;
    }
  }

 
  Future<Map<String, dynamic>> cancelTrip(String tripId, String reason) async {
    try {
    
      final response = await _apiClient.put(
        ApiConstants.driverTripCanceled(tripId),
        data: {'reason': reason},
      );
      
      
      return response.data as Map<String, dynamic>;
    } catch (e) {
    
      rethrow;
    }
  }
}