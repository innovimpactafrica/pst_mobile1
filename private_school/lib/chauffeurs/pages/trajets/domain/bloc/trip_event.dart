abstract class TripEvent {}

class LoadTripsEvent extends TripEvent {}

class CreateTripEvent extends TripEvent {
  final String startPoint;
  final String endPoint;
  final DateTime departureTime;
  final int capacityMax;
  final int schoolId;
  final bool isRecurring;

  CreateTripEvent({
    required this.startPoint,
    required this.endPoint,
    required this.departureTime,
    required this.capacityMax,
    required this.schoolId,
    this.isRecurring = false,
  });
}

class StartTripEvent extends TripEvent {
  final String tripId;

  StartTripEvent(this.tripId);
}

class CompleteTripEvent extends TripEvent {
  final String tripId;

  CompleteTripEvent(this.tripId);
}

class CancelTripEvent extends TripEvent {
  final String tripId;
  final String reason;

  CancelTripEvent({
    required this.tripId,
    required this.reason,
  });
}

class RefreshTripsEvent extends TripEvent {}