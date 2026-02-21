import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/notifications_repository.dart';

// ════════════════════════════════════════════
// EVENTS
// ════════════════════════════════════════════

abstract class UnreadNotificationsEvent {}

class LoadUnreadNotificationsCountEvent extends UnreadNotificationsEvent {}

class RefreshUnreadNotificationsCountEvent extends UnreadNotificationsEvent {}

class UpdateUnreadCountEvent extends UnreadNotificationsEvent {
  final int count;
  UpdateUnreadCountEvent(this.count);
}

/// ✅ Décrémente immédiatement le badge quand l'user tape une notification
class MarkNotificationAsReadLocalEvent extends UnreadNotificationsEvent {
  final int notificationId;
  MarkNotificationAsReadLocalEvent(this.notificationId);
}

// ════════════════════════════════════════════
// STATES
// ════════════════════════════════════════════

abstract class UnreadNotificationsState {}

class UnreadNotificationsInitial extends UnreadNotificationsState {}

class UnreadNotificationsLoading extends UnreadNotificationsState {}

class UnreadNotificationsLoaded extends UnreadNotificationsState {
  final int count;
  UnreadNotificationsLoaded({required this.count});
}

class UnreadNotificationsError extends UnreadNotificationsState {
  final String message;
  UnreadNotificationsError({required this.message});
}

// ════════════════════════════════════════════
// BLOC
// ════════════════════════════════════════════

class UnreadNotificationsBloc
    extends Bloc<UnreadNotificationsEvent, UnreadNotificationsState> {
  final NotificationsRepository repository;

  /// IDs des notifications lues localement (avant sync backend)
  final Set<int> _locallyReadIds = {};

  /// Compteur de base venant du backend
  int _baseCount = 0;

  UnreadNotificationsBloc({required this.repository})
      : super(UnreadNotificationsInitial()) {
    on<LoadUnreadNotificationsCountEvent>(_onLoad);
    on<RefreshUnreadNotificationsCountEvent>(_onRefresh);
    on<UpdateUnreadCountEvent>(_onUpdate);
    on<MarkNotificationAsReadLocalEvent>(_onMarkLocal);
  }

  /// ✅ Compteur réel = base backend - lectures locales
  int get _effectiveCount {
    final c = _baseCount - _locallyReadIds.length;
    return c < 0 ? 0 : c;
  }

  Future<void> _onLoad(
    LoadUnreadNotificationsCountEvent event,
    Emitter<UnreadNotificationsState> emit,
  ) async {
    emit(UnreadNotificationsLoading());
    try {
      final count = await repository.getUnreadCount();
      _baseCount = count;
      _locallyReadIds.clear();
      debugPrint('🔔 [UnreadNotifBloc] Chargement: $_baseCount non lues');
      emit(UnreadNotificationsLoaded(count: _baseCount));
    } catch (e) {
      debugPrint('❌ [UnreadNotifBloc] Erreur load: $e');
      emit(UnreadNotificationsError(message: e.toString()));
    }
  }

  Future<void> _onRefresh(
    RefreshUnreadNotificationsCountEvent event,
    Emitter<UnreadNotificationsState> emit,
  ) async {
    try {
      final count = await repository.getUnreadCount();
      _baseCount = count;
      // ✅ Après refresh backend, vider les lectures locales (backend est à jour)
      _locallyReadIds.clear();
      debugPrint('🔄 [UnreadNotifBloc] Refresh: $_baseCount non lues');
      emit(UnreadNotificationsLoaded(count: _baseCount));
    } catch (e) {
      debugPrint('❌ [UnreadNotifBloc] Erreur refresh: $e');
      // Garder l'état actuel en cas d'erreur
      if (state is UnreadNotificationsLoaded) {
        emit(UnreadNotificationsLoaded(count: _effectiveCount));
      }
    }
  }

  void _onUpdate(
    UpdateUnreadCountEvent event,
    Emitter<UnreadNotificationsState> emit,
  ) {
    _baseCount = event.count;
    _locallyReadIds.clear();
    debugPrint('📊 [UnreadNotifBloc] Update forcé: $_baseCount non lues');
    emit(UnreadNotificationsLoaded(count: _baseCount));
  }

  void _onMarkLocal(
    MarkNotificationAsReadLocalEvent event,
    Emitter<UnreadNotificationsState> emit,
  ) {
    if (_locallyReadIds.contains(event.notificationId)) return;
    _locallyReadIds.add(event.notificationId);
    debugPrint(
      '✅ [UnreadNotifBloc] Lu local: ${event.notificationId} → badge: $_effectiveCount',
    );
    emit(UnreadNotificationsLoaded(count: _effectiveCount));
  }
}