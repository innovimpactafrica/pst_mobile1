
import '../../../../../core/services/api_service.dart';

class NotificationsRepository {
  final ApiService _apiService = ApiService();
  Future<int> getUnreadCount() async {
    try {
      final response = await _apiService.get('/api/notifications/user');
      List<dynamic> notificationsList = [];
      if (response['data'] is List) {
        notificationsList = response['data'] as List<dynamic>;
      } else if (response['notifications'] is List) {
        notificationsList = response['notifications'] as List<dynamic>;
      } else if (response['data'] is Map) {
        final data = response['data'] as Map;
        if (data['notifications'] is List) {
          notificationsList = data['notifications'] as List<dynamic>;
        }
      }
      
      if (notificationsList.isEmpty && response['unreadNotificationsCount'] != null) {
        final count = response['unreadNotificationsCount'];
        final result = count is int ? count : int.tryParse(count.toString()) ?? 0;
        return result;
      }
      int count = 0;
      for (final notif in notificationsList) {
        if (notif is Map && notif['lu'] == false) {
          count++;
        }
      }

      return count;
    } catch (e) {
      return 0;
    }
  }
}