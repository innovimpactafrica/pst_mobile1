import '../models/notification_model.dart';
import '../services/notification_service.dart';

class NotificationRepository {
  final NotificationService _service = NotificationService();

  Future<List<NotificationModel>> getNotifications() async {
    return await _service.fetchNotifications();
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    await _service.markAsRead(notificationId);
  }

  Future<void> deleteNotification(String notificationId) async {
    await _service.deleteNotification(notificationId);
  }
}