
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

 
  final Set<int> _locallyReadIds = {};

 
  int _baseCount = 0;

  UnreadNotificationsBloc({required this.repository})
      : super(UnreadNotificationsInitial()) {
    on<LoadUnreadNotificationsCountEvent>(_onLoad);
    on<RefreshUnreadNotificationsCountEvent>(_onRefresh);
    on<UpdateUnreadCountEvent>(_onUpdate);
    on<MarkNotificationAsReadLocalEvent>(_onMarkLocal);
  }


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
      emit(UnreadNotificationsLoaded(count: _baseCount));
    } catch (e) {
     
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
      _locallyReadIds.clear();
     
      emit(UnreadNotificationsLoaded(count: _baseCount));
    } catch (e) {
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
    emit(UnreadNotificationsLoaded(count: _baseCount));
  }

  void _onMarkLocal(
    MarkNotificationAsReadLocalEvent event,
    Emitter<UnreadNotificationsState> emit,
  ) {
    if (_locallyReadIds.contains(event.notificationId)) return;
    _locallyReadIds.add(event.notificationId);
    emit(UnreadNotificationsLoaded(count: _effectiveCount));
  }
}