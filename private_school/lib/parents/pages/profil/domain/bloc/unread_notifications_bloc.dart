import 'dart:async';
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
  
  // ✅ Liste locale des notifications déjà lues
  final Set<String> _readNotifications = {};
  
  static UnreadNotificationsBloc? _instance;
  static UnreadNotificationsBloc? get instance => _instance;

  UnreadNotificationsBloc({required this.repository}) : super(UnreadNotificationsInitial()) {
    on<LoadUnreadNotificationsCountEvent>(_onLoadUnreadCount);
    on<RefreshUnreadNotificationsCountEvent>(_onRefreshUnreadCount);
    on<MarkNotificationAsReadEvent>(_onMarkAsRead);
    _instance = this;
  }

  Future<void> _onLoadUnreadCount(
    LoadUnreadNotificationsCountEvent event,
    Emitter<UnreadNotificationsState> emit,
  ) async {
    try {
      debugPrint('🔔 [UnreadNotificationsBloc] Chargement compteur...');
      final unreadCount = await repository.getUnreadCount();
      debugPrint('🔔 Notifications non lues (backend): $unreadCount');
      emit(UnreadNotificationsLoaded(unreadCount));
    } catch (e) {
      debugPrint('❌ Erreur: $e');
      if (state is UnreadNotificationsLoaded) {
        emit(UnreadNotificationsLoaded((state as UnreadNotificationsLoaded).count));
      } else {
        emit(UnreadNotificationsLoaded(0));
      }
    }
  }

  Future<void> _onRefreshUnreadCount(
    RefreshUnreadNotificationsCountEvent event,
    Emitter<UnreadNotificationsState> emit,
  ) async {
    try {
      final unreadCount = await repository.getUnreadCount();
      debugPrint('🔄 Refresh compteur notifications: $unreadCount');
      emit(UnreadNotificationsLoaded(unreadCount));
    } catch (e) {
      debugPrint('❌ Erreur refresh: $e');
      if (state is UnreadNotificationsLoaded) {
        emit(state as UnreadNotificationsLoaded);
      }
    }
  }

  Future<void> _onMarkAsRead(
    MarkNotificationAsReadEvent event,
    Emitter<UnreadNotificationsState> emit,
  ) async {
    debugPrint('✅ Marquage notification ${event.notificationId} comme lue');
    
    // ✅ Décrémenter IMMÉDIATEMENT
    _readNotifications.add(event.notificationId);
    if (state is UnreadNotificationsLoaded) {
      final currentCount = (state as UnreadNotificationsLoaded).count;
      emit(UnreadNotificationsLoaded(currentCount > 0 ? currentCount - 1 : 0));
    }

    // ✅ Appel API en arrière-plan
    try {
      await repository.markNotificationAsRead(event.notificationId);
      debugPrint('✅ API mark-read réussie');
    } catch (e) {
      debugPrint('⚠️ Erreur API mark-read (non bloquant): $e');
      // On garde quand même la notification comme lue localement
    }
  }
}