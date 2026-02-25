import 'package:private_school/chauffeurs/pages/trajets/data/models/trip_model.dart';



abstract class TripState {}

class TripInitial extends TripState {}


class TripLoading extends TripState {}


class TripCreating extends TripState {}


class TripsLoaded extends TripState {
  final List<TripModel> trips;

  TripsLoaded({required this.trips});
}


class TripCreated extends TripState {}


class TripStarted extends TripState {}

 
class TripCompleted extends TripState {}


class TripCanceled extends TripState {}


class TripError extends TripState {
  final String message;

  TripError(this.message);
}