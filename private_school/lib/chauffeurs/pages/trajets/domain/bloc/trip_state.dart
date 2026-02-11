import 'package:private_school/chauffeurs/pages/trajets/data/models/trip_model.dart';


/// Base state for trip management
abstract class TripState {}

/// Initial state
class TripInitial extends TripState {}

/// Loading state - shown when fetching trips
class TripLoading extends TripState {}

/// Creating state - shown when creating a new trip
class TripCreating extends TripState {}

/// Trips loaded successfully
class TripsLoaded extends TripState {
  final List<TripModel> trips;

  TripsLoaded({required this.trips});
}

/// Trip created successfully
class TripCreated extends TripState {}

/// Trip started successfully
class TripStarted extends TripState {}

/// Trip completed successfully  
class TripCompleted extends TripState {}

/// Trip canceled successfully
class TripCanceled extends TripState {}

/// Error state
class TripError extends TripState {
  final String message;

  TripError(this.message);
}