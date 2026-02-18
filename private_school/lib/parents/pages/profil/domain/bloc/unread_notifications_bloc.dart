import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import '../../data/repositories/notifications_repository.dart';

// Events
abstract class UnreadNotificationsEvent {}

class LoadUnreadNotificationsCountEvent extends UnreadNotificationsEvent {}

class RefreshUnreadNotificationsCountEvent extends UnreadNotificationsEvent {}

class MarkNotificationAsReadEvent extends UnreadNotificationsEvent {
  final String notificationId;
  MarkNotificationAsReadEvent(this.notificationId);
}

// States
abstract class UnreadNotificationsState {}

class UnreadNotificationsInitial extends UnreadNotificationsState {}

class UnreadNotificationsLoading extends UnreadNotificationsState {}

class UnreadNotificationsLoaded extends UnreadNotificationsState {
  final int count;
  UnreadNotificationsLoaded(this.count);
}

class UnreadNotificationsError extends UnreadNotificationsState {
  final String message;
  UnreadNotificationsError(this.message);
}

// Bloc
class UnreadNotificationsBloc extends Bloc<UnreadNotificationsEvent, UnreadNotificationsState> {
  final NotificationRepository repository;

  UnreadNotificationsBloc({required this.repository}) : super(UnreadNotificationsInitial()) {
    on<LoadUnreadNotificationsCountEvent>(_onLoadUnreadCount);
    on<RefreshUnreadNotificationsCountEvent>(_onRefreshUnreadCount);
    on<MarkNotificationAsReadEvent>(_onMarkAsRead);
  }

  Future<void> _onLoadUnreadCount(
    LoadUnreadNotificationsCountEvent event,
    Emitter<UnreadNotificationsState> emit,
  ) async {
    emit(UnreadNotificationsLoading());
    try {
      debugPrint('🔔 [UnreadNotificationsBloc] Chargement compteur notifications...');
      final notifications = await repository.getNotifications();
      final unreadCount = notifications.where((n) => !n.isRead).length;
      debugPrint('🔔 [UnreadNotificationsBloc] Notifications non lues: $unreadCount');
      emit(UnreadNotificationsLoaded(unreadCount));
    } catch (e) {
      debugPrint('❌ [UnreadNotificationsBloc] Erreur: $e');
      emit(UnreadNotificationsError('Erreur chargement notifications'));
    }
  }

  Future<void> _onRefreshUnreadCount(
    RefreshUnreadNotificationsCountEvent event,
    Emitter<UnreadNotificationsState> emit,
  ) async {
    try {
      debugPrint('🔄 [UnreadNotificationsBloc] Refresh compteur notifications...');
      final notifications = await repository.getNotifications();
      final unreadCount = notifications.where((n) => !n.isRead).length;
      debugPrint('🔄 [UnreadNotificationsBloc] Nouveau compteur: $unreadCount');
      emit(UnreadNotificationsLoaded(unreadCount));
    } catch (e) {
      debugPrint('❌ [UnreadNotificationsBloc] Erreur refresh: $e');
      // Ne pas émettre d'erreur lors du refresh pour éviter de casser l'UI
    }
  }

  Future<void> _onMarkAsRead(
    MarkNotificationAsReadEvent event,
    Emitter<UnreadNotificationsState> emit,
  ) async {
    try {
      debugPrint('✅ [UnreadNotificationsBloc] Marquage notification ${event.notificationId} comme lue');
      await repository.markNotificationAsRead(event.notificationId);
      
      // Recharger le compteur
      final notifications = await repository.getNotifications();
      final unreadCount = notifications.where((n) => !n.isRead).length;
      debugPrint('✅ [UnreadNotificationsBloc] Nouveau compteur après lecture: $unreadCount');
      emit(UnreadNotificationsLoaded(unreadCount));
    } catch (e) {
      debugPrint('❌ [UnreadNotificationsBloc] Erreur marquage: $e');
    }
  }
}