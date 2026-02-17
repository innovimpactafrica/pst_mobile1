import 'package:equatable/equatable.dart';
import '../../data/models/child_model.dart';

/// Base class for all child events
abstract class ChildEvent extends Equatable {
  const ChildEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load all children
class LoadChildrenEvent extends ChildEvent {
  const LoadChildrenEvent();
}

/// Event to add a new child
class AddChildEvent extends ChildEvent {
  final ChildModel child;

  const AddChildEvent(this.child);

  @override
  List<Object?> get props => [child];
}

/// Event to update an existing child
class UpdateChildEvent extends ChildEvent {
  final ChildModel child;

  const UpdateChildEvent(this.child);

  @override
  List<Object?> get props => [child];
}

/// Event to delete a child
class DeleteChildEvent extends ChildEvent {
  final String? childId;


  const DeleteChildEvent(this.childId);

  @override
  List<Object?> get props => [childId];
}

/// Event to search children
class SearchChildrenEvent extends ChildEvent {
  final String query;

  const SearchChildrenEvent(this.query);

  @override
  List<Object?> get props => [query];
}

/// Event to update child schedule
class UpdateChildScheduleEvent extends ChildEvent {
  final String? childId;
  final Map<String, DaySchedule > schedule;

  const UpdateChildScheduleEvent({
    required this.childId,
    required this.schedule,
  });

  @override
  List<Object?> get props => [childId, schedule];
}

// Dans child_event.dart (AJOUTEZ ce nouveau event)
class ClearChildrenCacheEvent extends ChildEvent {
  const ClearChildrenCacheEvent();
  
  @override
  List<Object?> get props => [];
}