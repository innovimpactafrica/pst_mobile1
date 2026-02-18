import 'package:flutter_bloc/flutter_bloc.dart';
//import '../../data/models/incident_model.dart';
import '../../data/services/incident_service.dart';
import 'incident_event.dart';
import 'incident_state.dart';

class IncidentBloc extends Bloc<IncidentEvent, IncidentState> {
  final IncidentService _incidentService;

  IncidentBloc(this._incidentService) : super(IncidentInitial()) {
    on<LoadIncidentsEvent>(_onLoadIncidents);
    on<CreateIncidentEvent>(_onCreateIncident);
  }

  Future<void> _onLoadIncidents(
    LoadIncidentsEvent event,
    Emitter<IncidentState> emit,
  ) async {
    emit(IncidentLoading());
    try {
      final incidents = await _incidentService.fetchIncidents();
      emit(IncidentsLoaded(incidents));
    } catch (e) {
      emit(IncidentError(e.toString()));
    }
  }

  Future<void> _onCreateIncident(
    CreateIncidentEvent event,
    Emitter<IncidentState> emit,
  ) async {
    try {
      await _incidentService.createIncident(
        title: event.title,
        description: event.description,
        category: event.category,
        imageUrl: event.imageUrl,
      );
      add(LoadIncidentsEvent());
    } catch (e) {
      emit(IncidentError(e.toString()));
    }
  }
}
