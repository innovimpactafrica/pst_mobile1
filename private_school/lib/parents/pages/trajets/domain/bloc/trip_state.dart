import 'package:equatable/equatable.dart';
import '../../data/models/trip_model.dart';

abstract class TripState extends Equatable {
  const TripState();

  @override
  List<Object?> get props => [];
}

/// État initial
class TripInitial extends TripState {}

/// Chargement en cours
class TripLoading extends TripState {}

/// ✅ Liste de trajets chargée (disponibles OU réservations)
class TripLoaded extends TripState {
  final List<TripModel> trips;
  final int selectedTabIndex; // 0 = Disponibles, 1 = Mes réservations

  const TripLoaded({
    required this.trips,
    this.selectedTabIndex = 0,
  });

  @override
  List<Object?> get props => [trips, selectedTabIndex];
}

/// ✅ Détails d'un trajet chargés
class TripDetailsLoaded extends TripState {
  final TripModel trip;

  const TripDetailsLoaded(this.trip);

  @override
  List<Object?> get props => [trip];
}

/// ✅ Suivi en temps réel actif
class TripRealtimeTracking extends TripState {
  final Map<String, dynamic> realtimeData;

  const TripRealtimeTracking(this.realtimeData);

  @override
  List<Object?> get props => [realtimeData];
}

/// ✅ Réservation en cours
class TripReserving extends TripState {}

/// ✅ Réservation réussie
class TripReserved extends TripState {
  final String message;

  const TripReserved({this.message = 'Réservation réussie'});

  @override
  List<Object?> get props => [message];
}

/// ✅ Annulation en cours
class TripCanceling extends TripState {}

/// ✅ Annulation réussie
class TripCanceled extends TripState {
  final String message;

  const TripCanceled({this.message = 'Annulation réussie'});

  @override
  List<Object?> get props => [message];
}

/// Erreur
class TripError extends TripState {
  final String message;

  const TripError(this.message);

  @override
  List<Object?> get props => [message];
}