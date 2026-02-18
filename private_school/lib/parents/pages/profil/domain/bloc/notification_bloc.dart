import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/notifications_repository.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class ParentNotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository repository;

  ParentNotificationBloc({required this.repository})
      : super(const NotificationInitial()) {
    on<LoadNotificationsEvent>(_onLoadNotifications);
    on<RefreshNotificationsEvent>(_onRefreshNotifications);
    on<MarkAsReadEvent>(_onMarkAsRead);
    on<DeleteNotificationEvent>(_onDeleteNotification);
  }

  Future<void> _onLoadNotifications(
    LoadNotificationsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    emit(const NotificationLoading());
    try {
      final notifications = await repository.getNotifications();
      emit(NotificationsLoaded(notifications));
    } catch (e) {
      emit(NotificationError('Erreur lors du chargement des notifications'));
    }
  }

  Future<void> _onRefreshNotifications(
    RefreshNotificationsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      final notifications = await repository.getNotifications();
      emit(NotificationsLoaded(notifications));
    } catch (e) {
      emit(NotificationError('Erreur lors du rafraîchissement'));
    }
  }

 Future<void> _onMarkAsRead(
  MarkAsReadEvent event,
  Emitter<NotificationState> emit,
) async {
  if (state is NotificationsLoaded) {
    final currentNotifications = (state as NotificationsLoaded).notifications;
    
    // ✅ Mettre à jour IMMÉDIATEMENT localement
    final updatedNotifications = currentNotifications.map((n) {
      if (n.id == event.notificationId) {
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();
    
    emit(NotificationsLoaded(updatedNotifications));
    
    // ✅ Appel API en arrière-plan
    try {
      await repository.markNotificationAsRead(event.notificationId);
      debugPrint('✅ Notification ${event.notificationId} marquée comme lue sur le serveur');
    } catch (e) {
      debugPrint('⚠️ Erreur API mark-read notification (non bloquant): $e');
      // On garde quand même la mise à jour locale
    }
  }
}

  Future<void> _onDeleteNotification(
    DeleteNotificationEvent event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await repository.deleteNotification(event.notificationId);
      
      emit(const NotificationDeleted());
      
      // Recharger les notifications
      final notifications = await repository.getNotifications();
      emit(NotificationsLoaded(notifications));
    } catch (e) {
      emit(NotificationError('Erreur lors de la suppression'));
    }
  }
}