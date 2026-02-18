abstract class IncidentEvent {}

class LoadIncidentsEvent extends IncidentEvent {}

class CreateIncidentEvent extends IncidentEvent {
  final String title;
  final String description;
  final String category;
  final String? imageUrl;

  CreateIncidentEvent({
    required this.title,
    required this.description,
    required this.category,
    this.imageUrl,
  });
}
