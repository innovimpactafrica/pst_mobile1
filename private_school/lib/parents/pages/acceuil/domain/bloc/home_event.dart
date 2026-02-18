import 'package:private_school/parents/pages/acceuil/presentation/widgets/trip_filter_modal.dart';

abstract class HomeEvent {}

class LoadDriversEvent extends HomeEvent {}

class SearchTripsEvent extends HomeEvent {
  final String query;
  SearchTripsEvent(this.query);
}

class FilterTripsEvent extends HomeEvent {
  final TripFilters filters;
  FilterTripsEvent(this.filters);
}

class ClearHomeCache extends HomeEvent {}