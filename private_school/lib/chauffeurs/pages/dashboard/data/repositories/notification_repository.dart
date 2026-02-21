import 'package:flutter/material.dart';
import '../../../../../core/services/api_service.dart';
import '../../../../../core/utils/api_constants.dart';
import '../models/notification_model.dart';

/// Repository des notifications pour le chauffeur
/// Utilisé par NotificationBloc pour la liste complète des notifications
class NotificationRepository {
  final ApiService _apiService = ApiService();
  
  // Cache local des IDs supprimés (solution temporaire)
  final Set<int> _deletedIds = {};

  /// Récupérer toutes les notifications du chauffeur
  Future<List<NotificationModel>> getNotifications() async {
    try {
      debugPrint('📡 [NotificationRepository] Récupération notifications chauffeur...');

      final response = await _apiService.get(ApiConstants.notifications);

      List<dynamic> notificationsList = [];

      if (response['notifications'] is List) {
        notificationsList = response['notifications'] as List<dynamic>;
      } else if (response['data'] is List) {
        notificationsList = response['data'] as List<dynamic>;
      }

      // Filtrer les notifications supprimées (backend + cache local)
      final filteredList = notificationsList.where((json) {
        final id = json['id'] as int;
        final statut = (json['statut'] as String?)?.toLowerCase() ?? 'active';
        
        // Exclure si dans le cache local OU si statut deleted/archived
        if (_deletedIds.contains(id)) {
          debugPrint('🚫 Notification $id: supprimée localement');
          return false;
        }
        
        if (statut == 'deleted' || statut == 'archived') {
          debugPrint('🚫 Notification $id: statut=$statut');
          return false;
        }
        
        return true;
      }).toList();

      final notifications = filteredList
          .map((json) => NotificationModel.fromJson(json as Map<String, dynamic>))
          .toList();

      debugPrint('✅ [NotificationRepository] ${notifications.length} notifications (${notificationsList.length} avant filtrage, ${_deletedIds.length} en cache)');
      debugPrint('   Non lues: ${notifications.where((n) => !n.isRead).length}');

      return notifications;
    } catch (e) {
      debugPrint('❌ [NotificationRepository] Erreur: $e');
      throw Exception('Erreur récupération notifications: $e');
    }
  }

  /// Marquer une notification comme lue
  Future<void> markAsRead(int notificationId) async {
    try {
      debugPrint('📡 [NotificationRepository] Marquage $notificationId comme lu...');
      await _apiService.put(ApiConstants.notificationMarkAsRead(notificationId));
      debugPrint('✅ [NotificationRepository] Notification $notificationId marquée lue');
    } catch (e) {
      debugPrint('❌ [NotificationRepository] Erreur markAsRead: $e');
      throw Exception('Erreur marquage notification: $e');
    }
  }

  /// Supprimer une notification
  Future<void> deleteNotification(int notificationId) async {
    try {
      debugPrint('📡 [NotificationRepository] Suppression $notificationId...');
      
      // Ajouter au cache local AVANT l'appel API
      _deletedIds.add(notificationId);
      debugPrint('💾 Cache local: notification $notificationId ajoutée');
      
      await _apiService.delete(ApiConstants.notificationDelete(notificationId));
      debugPrint('✅ [NotificationRepository] Notification $notificationId supprimée');
    } catch (e) {
      // En cas d'erreur, retirer du cache
      _deletedIds.remove(notificationId);
      debugPrint('❌ [NotificationRepository] Erreur delete: $e');
      throw Exception('Erreur suppression notification: $e');
    }
  }
}