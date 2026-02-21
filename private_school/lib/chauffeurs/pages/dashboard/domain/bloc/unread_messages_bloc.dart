import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/messaging_repository.dart';

// Events
abstract class UnreadMessagesEvent {}

class LoadUnreadCountEvent extends UnreadMessagesEvent {}
class RefreshUnreadCountEvent extends UnreadMessagesEvent {}
class UpdateUnreadCountEvent extends UnreadMessagesEvent {
  final int count;
  UpdateUnreadCountEvent(this.count);
}
class IncrementUnreadCountEvent extends UnreadMessagesEvent {}
class DecrementUnreadCountEvent extends UnreadMessagesEvent {}

// States
abstract class UnreadMessagesState {}

class UnreadMessagesInitial extends UnreadMessagesState {}
class UnreadMessagesLoading extends UnreadMessagesState {}
class UnreadMessagesLoaded extends UnreadMessagesState {
  final int count;
  UnreadMessagesLoaded({required this.count});
}
class UnreadMessagesError extends UnreadMessagesState {
  final String message;
  UnreadMessagesError({required this.message});
}

// Bloc
class UnreadMessagesBloc extends Bloc<UnreadMessagesEvent, UnreadMessagesState> {
  final MessagingRepository repository;
  static UnreadMessagesBloc? instance;

  UnreadMessagesBloc({required this.repository}) : super(UnreadMessagesInitial()) {
    instance = this;
    on<LoadUnreadCountEvent>(_onLoadUnreadCount);
    on<RefreshUnreadCountEvent>(_onRefreshUnreadCount);
    on<UpdateUnreadCountEvent>(_onUpdateUnreadCount);
    on<IncrementUnreadCountEvent>(_onIncrementUnreadCount);
    on<DecrementUnreadCountEvent>(_onDecrementUnreadCount);
  }

  Future<void> _onLoadUnreadCount(LoadUnreadCountEvent event, Emitter<UnreadMessagesState> emit) async {
    emit(UnreadMessagesLoading());
    try {
      final count = await repository.getUnreadCount();
      emit(UnreadMessagesLoaded(count: count));
    } catch (e) {
      emit(UnreadMessagesError(message: e.toString()));
    }
  }

  Future<void> _onRefreshUnreadCount(RefreshUnreadCountEvent event, Emitter<UnreadMessagesState> emit) async {
    try {
      final count = await repository.getUnreadCount();
      emit(UnreadMessagesLoaded(count: count));
    } catch (e) {
      emit(UnreadMessagesError(message: e.toString()));
    }
  }

  void _onUpdateUnreadCount(UpdateUnreadCountEvent event, Emitter<UnreadMessagesState> emit) {
    emit(UnreadMessagesLoaded(count: event.count));
  }

  void _onIncrementUnreadCount(IncrementUnreadCountEvent event, Emitter<UnreadMessagesState> emit) {
    final currentState = state;
    if (currentState is UnreadMessagesLoaded) {
      emit(UnreadMessagesLoaded(count: currentState.count + 1));
    }
  }

  void _onDecrementUnreadCount(DecrementUnreadCountEvent event, Emitter<UnreadMessagesState> emit) {
    final currentState = state;
    if (currentState is UnreadMessagesLoaded) {
      final newCount = currentState.count > 0 ? currentState.count - 1 : 0;
      emit(UnreadMessagesLoaded(count: newCount));
    }
  }

  static void notifyNewMessage(int conversationId) {
    instance?.add(IncrementUnreadCountEvent());
  }

  static void notifyMessageRead(int conversationId) {
    instance?.add(DecrementUnreadCountEvent());
  }
}