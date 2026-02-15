import 'package:flutter/material.dart';
import '../../../../../core/network/api_client.dart';
import '../models/notification_model.dart';

class NotificationService {
  final ApiClient _apiClient = ApiClient();

  /// Récupérer toutes les notifications du parent connecté
  Future<List<NotificationModel>> fetchNotifications() async {
    try {
      debugPrint('═══════════════════════════════════════════════════════');
      debugPrint('📥 [NotificationService] GET /api/notifications/user');
      debugPrint('═══════════════════════════════════════════════════════');
      
      final response = await _apiClient.get('/api/notifications/user');
      
      debugPrint('📦 Response: ${response.data}');
      
      if (response.data != null) {
        final List<dynamic> notificationsList = response.data['notifications'] ?? response.data['data'] ?? [];
        
        debugPrint('📊 ${notificationsList.length} notification(s) reçue(s) du backend');
        
        final allNotifications = notificationsList
            .map((json) => NotificationModel.fromJson(json))
            .toList();
        
        // ✅ FILTRER : Garder uniquement les notifications pour les parents
        final filteredNotifications = allNotifications.where((notif) {
          final type = notif.type.toLowerCase();
          
          // Exclure les notifications admin/système
          if (type.contains('admin') || 
              type.contains('system') || 
              type.contains('driver_only') ||
              type.contains('chauffeur_only')) {
            debugPrint('🚫 Notification filtrée (admin/system): ${notif.title}');
            return false;
          }
          
          return true;
        }).toList();
        
        debugPrint('✅ ${filteredNotifications.length} notification(s) après filtrage');
        
        return filteredNotifications;
      }
      
      return [];
    } catch (e) {
      debugPrint('❌ [NotificationService] Erreur: $e');
      throw Exception('Erreur lors de la récupération des notifications: $e');
    }
  }

  /// Marquer une notification comme lue
  Future<void> markAsRead(String notificationId) async {
    try {
      debugPrint('═══════════════════════════════════════════════════════');
      debugPrint('📝 [NotificationService] PUT /api/notifications/$notificationId/read');
      debugPrint('═══════════════════════════════════════════════════════');
      
      await _apiClient.put('/api/notifications/$notificationId/read');
      
      debugPrint('✅ Notification marquée comme lue');
    } catch (e) {
      debugPrint('❌ [NotificationService] Erreur: $e');
      throw Exception('Erreur lors du marquage: $e');
    }
  }

  /// Supprimer une notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      debugPrint('═══════════════════════════════════════════════════════');
      debugPrint('🗑️ [NotificationService] DELETE /api/notifications/$notificationId');
      debugPrint('═══════════════════════════════════════════════════════');
      
      await _apiClient.delete('/api/notifications/$notificationId');
      
      debugPrint('✅ Notification supprimée');
    } catch (e) {
      debugPrint('❌ [NotificationService] Erreur: $e');
      throw Exception('Erreur lors de la suppression: $e');
    }
  }
}