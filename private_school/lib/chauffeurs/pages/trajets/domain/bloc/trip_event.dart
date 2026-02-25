abstract class TripEvent {}

class LoadTripsEvent extends TripEvent {}

class CreateTripEvent extends TripEvent {
  final String startPoint;
  final String endPoint;
  final DateTime? departureTime;
  final DateTime? returnTime;
  final int capacityMax;
  final List<int> schoolIds;
  final bool isRecurring;
  final double? startLatitude;
  final double? startLongitude;
  final double? endLatitude;
  final double? endLongitude;

  CreateTripEvent({
    required this.startPoint,
    required this.endPoint,
    this.departureTime,
    this.returnTime,
    required this.capacityMax,
    required this.schoolIds,
    this.isRecurring = false,
    this.startLatitude,
    this.startLongitude,
    this.endLatitude,
    this.endLongitude,
  });
}

class StartTripEvent extends TripEvent {
  final String tripId;
  final String? direction;
  StartTripEvent(this.tripId, {this.direction});
}

class CompleteTripEvent extends TripEvent {
  final String tripId;
  final String? direction;
  CompleteTripEvent(this.tripId, {this.direction});
}

class CancelTripEvent extends TripEvent {
  final String tripId;
  final String reason;

  CancelTripEvent({required this.tripId, required this.reason});
}

class LoadTripDetailEvent extends TripEvent {
  final String tripId;
  LoadTripDetailEvent(this.tripId);
}

class RefreshTripsEvent extends TripEvent {}
