import '../../data/models/incident_model.dart';

abstract class IncidentState {}

class IncidentInitial extends IncidentState {}

class IncidentLoading extends IncidentState {}

class IncidentsLoaded extends IncidentState {
  final List<IncidentModel> incidents;

  IncidentsLoaded(this.incidents);
}

class IncidentError extends IncidentState {
  final String message;

  IncidentError(this.message);
}
