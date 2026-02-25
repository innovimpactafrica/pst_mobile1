import 'package:equatable/equatable.dart';

abstract class TripEvent extends Equatable {
  const TripEvent();

  @override
  List<Object?> get props => [];
}

///  Charger les trajets DISPONIBLES (pas encore réservés)
class LoadAvailableTripsEvent extends TripEvent {}

///  Charger MES RÉSERVATIONS (trajets déjà réservés)
class LoadMyReservationsEvent extends TripEvent {}

///  Réserver un trajet pour un ou plusieurs enfants
class ReserveTripEvent extends TripEvent {
  final String tripId;
  final List<String> childIds;

  const ReserveTripEvent({required this.tripId, required this.childIds});

  @override
  List<Object?> get props => [tripId, childIds];
}

///  Annuler une réservation
class CancelReservationEvent extends TripEvent {
  final String tripId;
  final String childId;

  const CancelReservationEvent({required this.tripId, required this.childId});

  @override
  List<Object?> get props => [tripId, childId];
}

/// Sélectionner un onglet (0 = Disponibles, 1 = Mes réservations)
class SelectTripTabEvent extends TripEvent {
  final int tabIndex;

  const SelectTripTabEvent(this.tabIndex);

  @override
  List<Object?> get props => [tabIndex];
}

/// Rechercher des trajets avec filtres
class SearchTripsEvent extends TripEvent {
  final String? homeAddress;
  final String? schoolAddress;
  final String? departureTime;
  final String? childId;

  const SearchTripsEvent({
    this.homeAddress,
    this.schoolAddress,
    this.departureTime,
    this.childId,
  });

  @override
  List<Object?> get props => [
    homeAddress,
    schoolAddress,
    departureTime,
    childId,
  ];
}

/// Rafraîchir les trajets
class RefreshTripsEvent extends TripEvent {}

/// Obtenir les détails d'un trajet
class LoadTripDetailsEvent extends TripEvent {
  final String tripId;

  const LoadTripDetailsEvent(this.tripId);

  @override
  List<Object?> get props => [tripId];
}

/// Suivre un trajet en temps réel
class TrackTripRealtimeEvent extends TripEvent {
  final String tripId;

  const TrackTripRealtimeEvent(this.tripId);

  @override
  List<Object?> get props => [tripId];
}

/// Contacter le chauffeur
class ContactDriverEvent extends TripEvent {
  final String tripId;
  final String message;

  const ContactDriverEvent({required this.tripId, required this.message});

  @override
  List<Object?> get props => [tripId, message];
}
