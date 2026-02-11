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
    try {
      await repository.markNotificationAsRead(event.notificationId);
      
      // Recharger les notifications
      final notifications = await repository.getNotifications();
      emit(NotificationsLoaded(notifications));
    } catch (e) {
      emit(NotificationError('Erreur lors du marquage'));
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