import 'package:flutter/material.dart';
import '../../../../../core/services/api_service.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';

class MessagingService {
  final ApiService _apiService = ApiService();

  /// Récupérer toutes les conversations du chauffeur
  Future<List<ConversationModel>> getConversations() async {
    try {
      debugPrint('📡 [MessagingService] Récupération conversations chauffeur...');
      
      final response = await _apiService.get('/driver/conversations');
      
      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> conversationsData = response['data'];
        final conversations = conversationsData
            .map((data) => ConversationModel.fromJson(data))
            .toList();
        
        debugPrint('✅ [MessagingService] ${conversations.length} conversations récupérées');
        return conversations;
      }
      
      debugPrint('⚠️ [MessagingService] Aucune conversation trouvée');
      return [];
    } catch (e) {
      debugPrint('❌ [MessagingService] Erreur conversations: $e');
      return [];
    }
  }

  /// Récupérer les messages d'une conversation
  Future<List<MessageModel>> getMessages(String conversationId) async {
    try {
      debugPrint('📡 [MessagingService] Récupération messages conversation $conversationId...');
      
      final response = await _apiService.get('/driver/conversations/$conversationId/messages');
      
      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> messagesData = response['data'];
        final messages = messagesData
            .map((data) => MessageModel.fromJson(data))
            .toList();
        
        // Trier par date (plus récent en bas)
        messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        
        debugPrint('✅ [MessagingService] ${messages.length} messages récupérés');
        return messages;
      }
      
      return [];
    } catch (e) {
      debugPrint('❌ [MessagingService] Erreur messages: $e');
      return [];
    }
  }

  /// Envoyer un message
  Future<bool> sendMessage(String conversationId, String content) async {
    try {
      debugPrint('📡 [MessagingService] Envoi message...');
      
      final response = await _apiService.post('/driver/conversations/$conversationId/messages', {
        'content': content,
      });
      
      if (response['success'] == true) {
        debugPrint('✅ [MessagingService] Message envoyé avec succès');
        return true;
      }
      
      debugPrint('❌ [MessagingService] Échec envoi message');
      return false;
    } catch (e) {
      debugPrint('❌ [MessagingService] Erreur envoi: $e');
      return false;
    }
  }

  /// Marquer une conversation comme lue
  Future<bool> markConversationAsRead(String conversationId) async {
    try {
      debugPrint('📡 [MessagingService] Marquage conversation $conversationId comme lue...');
      
      final response = await _apiService.post('/driver/conversations/$conversationId/mark-read', {});
      
      if (response['success'] == true) {
        debugPrint('✅ [MessagingService] Conversation marquée comme lue');
        return true;
      }
      
      return false;
    } catch (e) {
      debugPrint('❌ [MessagingService] Erreur marquage: $e');
      return false;
    }
  }

  /// Créer une nouvelle conversation avec un parent
  Future<ConversationModel?> createConversation(String parentId) async {
    try {
      debugPrint('📡 [MessagingService] Création conversation avec parent $parentId...');
      
      final response = await _apiService.post('/driver/conversations', {
        'participant_id': parentId,
        'participant_type': 'parent',
      });
      
      if (response['success'] == true && response['data'] != null) {
        final conversation = ConversationModel.fromJson(response['data']);
        debugPrint('✅ [MessagingService] Conversation créée: ${conversation.id}');
        return conversation;
      }
      
      return null;
    } catch (e) {
      debugPrint('❌ [MessagingService] Erreur création conversation: $e');
      return null;
    }
  }
}