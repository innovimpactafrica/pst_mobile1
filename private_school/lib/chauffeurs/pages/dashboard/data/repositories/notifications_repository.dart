import 'package:flutter/material.dart';
import '../../../../../core/services/api_service.dart';

class NotificationsRepository {
  final ApiService _apiService = ApiService();

  /// Récupérer le nombre de notifications non lues pour le chauffeur
  Future<int> getUnreadCount() async {
    try {
      debugPrint('📡 [NotificationsRepository] Récupération notifications non lues chauffeur...');
      
      final response = await _apiService.get('/driver/notifications/unread-count');
      
      if (response['success'] == true) {
        final count = response['data']['unread_count'] ?? 0;
        debugPrint('✅ [NotificationsRepository] Notifications non lues: $count');
        return count is int ? count : int.tryParse(count.toString()) ?? 0;
      }
      
      debugPrint('⚠️ [NotificationsRepository] Réponse API invalide');
      return 0;
    } catch (e) {
      debugPrint('❌ [NotificationsRepository] Erreur: $e');
      return 0;
    }
  }

  /// Récupérer la liste des notifications du chauffeur
  Future<List<Map<String, dynamic>>> getNotifications() async {
    try {
      debugPrint('📡 [NotificationsRepository] Récupération notifications chauffeur...');
      
      final response = await _apiService.get('/driver/notifications');
      
      if (response['success'] == true && response['data'] != null) {
        final notifications = List<Map<String, dynamic>>.from(response['data']);
        debugPrint('✅ [NotificationsRepository] ${notifications.length} notifications récupérées');
        return notifications;
      }
      
      return [];
    } catch (e) {
      debugPrint('❌ [NotificationsRepository] Erreur notifications: $e');
      return [];
    }
  }

  /// Marquer une notification comme lue
  Future<bool> markAsRead(String notificationId) async {
    try {
      debugPrint('📡 [NotificationsRepository] Marquage notification $notificationId comme lue...');
      
      final response = await _apiService.post('/driver/notifications/$notificationId/mark-read', {});
      
      if (response['success'] == true) {
        debugPrint('✅ [NotificationsRepository] Notification marquée comme lue');
        return true;
      }
      
      return false;
    } catch (e) {
      debugPrint('❌ [NotificationsRepository] Erreur marquage: $e');
      return false;
    }
  }

  /// Marquer toutes les notifications comme lues
  Future<bool> markAllAsRead() async {
    try {
      debugPrint('📡 [NotificationsRepository] Marquage toutes notifications comme lues...');
      
      final response = await _apiService.post('/driver/notifications/mark-all-read', {});
      
      if (response['success'] == true) {
        debugPrint('✅ [NotificationsRepository] Toutes notifications marquées comme lues');
        return true;
      }
      
      return false;
    } catch (e) {
      debugPrint('❌ [NotificationsRepository] Erreur marquage global: $e');
      return false;
    }
  }

  /// Supprimer une notification
  Future<bool> deleteNotification(String notificationId) async {
    try {
      debugPrint('📡 [NotificationsRepository] Suppression notification $notificationId...');
      
      final response = await _apiService.delete('/driver/notifications/$notificationId');
      
      if (response['success'] == true) {
        debugPrint('✅ [NotificationsRepository] Notification supprimée');
        return true;
      }
      
      return false;
    } catch (e) {
      debugPrint('❌ [NotificationsRepository] Erreur suppression: $e');
      return false;
    }
  }
}