import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/notifications_repository.dart';

// Events
abstract class UnreadNotificationsEvent {}

class LoadUnreadNotificationsCountEvent extends UnreadNotificationsEvent {}
class RefreshUnreadNotificationsCountEvent extends UnreadNotificationsEvent {}
class UpdateUnreadCountEvent extends UnreadNotificationsEvent {
  final int count;
  UpdateUnreadCountEvent(this.count);
}

// States
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

// Bloc
class UnreadNotificationsBloc extends Bloc<UnreadNotificationsEvent, UnreadNotificationsState> {
  final NotificationsRepository repository;

  UnreadNotificationsBloc({required this.repository}) : super(UnreadNotificationsInitial()) {
    on<LoadUnreadNotificationsCountEvent>(_onLoadUnreadCount);
    on<RefreshUnreadNotificationsCountEvent>(_onRefreshUnreadCount);
    on<UpdateUnreadCountEvent>(_onUpdateUnreadCount);
  }

  Future<void> _onLoadUnreadCount(LoadUnreadNotificationsCountEvent event, Emitter<UnreadNotificationsState> emit) async {
    emit(UnreadNotificationsLoading());
    try {
      final count = await repository.getUnreadCount();
      emit(UnreadNotificationsLoaded(count: count));
    } catch (e) {
      emit(UnreadNotificationsError(message: e.toString()));
    }
  }

  Future<void> _onRefreshUnreadCount(RefreshUnreadNotificationsCountEvent event, Emitter<UnreadNotificationsState> emit) async {
    try {
      final count = await repository.getUnreadCount();
      emit(UnreadNotificationsLoaded(count: count));
    } catch (e) {
      emit(UnreadNotificationsError(message: e.toString()));
    }
  }

  void _onUpdateUnreadCount(UpdateUnreadCountEvent event, Emitter<UnreadNotificationsState> emit) {
    emit(UnreadNotificationsLoaded(count: event.count));
  }
}