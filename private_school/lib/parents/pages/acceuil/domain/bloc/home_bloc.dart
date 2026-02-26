import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:private_school/parents/pages/trajets/data/models/trip_model.dart';
import 'package:private_school/parents/pages/trajets/data/repositories/trip_repository.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final TripRepository repository;
  Set<String> _reservedTripIds = {};

  HomeBloc({required this.repository}) : super(HomeInitial()) {
    on<LoadDriversEvent>(_onLoadDrivers);
    on<SearchTripsEvent>(_onSearchTrips);
    on<FilterTripsEvent>(_onFilterTrips);
    on<ClearHomeCache>(_onClearCache);
  }

  Future<void> _onLoadDrivers(
    LoadDriversEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint(' [HomeBloc] LOAD ALL TRIPS FOR HOME PAGE');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      //  Charger TOUS les trajets disponibles AVEC TIMEOUT
      final allTrips = await repository.getAvailableTrips().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          debugPrint('⏱️ [HomeBloc] TIMEOUT après 30s');
          throw Exception('Timeout: Impossible de charger les trajets');
        },
      );

      debugPrint('Total trajets API: ${allTrips.length}');

      //  Charger les réservations pour construire le cache
      try {
        final reservations = await repository.getMyReservations().timeout(
          const Duration(seconds: 10),
        );
        _reservedTripIds = reservations.map((trip) => trip.id).toSet();

        debugPrint(' Trajets réservés: ${_reservedTripIds.length}');
        if (_reservedTripIds.isNotEmpty) {
          debugPrint('   IDs réservés: $_reservedTripIds');
        }
      } catch (e) {
        debugPrint(' Impossible de charger les réservations: $e');
        _reservedTripIds = {};
      }

      // Trajets réservés EN PREMIER
      allTrips.sort((a, b) {
        final aReserved = _reservedTripIds.contains(a.id);
        final bReserved = _reservedTripIds.contains(b.id);

        if (aReserved && !bReserved) return -1;
        if (!aReserved && bReserved) return 1;
        return 0;
      });

      debugPrint('');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint(' RÉSULTAT TRI (HOME):');
      debugPrint('   Total trajets: ${allTrips.length}');
      debugPrint('   Réservés (en premier): ${_reservedTripIds.length}');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      // Récupérer les réservations complètes pour le state
List<TripModel> reservationsList = [];
try {
  reservationsList = await repository.getMyReservations();
} catch (e) {
  debugPrint('Erreur récupération réservations pour state: $e');
}

emit(HomeLoaded(
  trips: allTrips,
  reservations: reservationsList, 
));
    } catch (e, stackTrace) {
      debugPrint('');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint(' [HomeBloc] ERROR LOADING TRIPS');
      debugPrint('Error: $e');
      debugPrint('Stack: $stackTrace');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      emit(
        HomeError(
          message:
              'Impossible de charger les trajets.\nVérifiez votre connexion.',
        ),
      );
    }
  }

  ///  Vérifier si un trajet est réservé
  bool isTripReserved(String tripId) {
    final isReserved = _reservedTripIds.contains(tripId);

    debugPrint(' [HomeBloc] Vérification réservation:');
    debugPrint('   Trip ID: $tripId');
    debugPrint('   Est réservé: $isReserved');

    return isReserved;
  }

  ///  Obtenir les IDs réservés (pour debug)
  Set<String> get reservedTripIds => _reservedTripIds;

  /// Vider le cache
  void _onClearCache(ClearHomeCache event, Emitter<HomeState> emit) {
    debugPrint('🧹 [HomeBloc] Clearing home cache');
    _reservedTripIds = {};
    emit(HomeInitial());
  }

  void _onSearchTrips(SearchTripsEvent event, Emitter<HomeState> emit) {
    final currentState = state;
    if (currentState is! HomeLoaded) return;

    final query = event.query.toLowerCase().trim();

    if (query.isEmpty) {
      emit(HomeLoaded(trips: currentState.trips));
      return;
    }

    final filtered = currentState.trips.where((trip) {
      return trip.destination.toLowerCase().contains(query) ||
          trip.departure.toLowerCase().contains(query) ||
          trip.driverName?.toLowerCase().contains(query) == true;
    }).toList();

    emit(
      HomeLoaded(
        trips: currentState.trips,
        filteredTrips: filtered,
        searchQuery: query,
      ),
    );
  }

  void _onFilterTrips(FilterTripsEvent event, Emitter<HomeState> emit) {
    final currentState = state;
    if (currentState is! HomeLoaded) return;

    var filtered = currentState.trips;

    // Filtrer par heure de départ
    if (event.filters.departureTime != null) {
      filtered = filtered.where((trip) {
        final tripTime = _parseTime(trip.time);
        if (tripTime == null) return false;
        return tripTime.hour == event.filters.departureTime!.hour &&
            tripTime.minute == event.filters.departureTime!.minute;
      }).toList();
    }

    // Filtrer par destination
    if (event.filters.destination != null &&
        event.filters.destination!.isNotEmpty) {
      final dest = event.filters.destination!.toLowerCase();
      filtered = filtered.where((trip) {
        return trip.destination.toLowerCase().contains(dest);
      }).toList();
    }

    emit(
      HomeLoaded(
        trips: currentState.trips,
        filteredTrips: filtered,
        searchQuery: currentState.searchQuery,
      ),
    );
  }

  TimeOfDay? _parseTime(String timeStr) {
    try {
      final parts = timeStr.split(':');
      if (parts.length == 2) {
        return TimeOfDay(
          hour: int.parse(parts[0].trim()),
          minute: int.parse(parts[1].trim()),
        );
      }
    } catch (e) {
      debugPrint(' Erreur parsing time: $timeStr');
    }
    return null;
  }
}
