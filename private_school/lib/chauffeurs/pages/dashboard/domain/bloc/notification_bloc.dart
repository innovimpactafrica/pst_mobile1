import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/notification_repository.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository repository;

  NotificationBloc({required this.repository})
    : super(const NotificationInitial()) {
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

      emit(
        NotificationLoaded(
          notifications: notifications,
          unreadCount: unreadCount,
        ),
      );
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> _onMarkAsRead(
    MarkNotificationAsReadEvent event,
    Emitter<NotificationState> emit,
  ) async {
    if (state is NotificationLoaded) {
      final current = state as NotificationLoaded;
      final updated = current.notifications.map((n) {
        if (n.id == event.notificationId) return n.copyWith(isRead: true);
        return n;
      }).toList();
      emit(
        NotificationLoaded(
          notifications: updated,
          unreadCount: updated.where((n) => !n.isRead).length,
        ),
      );
    }

    try {
      await repository.markAsRead(event.notificationId);

      final fresh = await repository.getNotifications();
      final unreadCount = fresh.where((n) => !n.isRead).length;

      emit(NotificationLoaded(notifications: fresh, unreadCount: unreadCount));
    } catch (e) {
      //
    }
  }

  Future<void> _onDeleteNotification(
    DeleteNotificationEvent event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await repository.deleteNotification(event.notificationId);
      emit(const NotificationActionSuccess('Notification supprimée'));
      final notifications = await repository.getNotifications();
      final unreadCount = notifications.where((n) => !n.isRead).length;
      emit(
        NotificationLoaded(
          notifications: notifications,
          unreadCount: unreadCount,
        ),
      );
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
      emit(
        NotificationLoaded(
          notifications: notifications,
          unreadCount: unreadCount,
        ),
      );
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }
}
