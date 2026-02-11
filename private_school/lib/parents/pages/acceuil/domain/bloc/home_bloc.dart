import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:private_school/parents/pages/trajets/data/repositories/trip_repository.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final TripRepository repository;
  
  // ✅ NOUVEAU : Cache des IDs des trajets réservés
  Set<String> _reservedTripIds = {};

  HomeBloc({required this.repository}) : super(HomeInitial()) {
    on<LoadDriversEvent>(_onLoadDrivers);
  }

  /// ✅ MODIFIÉ : Charger les trajets disponibles avec filtrage des réservés
  Future<void> _onLoadDrivers(
    LoadDriversEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🏠 [HomeBloc] LOAD TRIPS FOR HOME PAGE');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      // 1️⃣ Charger TOUS les trajets disponibles
      final allTrips = await repository.getAvailableTrips();
      
      debugPrint('📊 Total trajets API: ${allTrips.length}');

      // 2️⃣ Charger les réservations pour construire le cache
      try {
        final reservations = await repository.getMyReservations();
        _reservedTripIds = reservations.map((trip) => trip.id).toSet();
        
        debugPrint('🔖 Trajets déjà réservés: ${_reservedTripIds.length}');
        if (_reservedTripIds.isNotEmpty) {
          debugPrint('   IDs réservés: $_reservedTripIds');
        }
      } catch (e) {
        debugPrint('⚠️ Impossible de charger les réservations: $e');
        _reservedTripIds = {};
      }

      // 3️⃣ Filtrer pour exclure les trajets déjà réservés
      final availableTrips = allTrips.where((trip) {
        final isReserved = _reservedTripIds.contains(trip.id);
        
        if (isReserved) {
          debugPrint('   ⏭️ Exclu (réservé): ID ${trip.id} - ${trip.destination}');
        }
        
        return !isReserved; // Garder seulement les NON réservés
      }).toList();

      debugPrint('');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('✅ RÉSULTAT FILTRAGE (HOME):');
      debugPrint('   Total API: ${allTrips.length}');
      debugPrint('   Réservés: ${_reservedTripIds.length}');
      debugPrint('   Disponibles (après filtre): ${availableTrips.length}');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      emit(HomeLoaded(trips: availableTrips));
    } catch (e) {
      debugPrint('');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('❌ [HomeBloc] ERROR LOADING TRIPS');
      debugPrint('Error: $e');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      
      emit(HomeError(message: 'Erreur: ${e.toString()}'));
    }
  }

  /// ✅ NOUVEAU : Vérifier si un trajet est réservé
  bool isTripReserved(String tripId) {
    return _reservedTripIds.contains(tripId);
  }

  /// ✅ NOUVEAU : Obtenir les IDs réservés (pour debug)
  Set<String> get reservedTripIds => _reservedTripIds;
}