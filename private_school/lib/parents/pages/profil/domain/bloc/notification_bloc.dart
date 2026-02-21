import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/notifications_repository.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class ParentNotificationBloc
    extends Bloc<NotificationEvent, NotificationState> {
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
      debugPrint('✅ [NotificationBloc] ${notifications.length} notifications chargées');
      debugPrint('   Non lues: ${notifications.where((n) => !n.isRead).length}');
      emit(NotificationsLoaded(notifications));
    } catch (e) {
      debugPrint('❌ [NotificationBloc] Erreur chargement: $e');
      emit(const NotificationError('Erreur lors du chargement des notifications'));
    }
  }

  Future<void> _onRefreshNotifications(
    RefreshNotificationsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      final notifications = await repository.getNotifications();
      debugPrint('🔄 [NotificationBloc] Refresh: ${notifications.length} notifications');
      debugPrint('   Non lues: ${notifications.where((n) => !n.isRead).length}');
      emit(NotificationsLoaded(notifications));
    } catch (e) {
      debugPrint('❌ [NotificationBloc] Erreur refresh: $e');
      emit(const NotificationError('Erreur lors du rafraîchissement'));
    }
  }

  Future<void> _onMarkAsRead(
    MarkAsReadEvent event,
    Emitter<NotificationState> emit,
  ) async {
    if (state is NotificationsLoaded) {
      final currentNotifications = (state as NotificationsLoaded).notifications;

      // ✅ 1. Mise à jour IMMÉDIATE en local pour l'UI
      final updatedNotifications = currentNotifications.map((n) {
        if (n.id == event.notificationId) {
          return n.copyWith(isRead: true);
        }
        return n;
      }).toList();
      emit(NotificationsLoaded(updatedNotifications));

      // ✅ 2. Appel API backend
      try {
        await repository.markNotificationAsRead(event.notificationId);
        debugPrint('✅ [NotificationBloc] Notification ${event.notificationId} marquée lue sur le serveur');

        // ✅ 3. Recharger depuis le backend pour avoir l'état réel
        final freshNotifications = await repository.getNotifications();
        debugPrint('🔄 [NotificationBloc] Rechargement après markAsRead:');
        debugPrint('   Non lues: ${freshNotifications.where((n) => !n.isRead).length}');
        emit(NotificationsLoaded(freshNotifications));
      } catch (e) {
        debugPrint('⚠️ [NotificationBloc] Erreur API mark-read (non bloquant): $e');
        // On garde la mise à jour locale
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

      // ✅ Recharger depuis le backend après suppression
      final notifications = await repository.getNotifications();
      emit(NotificationsLoaded(notifications));
    } catch (e) {
      debugPrint('❌ [NotificationBloc] Erreur suppression: $e');
      emit(const NotificationError('Erreur lors de la suppression'));
    }
  }
}