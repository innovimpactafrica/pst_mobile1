import 'package:equatable/equatable.dart';
import 'package:private_school/chauffeur/pages/trajets/data/models/trip_model.dart';

abstract class HomeState extends Equatable {
  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<TripModel> trips; // CHANGEMENT : trips au lieu de drivers

  HomeLoaded({required this.trips});

  @override
  List<Object?> get props => [trips];
}

class HomeError extends HomeState {
  final String message;

  HomeError({required this.message});

  @override
  List<Object?> get props => [message];
}