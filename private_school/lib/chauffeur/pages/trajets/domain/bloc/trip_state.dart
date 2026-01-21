import '../../data/models/trip_model.dart';

abstract class TripState {}

class TripInitial extends TripState {}

class TripLoading extends TripState {}

class TripLoaded extends TripState {
  final List<TripModel> trips;
  final int selectedTabIndex;

  TripLoaded({
    required this.trips,
    this.selectedTabIndex = 0,
  });
}

class TripError extends TripState {
  final String message;

  TripError(this.message);
}