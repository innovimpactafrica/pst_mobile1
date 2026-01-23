import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/child_model.dart';
import '../../data/repositories/child_repository.dart';
import 'child_event.dart';
import 'child_state.dart';

/// BLoC for managing children state
class ChildBloc extends Bloc<ChildEvent, ChildState> {
  final ChildRepository _repository;

  ChildBloc({ChildRepository? repository})
      : _repository = repository ?? ChildRepository(),
        super(const ChildInitialState()) {
    on<LoadChildrenEvent>(_onLoadChildren);
    on<AddChildEvent>(_onAddChild);
    on<UpdateChildEvent>(_onUpdateChild);
    on<DeleteChildEvent>(_onDeleteChild);
    on<SearchChildrenEvent>(_onSearchChildren);
    on<UpdateChildScheduleEvent>(_onUpdateChildSchedule);
  }

  /// Handle loading children
  Future<void> _onLoadChildren(
      LoadChildrenEvent event,
      Emitter<ChildState> emit,
      ) async {
    emit(const ChildLoadingState());

    try {
      final children = await _repository.getChildren();
      emit(ChildLoadedState(
        children: children,
        filteredChildren: children,
      ));
    } catch (e) {
      emit(ChildErrorState(error: e.toString()));
    }
  }

  /// Handle adding a child
  Future<void> _onAddChild(
      AddChildEvent event,
      Emitter<ChildState> emit,
      ) async {
    final currentState = state;
    final currentChildren = currentState is ChildLoadedState
        ? currentState.children
        : <ChildModel>[];

    emit(ChildActionInProgressState(currentChildren));

    try {
      final newChild = await _repository.addChild(event.child);
      final updatedChildren = [...currentChildren, newChild];

      emit(ChildActionSuccessState(
        message: 'Enfant ajouté avec succès',
        children: updatedChildren,
      ));

      emit(ChildLoadedState(
        children: updatedChildren,
        filteredChildren: updatedChildren,
      ));
    } catch (e) {
      emit(ChildErrorState(
        error: e.toString(),
        children: currentChildren,
      ));

      if (currentChildren.isNotEmpty) {
        emit(ChildLoadedState(
          children: currentChildren,
          filteredChildren: currentChildren,
        ));
      }
    }
  }

  /// Handle updating a child
  Future<void> _onUpdateChild(
      UpdateChildEvent event,
      Emitter<ChildState> emit,
      ) async {
    final currentState = state;
    final currentChildren = currentState is ChildLoadedState
        ? currentState.children
        : <ChildModel>[];

    emit(ChildActionInProgressState(currentChildren));

    try {
      final updatedChild = await _repository.modifyChild(event.child);
      final updatedChildren = currentChildren
          .map((child) => child.id == updatedChild.id ? updatedChild : child)
          .toList();

      emit(ChildActionSuccessState(
        message: 'Enfant mis à jour avec succès',
        children: updatedChildren,
      ));

      emit(ChildLoadedState(
        children: updatedChildren,
        filteredChildren: updatedChildren,
      ));
    } catch (e) {
      emit(ChildErrorState(
        error: e.toString(),
        children: currentChildren,
      ));

      if (currentChildren.isNotEmpty) {
        emit(ChildLoadedState(
          children: currentChildren,
          filteredChildren: currentChildren,
        ));
      }
    }
  }

  /// Handle deleting a child
  Future<void> _onDeleteChild(
      DeleteChildEvent event,
      Emitter<ChildState> emit,
      ) async {
    // ✅ CORRECTION : Vérifier que childId n'est pas null
    if (event.childId == null) {
      emit(const ChildErrorState(error: 'ID de l\'enfant manquant'));
      return;
    }

    final currentState = state;
    final currentChildren = currentState is ChildLoadedState
        ? currentState.children
        : <ChildModel>[];

    emit(ChildActionInProgressState(currentChildren));

    try {
      // ✅ Utiliser event.childId! car on a vérifié qu'il n'est pas null
      await _repository.removeChild(event.childId!);
      final updatedChildren =
      currentChildren.where((child) => child.id != event.childId).toList();

      emit(ChildActionSuccessState(
        message: 'Enfant supprimé avec succès',
        children: updatedChildren,
      ));

      emit(ChildLoadedState(
        children: updatedChildren,
        filteredChildren: updatedChildren,
      ));
    } catch (e) {
      emit(ChildErrorState(
        error: e.toString(),
        children: currentChildren,
      ));

      if (currentChildren.isNotEmpty) {
        emit(ChildLoadedState(
          children: currentChildren,
          filteredChildren: currentChildren,
        ));
      }
    }
  }

  /// Handle searching children
  void _onSearchChildren(
      SearchChildrenEvent event,
      Emitter<ChildState> emit,
      ) {
    final currentState = state;
    if (currentState is! ChildLoadedState) return;

    final query = event.query.toLowerCase();
    final filteredChildren = currentState.children.where((child) {
      final fullName = child.fullName.toLowerCase();
      final firstName = child.firstName.toLowerCase();
      final lastName = child.lastName.toLowerCase();

      return fullName.contains(query) ||
          firstName.contains(query) ||
          lastName.contains(query);
    }).toList();

    emit(currentState.copyWith(
      filteredChildren: filteredChildren,
      searchQuery: event.query,
    ));
  }

  /// Handle updating child schedule
  Future<void> _onUpdateChildSchedule(
      UpdateChildScheduleEvent event,
      Emitter<ChildState> emit,
      ) async {
    // ✅ CORRECTION : Vérifier que childId n'est pas null
    if (event.childId == null) {
      emit(const ChildErrorState(error: 'ID de l\'enfant manquant'));
      return;
    }

    final currentState = state;
    final currentChildren = currentState is ChildLoadedState
        ? currentState.children
        : <ChildModel>[];

    emit(ChildActionInProgressState(currentChildren));

    try {
      // ✅ Utiliser event.childId! car on a vérifié qu'il n'est pas null
      final childToUpdate = currentChildren.firstWhere(
            (c) => c.id == event.childId,
      );
      final updatedChild = childToUpdate.copyWith(
        schedule: event.schedule,
      );

      final updatedChildren = currentChildren
          .map((child) => child.id == updatedChild.id ? updatedChild : child)
          .toList();

      emit(ChildActionSuccessState(
        message: 'Horaires mis à jour avec succès',
        children: updatedChildren,
      ));

      emit(ChildLoadedState(
        children: updatedChildren,
        filteredChildren: updatedChildren,
      ));
    } catch (e) {
      emit(ChildErrorState(
        error: e.toString(),
        children: currentChildren,
      ));

      if (currentChildren.isNotEmpty) {
        emit(ChildLoadedState(
          children: currentChildren,
          filteredChildren: currentChildren,
        ));
      }
    }
  }
}