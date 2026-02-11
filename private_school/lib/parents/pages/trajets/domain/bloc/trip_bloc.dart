import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'trip_event.dart';
import 'trip_state.dart';
import '../../data/repositories/trip_repository.dart';

class TripBloc extends Bloc<TripEvent, TripState> {
  final TripRepository repository;

  // ✅ NOUVEAU : Cache des IDs des trajets réservés
  Set<String> _reservedTripIds = {};

  TripBloc({required this.repository}) : super(TripInitial()) {
    on<LoadAvailableTripsEvent>(_onLoadAvailableTrips);
    on<LoadMyReservationsEvent>(_onLoadMyReservations);
    on<ReserveTripEvent>(_onReserveTrip);
    on<CancelReservationEvent>(_onCancelReservation);
    on<SelectTripTabEvent>(_onSelectTab);
    on<SearchTripsEvent>(_onSearchTrips);
    on<RefreshTripsEvent>(_onRefreshTrips);
    on<LoadTripDetailsEvent>(_onLoadTripDetails);
    on<TrackTripRealtimeEvent>(_onTrackTripRealtime);
    on<ContactDriverEvent>(_onContactDriver);
  }

  /// ✅ MODIFIÉ : CHARGER LES TRAJETS DISPONIBLES (avec filtrage des réservés)
  Future<void> _onLoadAvailableTrips(
    LoadAvailableTripsEvent event,
    Emitter<TripState> emit,
  ) async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🔵 [TripBloc] LOAD AVAILABLE TRIPS');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      emit(TripLoading());
      
      // 1️⃣ Charger TOUS les trajets depuis l'API
      final allTrips = await repository.getAvailableTrips();
      
      debugPrint('📊 Total trajets API: ${allTrips.length}');

