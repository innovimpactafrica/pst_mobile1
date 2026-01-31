

import '../models/notification_model.dart';
import '../services/notification_service.dart';

class NotificationRepository {
  final NotificationService _service;

  NotificationRepository({NotificationService? service})
      : _service = service ?? NotificationService();

  Future<List<NotificationModel>> getNotifications() async {
    return await _service.getNotifications();
  }

  Future<void> markAsRead(int notificationId) async {
    return await _service.markAsRead(notificationId);
  }

  Future<void> deleteNotification(int notificationId) async {
    return await _service.deleteNotification(notificationId);
  }
}