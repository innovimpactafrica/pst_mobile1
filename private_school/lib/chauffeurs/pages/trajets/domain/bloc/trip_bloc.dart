
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
     
      final trips = await repository.getDriverTrips();
      
      
      emit(TripsLoaded(trips: trips));
    } catch (e) {
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
      
      if (event.departureTime != null) ;
      if (event.returnTime != null) ;
  
      
      await repository.createTrip(
        startPoint: event.startPoint,
        endPoint: event.endPoint,
        departureTime: event.departureTime,
        returnTime: event.returnTime,
        capacityMax: event.capacityMax,
        schoolIds: event.schoolIds,
        isRecurring: event.isRecurring,
        startLatitude: event.startLatitude,
        startLongitude: event.startLongitude,
        endLatitude: event.endLatitude,
        endLongitude: event.endLongitude,
      );
      
   
      
      emit(TripCreated());
      
      // Recharger la liste des trajets
      add(LoadTripsEvent());
    } catch (e) {
    
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
      
      await repository.startTrip(event.tripId, direction: event.direction);
     
      emit(TripStarted());
      
      // Recharger les trajets
      add(LoadTripsEvent());
    } catch (e) {
      
      emit(TripError('Erreur lors du démarrage du trajet'));
    }
  }

  /// Complete a trip
  Future<void> _onCompleteTrip(
    CompleteTripEvent event,
    Emitter<TripState> emit,
  ) async {
    try {
      
      await repository.completeTrip(event.tripId, direction: event.direction);
     
      emit(TripCompleted());
      
      // Recharger les trajets
      add(LoadTripsEvent());
    } catch (e) {
     
      emit(TripError('Erreur lors de la finalisation du trajet'));
    }
  }

  /// Cancel a trip
  Future<void> _onCancelTrip(
    CancelTripEvent event,
    Emitter<TripState> emit,
  ) async {
    try {
     
      await repository.cancelTrip(event.tripId, event.reason);
     
      emit(TripCanceled());
      
      // Recharger les trajets
      add(LoadTripsEvent());
    } catch (e) {
      
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