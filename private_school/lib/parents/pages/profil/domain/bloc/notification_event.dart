abstract class NotificationEvent {
  const NotificationEvent();
}

class LoadNotificationsEvent extends NotificationEvent {
  const LoadNotificationsEvent();
}

class RefreshNotificationsEvent extends NotificationEvent {
  const RefreshNotificationsEvent();
}

class MarkAsReadEvent extends NotificationEvent {
  final String notificationId;

  const MarkAsReadEvent(this.notificationId);
}

class DeleteNotificationEvent extends NotificationEvent {
  final String notificationId;

  const DeleteNotificationEvent(this.notificationId);
}
