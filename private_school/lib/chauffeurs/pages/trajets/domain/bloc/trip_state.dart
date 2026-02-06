

import 'package:equatable/equatable.dart';
import '../../data/models/trip_model.dart';

abstract class TripState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TripInitial extends TripState {}

class TripLoading extends TripState {}

class TripsLoaded extends TripState {
  final List<TripModel> trips;

  TripsLoaded(this.trips);

  @override
  List<Object?> get props => [trips];
}

class TripCreating extends TripState {}

class TripCreated extends TripState {
  final TripModel trip;

  TripCreated(this.trip);

  @override
  List<Object?> get props => [trip];
}

class TripStarted extends TripState {
  final TripModel trip;

  TripStarted(this.trip);

  @override
  List<Object?> get props => [trip];
}

class TripCompleted extends TripState {
  final TripModel trip;

  TripCompleted(this.trip);

  @override
  List<Object?> get props => [trip];
}

class TripCanceled extends TripState {
  final String tripId;

  TripCanceled(this.tripId);

  @override
  List<Object?> get props => [tripId];
}

class TripLoaded extends TripState {
  final TripModel trip;

  TripLoaded(this.trip);

  @override
  List<Object?> get props => [trip];
}


class TripError extends TripState {
  final String message;

  TripError(this.message);

  @override
  List<Object?> get props => [message];
}