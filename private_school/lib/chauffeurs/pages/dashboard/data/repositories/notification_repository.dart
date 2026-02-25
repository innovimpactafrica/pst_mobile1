import '../../../../../core/services/api_service.dart';
import '../../../../../core/utils/api_constants.dart';
import '../models/notification_model.dart';

class NotificationRepository {
  final ApiService _apiService = ApiService();
  final Set<int> _deletedIds = {};

  Future<List<NotificationModel>> getNotifications() async {
    try {
      final response = await _apiService.get(ApiConstants.notifications);

      List<dynamic> notificationsList = [];

      if (response['notifications'] is List) {
        notificationsList = response['notifications'] as List<dynamic>;
      } else if (response['data'] is List) {
        notificationsList = response['data'] as List<dynamic>;
      }

      final filteredList = notificationsList.where((json) {
        final id = json['id'] as int;
        final statut = (json['statut'] as String?)?.toLowerCase() ?? 'active';

        if (_deletedIds.contains(id)) {
          return false;
        }

        if (statut == 'deleted' || statut == 'archived') {
          return false;
        }

        return true;
      }).toList();

      final notifications = filteredList
          .map(
            (json) => NotificationModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();

      return notifications;
    } catch (e) {
      throw Exception('Erreur récupération notifications: $e');
    }
  }

  Future<void> markAsRead(int notificationId) async {
    try {
      await _apiService.put(
        ApiConstants.notificationMarkAsRead(notificationId),
      );
    } catch (e) {
      throw Exception('Erreur marquage notification: $e');
    }
  }

  Future<void> deleteNotification(int notificationId) async {
    try {
      _deletedIds.add(notificationId);
      await _apiService.delete(ApiConstants.notificationDelete(notificationId));
    } catch (e) {
      _deletedIds.remove(notificationId);
      throw Exception('Erreur suppression notification: $e');
    }
  }
}
