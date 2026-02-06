import 'package:flutter/foundation.dart';
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

  /// ✅ Handle loading children - CORRIGÉ
  Future<void> _onLoadChildren(
    LoadChildrenEvent event,
    Emitter<ChildState> emit,
  ) async {
    debugPrint('🔄 [ChildBloc] Loading children...');
    emit(const ChildLoadingState());

    try {
      final children = await _repository.getChildren();
      
      debugPrint('✅ [ChildBloc] ${children.length} enfant(s) chargé(s)');
      
      emit(ChildLoadedState(
        children: children,
        filteredChildren: children,
      ));
    } catch (e) {
      debugPrint('❌ [ChildBloc] Error loading children: $e');
      
      final currentState = state;

      emit(ChildErrorState(
        error: 'Erreur: ${e.toString()}',
        children: currentState is ChildLoadedState
            ? currentState.children
            : [],
      ));
    }
  }

  /// ✅ Handle adding a child - CORRIGÉ avec rechargement
  Future<void> _onAddChild(
    AddChildEvent event,
    Emitter<ChildState> emit,
  ) async {
    debugPrint('🔄 [ChildBloc] Adding child: ${event.child.name}');
    
    final currentState = state;
    final currentChildren = currentState is ChildLoadedState
        ? currentState.children
        : <ChildModel>[];

    emit(ChildActionInProgressState(currentChildren));

    try {
      // 1. Créer l'enfant via l'API
      final newChild = await _repository.addChild(event.child);
      
      debugPrint('✅ [ChildBloc] Child added successfully: ${newChild.name}');

      // 2. Afficher le message de succès
      emit(ChildActionSuccessState(
        message: 'Enfant ajouté avec succès',
        children: [...currentChildren, newChild],
      ));

      // 3. ✅ IMPORTANT : Recharger TOUS les enfants depuis l'API
      debugPrint('🔄 [ChildBloc] Reloading all children from API...');
      
      final updatedChildren = await _repository.getChildren();
      
      debugPrint('✅ [ChildBloc] Reloaded: ${updatedChildren.length} enfant(s)');

      // 4. Émettre le nouvel état avec les données fraîches
      emit(ChildLoadedState(
        children: updatedChildren,
        filteredChildren: updatedChildren,
      ));
    } catch (e) {
      debugPrint('❌ [ChildBloc] Error adding child: $e');
      
      emit(ChildErrorState(
        error: 'Erreur lors de l\'ajout: ${e.toString()}',
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

  /// ✅ Handle updating a child - CORRIGÉ avec rechargement
  Future<void> _onUpdateChild(
    UpdateChildEvent event,
    Emitter<ChildState> emit,
  ) async {
    debugPrint('🔄 [ChildBloc] Updating child: ${event.child.name}');
    
    final currentState = state;
    final currentChildren = currentState is ChildLoadedState
        ? currentState.children
        : <ChildModel>[];

    emit(ChildActionInProgressState(currentChildren));

    try {
      // 1. Mettre à jour l'enfant via l'API
      final updatedChild = await _repository.modifyChild(event.child);
      
      debugPrint('✅ [ChildBloc] Child updated successfully: ${updatedChild.name}');

      // 2. Afficher le message de succès
      emit(ChildActionSuccessState(
        message: 'Enfant mis à jour avec succès',
        children: currentChildren
            .map((child) => child.id == updatedChild.id ? updatedChild : child)
            .toList(),
      ));

      // 3. ✅ Recharger tous les enfants depuis l'API
      debugPrint('🔄 [ChildBloc] Reloading all children from API...');
      
      final updatedChildren = await _repository.getChildren();
      
      debugPrint('✅ [ChildBloc] Reloaded: ${updatedChildren.length} enfant(s)');

      emit(ChildLoadedState(
        children: updatedChildren,
        filteredChildren: updatedChildren,
      ));
    } catch (e) {
      debugPrint('❌ [ChildBloc] Error updating child: $e');
      
      emit(ChildErrorState(
        error: 'Erreur lors de la mise à jour: ${e.toString()}',
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

  /// ✅ Handle deleting a child - CORRIGÉ avec rechargement
  Future<void> _onDeleteChild(
    DeleteChildEvent event,
    Emitter<ChildState> emit,
  ) async {
    if (event.childId == null) {
      debugPrint('❌ [ChildBloc] Cannot delete: childId is null');
      emit(const ChildErrorState(error: 'ID de l\'enfant manquant'));
      return;
    }

    debugPrint('🔄 [ChildBloc] Deleting child ID: ${event.childId}');

    final currentState = state;
    final currentChildren = currentState is ChildLoadedState
        ? currentState.children
        : <ChildModel>[];

    emit(ChildActionInProgressState(currentChildren));

    try {
      // 1. Supprimer l'enfant via l'API
      await _repository.removeChild(event.childId!);
      
      debugPrint('✅ [ChildBloc] Child deleted successfully');

      // 2. Afficher le message de succès
      emit(ChildActionSuccessState(
        message: 'Enfant supprimé avec succès',
        children: currentChildren.where((child) => child.id != event.childId).toList(),
      ));

      // 3. ✅ Recharger tous les enfants depuis l'API
      debugPrint('🔄 [ChildBloc] Reloading all children from API...');
      
      final updatedChildren = await _repository.getChildren();
      
      debugPrint('✅ [ChildBloc] Reloaded: ${updatedChildren.length} enfant(s)');

      emit(ChildLoadedState(
        children: updatedChildren,
        filteredChildren: updatedChildren,
      ));
    } catch (e) {
      debugPrint('❌ [ChildBloc] Error deleting child: $e');
      
      emit(ChildErrorState(
        error: 'Erreur lors de la suppression: ${e.toString()}',
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

    debugPrint('🔍 [ChildBloc] Search query: "$query" → ${filteredChildren.length} résultat(s)');

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
  if (event.childId == null) {
    debugPrint('❌ [ChildBloc] Cannot update schedule: childId is null');
    emit(const ChildErrorState(error: 'ID de l\'enfant manquant'));
    return;
  }

  debugPrint('🔄 [ChildBloc] Updating schedule for child ID: ${event.childId}');
  debugPrint('📦 [ChildBloc] Schedule data: ${event.schedule}');

  final currentState = state;
  final currentChildren = currentState is ChildLoadedState
      ? currentState.children
      : <ChildModel>[];

  emit(ChildActionInProgressState(currentChildren));

  try {
    // 1. ✅ Mettre à jour les horaires via l'API
    await _repository.updateChildSchedule(event.childId!, event.schedule);
    
    debugPrint('✅ [ChildBloc] Schedule updated successfully via API');

    // 2. Afficher le message de succès
    emit(ChildActionSuccessState(
      message: 'Horaires mis à jour avec succès',
      children: currentChildren,
    ));

    // 3. ✅ Recharger tous les enfants depuis l'API pour avoir les données fraîches
    debugPrint('🔄 [ChildBloc] Reloading all children from API...');
    
    final updatedChildren = await _repository.getChildren();
    
    debugPrint('✅ [ChildBloc] Reloaded: ${updatedChildren.length} enfant(s)');

    // 4. Émettre le nouvel état avec les données à jour
    emit(ChildLoadedState(
      children: updatedChildren,
      filteredChildren: updatedChildren,
    ));
  } catch (e) {
    debugPrint('❌ [ChildBloc] Error updating schedule: $e');
    
    emit(ChildErrorState(
      error: 'Erreur lors de la mise à jour des horaires: ${e.toString()}',
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