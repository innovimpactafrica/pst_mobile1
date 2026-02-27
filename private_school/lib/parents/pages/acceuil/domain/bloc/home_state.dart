import 'package:equatable/equatable.dart';
import 'package:private_school/parents/pages/trajets/data/models/trip_model.dart';

abstract class HomeState extends Equatable {
  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<TripModel> trips;
  final List<TripModel> filteredTrips;
  final List<TripModel> reservations;
  final String searchQuery;

  HomeLoaded({
    required this.trips,
    List<TripModel>? filteredTrips,
    this.reservations = const [],
    this.searchQuery = '',
  }) : filteredTrips = filteredTrips ?? trips;

  @override
  List<Object?> get props => [trips, filteredTrips, reservations, searchQuery];
}

class HomeError extends HomeState {
  final String message;

  HomeError({required this.message});

  @override
  List<Object?> get props => [message];
}
