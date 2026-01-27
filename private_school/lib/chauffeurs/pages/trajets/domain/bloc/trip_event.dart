

abstract class TripEvent {}

class LoadTripsEvent extends TripEvent {}

class CreateTripEvent extends TripEvent {
  final String destination;
  final String? startLocation;
  final DateTime date;
  final String time;
  final int totalSeats;
  final double? price;

  CreateTripEvent({
    required this.destination,
    this.startLocation,
    required this.date,
    required this.time,
    required this.totalSeats,
    this.price,
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