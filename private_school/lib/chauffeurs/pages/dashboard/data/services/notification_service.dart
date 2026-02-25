

import 'package:dio/dio.dart';
import 'package:private_school/core/network/api_client.dart';
import 'package:private_school/core/utils/api_constants.dart';
import '../models/notification_model.dart';

class NotificationService {
  final ApiClient _apiClient;

  NotificationService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Get all notifications from dashboard endpoint
  Future<List<NotificationModel>> getNotifications() async {
    try {
      
      final response = await _apiClient.get(ApiConstants.driverDashboard);

      if (response.data['success'] == true) {
        final List<dynamic> notificationsJson =
            response.data['data']['notifications'] as List<dynamic>? ?? [];

        final notifications = notificationsJson
            .map((json) => NotificationModel.fromJson(json as Map<String, dynamic>))
            .toList();

        return notifications;
      } else {
        throw Exception('Failed to fetch notifications');
      }
    } on DioException catch (e) {
      
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      
      throw Exception('Error fetching notifications: $e');
    }
  }

  /// Mark notification as read
  Future<void> markAsRead(int notificationId) async {
    try {
      await _apiClient.put(
        '/api/notifications/$notificationId/read',
      );

      
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {   
      throw Exception('Error marking notification as read: $e');
    }
  }

  /// Delete notification
  Future<void> deleteNotification(int notificationId) async {
    try {
      await _apiClient.delete(
        '/api/notifications/$notificationId',
      );

      
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error deleting notification: $e');
    }
  }
}