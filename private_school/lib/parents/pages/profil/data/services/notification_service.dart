import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/storage/secure_storage.dart';
import '../../../../../core/utils/api_constants.dart';
import '../models/notification_model.dart';

class NotificationService {
  final ApiClient _apiClient = ApiClient();
  final SecureStorage _storage = SecureStorage();

  /// ✅ Récupérer UNIQUEMENT les notifications du parent connecté
  Future<List<NotificationModel>> fetchNotifications({bool unreadOnly = false}) async {
    try {
      debugPrint('═══════════════════════════════════════════════════════');
      debugPrint('📥 [NotificationService] GET ${ApiConstants.notifications}');
      debugPrint('   unread_only: $unreadOnly');
      debugPrint('═══════════════════════════════════════════════════════');
      
      final parentId = await _getCurrentParentId();
      debugPrint('👤 Parent connecté: ID $parentId');
      
      final response = await _apiClient.get(
        ApiConstants.notifications,
        queryParameters: unreadOnly ? {'unread_only': true} : null,
      );
      
      debugPrint('📦 Response status: ${response.statusCode}');
      
      if (response.data != null) {
        final List<dynamic> notificationsList = _extractNotificationsList(response.data);
        
        debugPrint('📊 ${notificationsList.length} notification(s) reçue(s) du backend');
        
        if (notificationsList.isEmpty) {
          debugPrint('ℹ️ Aucune notification reçue');
          return [];
        }
        
        final allNotifications = notificationsList
            .map((json) => NotificationModel.fromJson(json))
            .toList();
        
        final filteredNotifications = allNotifications.where((notif) {
          final type = notif.type.toLowerCase();
          if (type.contains('admin') || 
              type.contains('system') || 
              type.contains('driver_only') ||
              type.contains('chauffeur_only') ||
              type.contains('internal')) {
            debugPrint('🚫 Notification filtrée (système): ${notif.title}');
            return false;
          }
          
          if (notif.statut.toLowerCase() == 'deleted' || 
              notif.statut.toLowerCase() == 'archived') {
            debugPrint('🚫 Notification filtrée (statut: ${notif.statut}): ${notif.title}');
            return false;
          }
          
          return true;
        }).toList();
        
        filteredNotifications.sort((a, b) => b.dateCreation.compareTo(a.dateCreation));
        
        debugPrint('');
        debugPrint('✅ RÉSULTAT FINAL:');
        debugPrint('   Total backend: ${notificationsList.length}');
        debugPrint('   Après filtrage: ${filteredNotifications.length}');
        debugPrint('   Non lues: ${filteredNotifications.where((n) => !n.isRead).length}');
        debugPrint('═══════════════════════════════════════════════════════\n');
        
        return filteredNotifications;
      }
      
      return [];
    } catch (e, stackTrace) {
      debugPrint('❌ [NotificationService] Erreur: $e');
      debugPrint('Stack trace: $stackTrace');
      throw Exception('Erreur lors de la récupération des notifications: $e');
    }
  }

  /// ✅ Récupérer le compteur de notifications non lues depuis le backend
  Future<int> fetchUnreadCount() async {
    try {
      final response = await _apiClient.get('/api/notifications/user');
      
      if (response.data != null && response.data is Map) {
        // ✅ Compter localement les notifications non lues au lieu d'utiliser unreadCount
        final List<dynamic> notificationsList = _extractNotificationsList(response.data);
        int count = 0;
        for (var notif in notificationsList) {
          if (notif['lu'] == false) {
            count++;
          }
        }
        debugPrint('🔔 [NotificationService] Compteur calculé: $count');
        return count;
      }
      
      return 0;
    } catch (e) {
      debugPrint('❌ [NotificationService] Erreur compteur: $e');
      // ✅ En cas d'erreur, retourner -1 pour signaler au bloc de garder l'ancien compteur
      rethrow;
    }
  }

  /// ✅ Extraire la liste des notifications de la réponse API (formats multiples)
  List<dynamic> _extractNotificationsList(dynamic responseData) {
    if (responseData is List) {
      return responseData;
    }
    
    if (responseData is Map) {
      // Essayer différentes clés possibles
      if (responseData['notifications'] is List) {
        return responseData['notifications'];
      }
      if (responseData['data'] is List) {
        return responseData['data'];
      }
      if (responseData['data'] is Map && responseData['data']['notifications'] is List) {
        return responseData['data']['notifications'];
      }
    }
    
    return [];
  }

  /// ✅ Récupérer l'ID du parent connecté depuis le token JWT
  Future<int?> _getCurrentParentId() async {
    try {
      final token = await _storage.getAccessToken();
      if (token == null) return null;
      
      // Décoder le JWT pour extraire l'ID
      final parts = token.split('.');
      if (parts.length != 3) return null;
      
      // Décoder la partie payload (Base64)
      final payload = parts[1];
      final normalized = base64.normalize(payload);
      final decoded = utf8.decode(base64.decode(normalized));
      final Map<String, dynamic> payloadMap = json.decode(decoded);
      
      return payloadMap['id'] as int?;
    } catch (e) {
      debugPrint('⚠️ Impossible de récupérer l\'ID du parent: $e');
      return null;
    }
  }

  /// Marquer une notification comme lue
  Future<void> markAsRead(String notificationId) async {
    try {
      debugPrint('═══════════════════════════════════════════════════════');
      debugPrint('📝 [NotificationService] PUT /api/notifications/$notificationId/read');
      debugPrint('═══════════════════════════════════════════════════════');
      
      await _apiClient.put('/api/notifications/$notificationId/read');
      
      debugPrint('✅ Notification $notificationId marquée comme lue\n');
    } catch (e) {
      debugPrint('❌ [NotificationService] Erreur marquage: $e');
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
      
      debugPrint('✅ Notification $notificationId supprimée\n');
    } catch (e) {
      debugPrint('❌ [NotificationService] Erreur suppression: $e');
      throw Exception('Erreur lors de la suppression: $e');
    }
  }
}