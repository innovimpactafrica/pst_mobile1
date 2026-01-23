import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:private_school/parents/pages/trajets/data/repositories/trip_repository.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final TripRepository repository; // CHANGEMENT : TripRepository

  HomeBloc({required this.repository}) : super(HomeInitial()) {
    on<LoadDriversEvent>(_onLoadDrivers);
  }

  Future<void> _onLoadDrivers(
      LoadDriversEvent event,
      Emitter<HomeState> emit,
      ) async {
    emit(HomeLoading());

    try {
      // CHANGEMENT : Charger les trips
      final trips = await repository.getAllTrips();

      emit(HomeLoaded(trips: trips));
    } catch (e) {
      emit(HomeError(message: 'Erreur: ${e.toString()}'));
    }
  }
}