// Notification Service - API calls only
// Path: lib/parents/profil/data/services/notification_service.dart

import 'package:private_school/core/network/api_client.dart';

import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';

class NotificationService {
  final ApiClient _apiClient = ApiClient();

  Future<List<NotificationModel>> fetchNotifications() async {
    try {
      debugPrint('🔍 Fetching notifications...');

      final response = await _apiClient.get('/api/notifications/user');

      debugPrint('✅ Notifications received: ${response.statusCode}');

      final List<dynamic> notificationsData = response.data is List
          ? response.data
          : response.data['data'] ?? response.data['notifications'] ?? [];

      return notificationsData
          .map(
            (json) => NotificationModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      debugPrint('❌ Error fetching notifications: $e');
      throw Exception('Failed to load notifications: $e');
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _apiClient.put(
        '/api/notifications/$notificationId',
        data: {'isRead': true},
      );
      debugPrint('✅ Notification marked as read');
    } catch (e) {
      debugPrint('❌ Error marking as read: $e');
      throw Exception('Failed to mark as read: $e');
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await _apiClient.delete('/api/notifications/$notificationId');
      debugPrint('✅ Notification deleted');
    } catch (e) {
      debugPrint('❌ Error deleting notification: $e');
      throw Exception('Failed to delete notification: $e');
    }
  }
}
