



import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:private_school/chauffeurs/pages/trajets/data/repositories/trip_repository.dart';
import 'package:private_school/chauffeurs/pages/trajets/domain/bloc/trip_event.dart';
import 'package:private_school/chauffeurs/pages/trajets/domain/bloc/trip_state.dart';

class TripBloc extends Bloc<TripEvent, TripState> {
  final TripRepository repository;

  TripBloc({required this.repository}) : super(TripInitial()) {
    on<LoadTripsEvent>(_onLoadTrips);
    on<CreateTripEvent>(_onCreateTrip);
    on<StartTripEvent>(_onStartTrip);
    on<CompleteTripEvent>(_onCompleteTrip);
    on<CancelTripEvent>(_onCancelTrip);
    on<RefreshTripsEvent>(_onRefreshTrips);
  }

  Future<void> _onLoadTrips(
    LoadTripsEvent event,
    Emitter<TripState> emit,
  ) async {
    emit(TripLoading());
    try {
      final trips = await repository.getTrips();
      emit(TripsLoaded(trips));
    } catch (e) {
      emit(TripError(e.toString()));
    }
  }

  Future<void> _onCreateTrip(
    CreateTripEvent event,
    Emitter<TripState> emit,
  ) async {
    emit(TripCreating());
    try {
      final trip = await repository.createTrip(
        destination: event.destination,
        startLocation: event.startLocation,
        date: event.date,
        time: event.time,
        totalSeats: event.totalSeats,
        price: event.price,
      );
      emit(TripCreated(trip));
      add(LoadTripsEvent());
    } catch (e) {
      emit(TripError(e.toString()));
    }
  }

  Future<void> _onStartTrip(
    StartTripEvent event,
    Emitter<TripState> emit,
  ) async {
    try {
      final trip = await repository.startTrip(event.tripId);
      emit(TripStarted(trip));
      add(LoadTripsEvent());
    } catch (e) {
      emit(TripError(e.toString()));
    }
  }

  Future<void> _onCompleteTrip(
    CompleteTripEvent event,
    Emitter<TripState> emit,
  ) async {
    try {
      final trip = await repository.completeTrip(event.tripId);
      emit(TripCompleted(trip));
      add(LoadTripsEvent());
    } catch (e) {
      emit(TripError(e.toString()));
    }
  }

  Future<void> _onCancelTrip(
    CancelTripEvent event,
    Emitter<TripState> emit,
  ) async {
    try {
      await repository.cancelTrip(event.tripId, event.reason);
      emit(TripCanceled(event.tripId));
      add(LoadTripsEvent());
    } catch (e) {
      emit(TripError(e.toString()));
    }
  }

  Future<void> _onRefreshTrips(
    RefreshTripsEvent event,
    Emitter<TripState> emit,
  ) async {
    try {
      final trips = await repository.getTrips();
      emit(TripsLoaded(trips));
    } catch (e) {
      emit(TripError(e.toString()));
    }
  }
}