import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/trip_repository.dart';
import 'trip_event.dart';
import 'trip_state.dart';

class TripBloc extends Bloc<TripEvent, TripState> {
  final TripRepository repository;

  TripBloc({required this.repository}) : super(TripInitial()) {
    on<LoadAvailableTripsEvent>(_onLoadAvailableTrips);
    on<LoadMyReservationsEvent>(_onLoadMyReservations);
    on<SelectTripTabEvent>(_onSelectTab);
  }

  Future<void> _onLoadAvailableTrips(
      LoadAvailableTripsEvent event,
      Emitter<TripState> emit,
      ) async {
    emit(TripLoading());
    try {
      final trips = await repository.getAvailableTrips();
      emit(TripLoaded(trips: trips, selectedTabIndex: 0));
    } catch (e) {
      emit(TripError('Erreur lors du chargement des trajets'));
    }
  }

  Future<void> _onLoadMyReservations(
      LoadMyReservationsEvent event,
      Emitter<TripState> emit,
      ) async {
    emit(TripLoading());
    try {
      final trips = await repository.getMyReservations();
      emit(TripLoaded(trips: trips, selectedTabIndex: 1));
    } catch (e) {
      emit(TripError('Erreur lors du chargement des réservations'));
    }
  }

  Future<void> _onSelectTab(
      SelectTripTabEvent event,
      Emitter<TripState> emit,
      ) async {
    emit(TripLoading());
    try {
      final trips = event.tabIndex == 0
          ? await repository.getAvailableTrips()
          : await repository.getMyReservations();
      emit(TripLoaded(trips: trips, selectedTabIndex: event.tabIndex));
    } catch (e) {
      emit(TripError('Erreur lors du changement d\'onglet'));
    }
  }
}