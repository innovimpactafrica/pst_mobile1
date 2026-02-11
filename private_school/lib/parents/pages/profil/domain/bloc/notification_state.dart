import '../../data/models/notification_model.dart';

abstract class NotificationState {
  const NotificationState();
}

class NotificationInitial extends NotificationState {
  const NotificationInitial();
}

class NotificationLoading extends NotificationState {
  const NotificationLoading();
}

class NotificationsLoaded extends NotificationState {
  final List<NotificationModel> notifications;

  const NotificationsLoaded(this.notifications);

  int get unreadCount => notifications.where((n) => !n.isRead).length;
}

class NotificationError extends NotificationState {
  final String message;

  const NotificationError(this.message);
}

class NotificationDeleted extends NotificationState {
  const NotificationDeleted();
}