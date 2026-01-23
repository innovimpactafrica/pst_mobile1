abstract class TripEvent {}

class LoadAvailableTripsEvent extends TripEvent {}

class LoadMyReservationsEvent extends TripEvent {}

class SelectTripTabEvent extends TripEvent {
  final int tabIndex; // 0 = Disponibles, 1 = Mes réservations

  SelectTripTabEvent(this.tabIndex);
}