import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:private_school/parents/pages/trajets/data/repositories/trip_repository.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final TripRepository repository;
  
  // ✅ Cache des IDs des trajets réservés
  Set<String> _reservedTripIds = {};

  HomeBloc({required this.repository}) : super(HomeInitial()) {
    on<LoadDriversEvent>(_onLoadDrivers);
    on<ClearHomeCache>(_onClearCache);
  }

  /// ✅ MODIFIÉ : Charger TOUS les trajets + Trier (réservés en premier)
  Future<void> _onLoadDrivers(
    LoadDriversEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🏠 [HomeBloc] LOAD ALL TRIPS FOR HOME PAGE');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      // 1️⃣ Charger TOUS les trajets disponibles
      final allTrips = await repository.getAvailableTrips();
      
      debugPrint('📊 Total trajets API: ${allTrips.length}');

      // 2️⃣ Charger les réservations pour construire le cache
      try {
        final reservations = await repository.getMyReservations();
        _reservedTripIds = reservations.map((trip) => trip.id).toSet();
        
        debugPrint('🔖 Trajets réservés: ${_reservedTripIds.length}');
        if (_reservedTripIds.isNotEmpty) {
          debugPrint('   IDs réservés: $_reservedTripIds');
        }
      } catch (e) {
        debugPrint('⚠️ Impossible de charger les réservations: $e');
        _reservedTripIds = {};
      }

      // 3️⃣ ✅ TRIER : Trajets réservés EN PREMIER
      allTrips.sort((a, b) {
        final aReserved = _reservedTripIds.contains(a.id);
        final bReserved = _reservedTripIds.contains(b.id);
        
        // Si a est réservé et b non → a avant b
        if (aReserved && !bReserved) return -1;
        // Si b est réservé et a non → b avant a
        if (!aReserved && bReserved) return 1;
        // Sinon même priorité
        return 0;
      });

      debugPrint('');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('✅ RÉSULTAT TRI (HOME):');
      debugPrint('   Total trajets: ${allTrips.length}');
      debugPrint('   Réservés (en premier): ${_reservedTripIds.length}');
      debugPrint('');
      
      // Afficher les 3 premiers pour debug
      for (var i = 0; i < (allTrips.length > 3 ? 3 : allTrips.length); i++) {
        final trip = allTrips[i];
        final isReserved = _reservedTripIds.contains(trip.id);
        debugPrint('   ${i + 1}. ${isReserved ? "🔖 RÉSERVÉ" : "⭕ Disponible"} - ID ${trip.id} - ${trip.destination}');
      }
      
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      emit(HomeLoaded(trips: allTrips));
    } catch (e) {
      debugPrint('');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('❌ [HomeBloc] ERROR LOADING TRIPS');
      debugPrint('Error: $e');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      
      emit(HomeError(message: 'Erreur: ${e.toString()}'));
    }
  }

  /// ✅ Vérifier si un trajet est réservé
  bool isTripReserved(String tripId) {
    final isReserved = _reservedTripIds.contains(tripId);
    
    debugPrint('🔍 [HomeBloc] Vérification réservation:');
    debugPrint('   Trip ID: $tripId');
    debugPrint('   Est réservé: $isReserved');
    
    return isReserved;
  }

  /// ✅ Obtenir les IDs réservés (pour debug)
  Set<String> get reservedTripIds => _reservedTripIds;

  /// Vider le cache
  void _onClearCache(ClearHomeCache event, Emitter<HomeState> emit) {
    debugPrint('🧹 [HomeBloc] Clearing home cache');
    _reservedTripIds = {};
    emit(HomeInitial());
  }
}