import 'package:flutter/material.dart';
import '../../../../../core/services/api_service.dart';

class MessagingRepository {
  final ApiService _apiService = ApiService();

  /// Récupérer le nombre de messages non lus pour le chauffeur
  Future<int> getUnreadCount() async {
    try {
      debugPrint('📡 [MessagingRepository] Récupération messages non lus chauffeur...');
      
      final response = await _apiService.get('/driver/messages/unread-count');
      
      if (response['success'] == true) {
        final count = response['data']['unread_count'] ?? 0;
        debugPrint('✅ [MessagingRepository] Messages non lus: $count');
        return count is int ? count : int.tryParse(count.toString()) ?? 0;
      }
      
      debugPrint('⚠️ [MessagingRepository] Réponse API invalide');
      return 0;
    } catch (e) {
      debugPrint('❌ [MessagingRepository] Erreur: $e');
      return 0;
    }
  }

  /// Récupérer la liste des conversations du chauffeur
  Future<List<Map<String, dynamic>>> getConversations() async {
    try {
      debugPrint('📡 [MessagingRepository] Récupération conversations chauffeur...');
      
      final response = await _apiService.get('/driver/conversations');
      
      if (response['success'] == true && response['data'] != null) {
        final conversations = List<Map<String, dynamic>>.from(response['data']);
        debugPrint('✅ [MessagingRepository] ${conversations.length} conversations récupérées');
        return conversations;
      }
      
      return [];
    } catch (e) {
      debugPrint('❌ [MessagingRepository] Erreur conversations: $e');
      return [];
    }
  }

  /// Récupérer les messages d'une conversation
  Future<List<Map<String, dynamic>>> getMessages(String conversationId) async {
    try {
      debugPrint('📡 [MessagingRepository] Récupération messages conversation $conversationId...');
      
      final response = await _apiService.get('/driver/conversations/$conversationId/messages');
      
      if (response['success'] == true && response['data'] != null) {
        final messages = List<Map<String, dynamic>>.from(response['data']);
        debugPrint('✅ [MessagingRepository] ${messages.length} messages récupérés');
        return messages;
      }
      
      return [];
    } catch (e) {
      debugPrint('❌ [MessagingRepository] Erreur messages: $e');
      return [];
    }
  }

  /// Envoyer un message
  Future<bool> sendMessage(String conversationId, String content) async {
    try {
      debugPrint('📡 [MessagingRepository] Envoi message...');
      
      final response = await _apiService.post('/driver/conversations/$conversationId/messages', {
        'content': content,
      });
      
      if (response['success'] == true) {
        debugPrint('✅ [MessagingRepository] Message envoyé');
        return true;
      }
      
      return false;
    } catch (e) {
      debugPrint('❌ [MessagingRepository] Erreur envoi: $e');
      return false;
    }
  }

  /// Marquer les messages comme lus
  Future<bool> markAsRead(String conversationId) async {
    try {
      debugPrint('📡 [MessagingRepository] Marquage comme lu...');
      
      final response = await _apiService.post('/driver/conversations/$conversationId/mark-read', {});
      
      if (response['success'] == true) {
        debugPrint('✅ [MessagingRepository] Messages marqués comme lus');
        return true;
      }
      
      return false;
    } catch (e) {
      debugPrint('❌ [MessagingRepository] Erreur marquage: $e');
      return false;
    }
  }
}