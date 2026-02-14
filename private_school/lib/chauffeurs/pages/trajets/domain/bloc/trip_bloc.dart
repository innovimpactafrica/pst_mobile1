import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/trip_repository.dart';
import 'trip_event.dart';
import 'trip_state.dart';

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

  /// Load all trips for the driver
  Future<void> _onLoadTrips(
    LoadTripsEvent event,
    Emitter<TripState> emit,
  ) async {
    emit(TripLoading());
    
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🔵 [TripBloc] LOAD TRIPS');
      
      final trips = await repository.getDriverTrips();
      
      debugPrint('✅ ${trips.length} trip(s) loaded');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      
      emit(TripsLoaded(trips: trips));
    } catch (e) {
      debugPrint('❌ [TripBloc] Error: $e\n');
      emit(TripError('Erreur lors du chargement des trajets'));
    }
  }

  /// Create a new trip
  Future<void> _onCreateTrip(
    CreateTripEvent event,
    Emitter<TripState> emit,
  ) async {
    emit(TripCreating());
    
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🟢 [TripBloc] CREATE TRIP');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('📍 Start: ${event.startPoint}');
      debugPrint('🎯 End: ${event.endPoint}');
      debugPrint('🕐 Departure: ${event.departureTime}');
      debugPrint('🕐 Return: ${event.returnTime}');
      debugPrint('👥 Capacity: ${event.capacityMax}');
      debugPrint('🏫 School ID: ${event.schoolId}');
      debugPrint('🔄 Recurring: ${event.isRecurring}');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      
      await repository.createTrip(
        startPoint: event.startPoint,
        endPoint: event.endPoint,
        departureTime: event.departureTime,
        returnTime: event.returnTime,
        capacityMax: event.capacityMax,
        schoolId: event.schoolId,
        isRecurring: event.isRecurring,
        startLatitude: event.startLatitude,
        startLongitude: event.startLongitude,
        endLatitude: event.endLatitude,
        endLongitude: event.endLongitude,
      );
      
      debugPrint('✅ Trip created successfully');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      
      emit(TripCreated());
      
      // Recharger la liste des trajets
      add(LoadTripsEvent());
    } catch (e) {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('❌ [TripBloc] CREATE TRIP ERROR');
      debugPrint('Error: $e');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      
      String errorMessage = 'Erreur lors de la création du trajet';
      
      final errorStr = e.toString().toLowerCase();
      
      if (errorStr.contains('school_id') || errorStr.contains('école')) {
        errorMessage = 'École invalide ou non trouvée';
      } else if (errorStr.contains('capacity') || errorStr.contains('capacité')) {
        errorMessage = 'Capacité invalide';
      } else if (errorStr.contains('departure_time') || errorStr.contains('date')) {
        errorMessage = 'Date et heure invalides';
      } else if (errorStr.contains('unauthorized') || errorStr.contains('401')) {
        errorMessage = 'Non autorisé. Vous devez être approuvé pour créer des trajets';
      } else if (errorStr.contains('403') || errorStr.contains('forbidden')) {
        errorMessage = 'Accès refusé. Vérifiez vos permissions';
      } else if (errorStr.contains('500')) {
        errorMessage = 'Erreur serveur. Veuillez réessayer plus tard';
      }
      
      emit(TripError(errorMessage));
    }
  }

  /// Start a trip
  Future<void> _onStartTrip(
    StartTripEvent event,
    Emitter<TripState> emit,
  ) async {
    try {
      debugPrint('🚀 [TripBloc] START TRIP: ${event.tripId} (${event.direction ?? "aller"})');
      
      await repository.startTrip(event.tripId, direction: event.direction);
      
      debugPrint('✅ Trip started\n');
      
      emit(TripStarted());
      
      // Recharger les trajets
      add(LoadTripsEvent());
    } catch (e) {
      debugPrint('❌ [TripBloc] Error: $e\n');
      emit(TripError('Erreur lors du démarrage du trajet'));
    }
  }

  /// Complete a trip
  Future<void> _onCompleteTrip(
    CompleteTripEvent event,
    Emitter<TripState> emit,
  ) async {
    try {
      debugPrint('✅ [TripBloc] COMPLETE TRIP: ${event.tripId} (${event.direction ?? "aller"})');
      
      await repository.completeTrip(event.tripId, direction: event.direction);
      
      debugPrint('✅ Trip completed\n');
      
      emit(TripCompleted());
      
      // Recharger les trajets
      add(LoadTripsEvent());
    } catch (e) {
      debugPrint('❌ [TripBloc] Error: $e\n');
      emit(TripError('Erreur lors de la finalisation du trajet'));
    }
  }

  /// Cancel a trip
  Future<void> _onCancelTrip(
    CancelTripEvent event,
    Emitter<TripState> emit,
  ) async {
    try {
      debugPrint('🔴 [TripBloc] CANCEL TRIP: ${event.tripId}');
      debugPrint('Reason: ${event.reason}');
      
      await repository.cancelTrip(event.tripId, event.reason);
      
      debugPrint('✅ Trip canceled\n');
      
      emit(TripCanceled());
      
      // Recharger les trajets
      add(LoadTripsEvent());
    } catch (e) {
      debugPrint('❌ [TripBloc] Error: $e\n');
      emit(TripError('Erreur lors de l\'annulation du trajet'));
    }
  }

  /// Refresh trips
  Future<void> _onRefreshTrips(
    RefreshTripsEvent event,
    Emitter<TripState> emit,
  ) async {
    // Refresh is the same as load
    add(LoadTripsEvent());
  }
}