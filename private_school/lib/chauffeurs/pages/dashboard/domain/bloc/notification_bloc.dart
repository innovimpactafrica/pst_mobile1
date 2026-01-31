

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/notification_repository.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository repository;

  NotificationBloc({required this.repository}) : super(const NotificationInitial()) {
    on<LoadNotificationsEvent>(_onLoadNotifications);
    on<MarkNotificationAsReadEvent>(_onMarkAsRead);
    on<DeleteNotificationEvent>(_onDeleteNotification);
    on<RefreshNotificationsEvent>(_onRefreshNotifications);
  }

  Future<void> _onLoadNotifications(
    LoadNotificationsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    emit(const NotificationLoading());
    try {
      final notifications = await repository.getNotifications();
      final unreadCount = notifications.where((n) => !n.isRead).length;

      emit(NotificationLoaded(
        notifications: notifications,
        unreadCount: unreadCount,
      ));
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> _onMarkAsRead(
    MarkNotificationAsReadEvent event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await repository.markAsRead(event.notificationId);

      // Reload notifications after marking as read
      final notifications = await repository.getNotifications();
      final unreadCount = notifications.where((n) => !n.isRead).length;

      emit(NotificationLoaded(
        notifications: notifications,
        unreadCount: unreadCount,
      ));
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> _onDeleteNotification(
    DeleteNotificationEvent event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await repository.deleteNotification(event.notificationId);

      // Reload notifications after deletion
      final notifications = await repository.getNotifications();
      final unreadCount = notifications.where((n) => !n.isRead).length;

      emit(NotificationLoaded(
        notifications: notifications,
        unreadCount: unreadCount,
      ));

      emit(const NotificationActionSuccess('Notification supprimée'));
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> _onRefreshNotifications(
    RefreshNotificationsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      final notifications = await repository.getNotifications();
      final unreadCount = notifications.where((n) => !n.isRead).length;

      emit(NotificationLoaded(
        notifications: notifications,
        unreadCount: unreadCount,
      ));
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }
}