import 'package:flutter/material.dart';
import '../../../../../core/services/api_service.dart';

/// Repository pour le COMPTEUR de notifications non lues (badge dans la navbar)
/// Différent de notification_repository.dart qui gère la liste complète
class NotificationsRepository {
  final ApiService _apiService = ApiService();

  /// ✅ Récupérer le nombre de notifications non lues
  /// Utilise /api/notifications/user et compte les lu:false
  Future<int> getUnreadCount() async {
    try {
      debugPrint('📡 [NotificationsRepository] Récupération count non lues chauffeur...');

      final response = await _apiService.get('/api/notifications/user');

      debugPrint('📦 [NotificationsRepository] Response type: ${response.runtimeType}');

      List<dynamic> notificationsList = [];

      // ✅ Gérer tous les formats possibles de réponse
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
      
      // ✅ Si le backend fournit directement unreadNotificationsCount, l'utiliser
      if (notificationsList.isEmpty && response['unreadNotificationsCount'] != null) {
        final count = response['unreadNotificationsCount'];
        final result = count is int ? count : int.tryParse(count.toString()) ?? 0;
        debugPrint('✅ [NotificationsRepository] Count direct: $result');
        return result;
      }

      // ✅ Compter localement les lu:false
      int count = 0;
      for (final notif in notificationsList) {
        if (notif is Map && notif['lu'] == false) {
          count++;
        }
      }

      debugPrint('✅ [NotificationsRepository] Count calculé: $count sur ${notificationsList.length} notifs');
      return count;
    } catch (e) {
      debugPrint('❌ [NotificationsRepository] Erreur: $e');
      return 0;
    }
  }
}