      // 2️⃣ Charger les réservations pour savoir quels trajets exclure
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
      debugPrint('✅ RÉSULTAT FILTRAGE:');
      debugPrint('   Total API: ${allTrips.length}');
      debugPrint('   Réservés: ${_reservedTripIds.length}');
      debugPrint('   Disponibles (après filtre): ${availableTrips.length}');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      
      debugPrint('✅ [TripBloc] ${availableTrips.length} trajets disponibles chargés');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      emit(TripLoaded(
        trips: availableTrips,
        selectedTabIndex: 0,
      ));
    } catch (e, stackTrace) {
      debugPrint('');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('❌ [TripBloc] ERROR LOADING AVAILABLE TRIPS');
      debugPrint('Error: $e');
      debugPrint('Stack: $stackTrace');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      
      emit(TripError('Erreur lors du chargement des trajets disponibles'));
    }
  }

  /// ✅ MODIFIÉ : CHARGER MES RÉSERVATIONS (avec mise à jour du cache)
  Future<void> _onLoadMyReservations(
    LoadMyReservationsEvent event,
    Emitter<TripState> emit,
  ) async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🔵 [TripBloc] LOAD MY RESERVATIONS');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      emit(TripLoading());
      
      final reservations = await repository.getMyReservations();

      // ✅ Mettre à jour le cache des IDs réservés
      _reservedTripIds = reservations.map((trip) => trip.id).toSet();
      
      debugPrint('✅ [TripBloc] ${reservations.length} réservations chargées');
      debugPrint('   Cache mis à jour: $_reservedTripIds');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      emit(TripLoaded(
        trips: reservations,
        selectedTabIndex: 1,
      ));
    } catch (e) {
      debugPrint('❌ [TripBloc] Error loading reservations: $e\n');
      emit(TripError('Erreur lors du chargement de vos réservations'));
    }
  }

  /// ✅ MODIFIÉ : RÉSERVER UN TRAJET (avec mise à jour du cache)
  Future<void> _onReserveTrip(
    ReserveTripEvent event,
    Emitter<TripState> emit,
  ) async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🟢 [TripBloc] RESERVE TRIP');
      debugPrint('   Trip ID: ${event.tripId}');
      debugPrint('   Children: ${event.childIds.length}');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      await repository.reserveTrip(
        tripId: event.tripId,
        childIds: event.childIds,
      );

      // ✅ Ajouter immédiatement au cache des réservés
      _reservedTripIds.add(event.tripId);

      debugPrint('✅ [TripBloc] Réservation réussie !');
      debugPrint('   Cache mis à jour: $_reservedTripIds');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      // Recharger les trajets disponibles (qui exclura maintenant ce trajet)
      add(LoadAvailableTripsEvent());
    } catch (e) {
      debugPrint('❌ [TripBloc] Reservation error: $e\n');
      emit(TripError('Erreur lors de la réservation'));
    }
  }

  /// ✅ MODIFIÉ : ANNULER UNE RÉSERVATION (avec mise à jour du cache)
  Future<void> _onCancelReservation(
    CancelReservationEvent event,
    Emitter<TripState> emit,
  ) async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🔴 [TripBloc] CANCEL RESERVATION');
      debugPrint('   Trip ID: ${event.tripId}');
      debugPrint('   Child ID: ${event.childId}');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      await repository.cancelReservation(
        tripId: event.tripId,
        childId: event.childId,
      );

      // ✅ Retirer du cache des réservés
      _reservedTripIds.remove(event.tripId);

      debugPrint('✅ [TripBloc] Annulation réussie');
      debugPrint('   Cache mis à jour: $_reservedTripIds');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      // Recharger les réservations
      add(LoadMyReservationsEvent());
    } catch (e) {
      debugPrint('❌ [TripBloc] Cancel error: $e\n');
      emit(TripError('Erreur lors de l\'annulation'));
    }
  }

  /// ✅ CHANGER D'ONGLET
  Future<void> _onSelectTab(
    SelectTripTabEvent event,
    Emitter<TripState> emit,
  ) async {
    debugPrint('🔄 [TripBloc] Changement onglet: ${event.tabIndex}');

    if (event.tabIndex == 0) {
      add(LoadAvailableTripsEvent());
    } else {
      add(LoadMyReservationsEvent());
    }
  }

  /// ✅ RECHERCHER DES TRAJETS
  Future<void> _onSearchTrips(
    SearchTripsEvent event,
    Emitter<TripState> emit,
  ) async {
    try {
      debugPrint('🔍 [TripBloc] SEARCH TRIPS');
      emit(TripLoading());
      
      final trips = await repository.searchTrips(
        homeAddress: event.homeAddress,
        schoolAddress: event.schoolAddress,
        departureTime: event.departureTime,
        childId: event.childId,
      );

      debugPrint('✅ [TripBloc] ${trips.length} résultats trouvés\n');

      emit(TripLoaded(
        trips: trips,
        selectedTabIndex: state is TripLoaded 
            ? (state as TripLoaded).selectedTabIndex 
            : 0,
      ));
    } catch (e) {
      debugPrint('❌ [TripBloc] Search error: $e\n');
      emit(TripError('Erreur lors de la recherche'));
    }
  }

  /// ✅ RAFRAÎCHIR
  Future<void> _onRefreshTrips(
    RefreshTripsEvent event,
    Emitter<TripState> emit,
  ) async {
    if (state is TripLoaded) {
      final currentState = state as TripLoaded;
      if (currentState.selectedTabIndex == 0) {
        add(LoadAvailableTripsEvent());
      } else {
        add(LoadMyReservationsEvent());
      }
    } else {
      add(LoadAvailableTripsEvent());
    }
  }

  /// ✅ CHARGER LES DÉTAILS D'UN TRAJET
  Future<void> _onLoadTripDetails(
    LoadTripDetailsEvent event,
    Emitter<TripState> emit,
  ) async {
    try {
      debugPrint('🔍 [TripBloc] LOAD TRIP DETAILS: ${event.tripId}');
      emit(TripLoading());
      
      final trip = await repository.getTripDetails(event.tripId);
      
      debugPrint('✅ [TripBloc] Trip details loaded\n');

      emit(TripDetailsLoaded(trip));
    } catch (e) {
      debugPrint('❌ [TripBloc] Details error: $e\n');
      emit(TripError('Erreur lors du chargement des détails'));
    }
  }

  /// ✅ SUIVRE UN TRAJET EN TEMPS RÉEL
  Future<void> _onTrackTripRealtime(
    TrackTripRealtimeEvent event,
    Emitter<TripState> emit,
  ) async {
    try {
      debugPrint('📍 [TripBloc] TRACK REALTIME: ${event.tripId}');
      
      final realtimeData = await repository.trackTripRealtime(event.tripId);
      
      debugPrint('✅ [TripBloc] Realtime data received\n');

      emit(TripRealtimeTracking(realtimeData));
    } catch (e) {
      debugPrint('❌ [TripBloc] Tracking error: $e\n');
      emit(TripError('Erreur lors du suivi en temps réel'));
    }
  }

  /// ✅ CONTACTER LE CHAUFFEUR
  Future<void> _onContactDriver(
    ContactDriverEvent event,
    Emitter<TripState> emit,
  ) async {
    try {
      debugPrint('💬 [TripBloc] CONTACT DRIVER: ${event.tripId}');
      
      await repository.contactDriver(
        tripId: event.tripId,
        message: event.message,
      );
      
      debugPrint('✅ [TripBloc] Message sent\n');
    } catch (e) {
      debugPrint('❌ [TripBloc] Contact error: $e\n');
      emit(TripError('Erreur lors de l\'envoi du message'));
    }
  }
}