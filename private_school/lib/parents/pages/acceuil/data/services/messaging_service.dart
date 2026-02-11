// Messaging Service - API Communication Layer
// Path: parents/pages/acceuil/data/services/messaging_service.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:private_school/core/storage/secure_storage.dart';
import 'package:private_school/core/utils/base_url.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';

class MessagingService {
  final SecureStorage _storage = SecureStorage();

  // ==================== CONVERSATIONS ====================
  
  /// GET /api/conversations - Récupérer toutes les conversations
  Future<List<ConversationModel>> getConversations() async {
    debugPrint('🔄 MessagingService.getConversations - START');
    
    try {
      final token = await _storage.getAccessToken();
      debugPrint('🔑 Token récupéré: ${token?.substring(0, 20)}...');
      
      final url = Uri.parse('${BaseUrl.current}/api/conversations');
      debugPrint('📡 URL: $url');
      
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      
      debugPrint('📊 Status Code: ${response.statusCode}');
      debugPrint('📦 Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // L'API peut retourner soit un objet avec 'data', soit directement un tableau
        final List<dynamic> conversationsJson = data is List ? data : (data['data'] ?? data['conversations'] ?? []);
        
        debugPrint('✅ ${conversationsJson.length} conversations récupérées');
        
        final conversations = conversationsJson
            .map((json) => ConversationModel.fromJson(json as Map<String, dynamic>))
            .toList();
        
        return conversations;
      } else {
        debugPrint('❌ Erreur HTTP: ${response.statusCode}');
        throw Exception('Erreur lors de la récupération des conversations: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Exception dans getConversations: $e');
      debugPrint('📋 StackTrace: $stackTrace');
      rethrow;
    }
  }

  /// POST /api/conversations - Créer ou récupérer une conversation directe
  Future<ConversationModel> createOrGetDirectConversation({
    required int otherUserId,
  }) async {
    debugPrint('🔄 MessagingService.createOrGetDirectConversation - START');
    debugPrint('👤 otherUserId: $otherUserId');
    
    try {
      final token = await _storage.getAccessToken();
      final url = Uri.parse('${BaseUrl.current}/api/conversations');
      
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'other_user_id': otherUserId,
        }),
      );
      
      debugPrint('📊 Status Code: ${response.statusCode}');
      debugPrint('📦 Response Body: ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        final conversationJson = data['data'] ?? data['conversation'] ?? data;
        
        debugPrint('✅ Conversation créée/récupérée avec succès');
        return ConversationModel.fromJson(conversationJson);
      } else {
        debugPrint('❌ Erreur HTTP: ${response.statusCode}');
        throw Exception('Erreur lors de la création de la conversation: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Exception dans createOrGetDirectConversation: $e');
      debugPrint('📋 StackTrace: $stackTrace');
      rethrow;
    }
  }

  /// POST /api/conversations/group - Créer une conversation de groupe
  Future<ConversationModel> createGroupConversation({
    required String name,
    required List<int> memberIds,
  }) async {
    debugPrint('🔄 MessagingService.createGroupConversation - START');
    debugPrint('📛 Nom du groupe: $name');
    debugPrint('👥 Membres: $memberIds');
    
    try {
      final token = await _storage.getAccessToken();
      final url = Uri.parse('${BaseUrl.current}/api/conversations/group');
      
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'name': name,
          'member_ids': memberIds,
        }),
      );
      
      debugPrint('📊 Status Code: ${response.statusCode}');
      debugPrint('📦 Response Body: ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        final conversationJson = data['data'] ?? data['conversation'] ?? data;
        
        debugPrint('✅ Conversation de groupe créée avec succès');
        return ConversationModel.fromJson(conversationJson);
      } else {
        debugPrint('❌ Erreur HTTP: ${response.statusCode}');
        throw Exception('Erreur lors de la création du groupe: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Exception dans createGroupConversation: $e');
      debugPrint('📋 StackTrace: $stackTrace');
      rethrow;
    }
  }

  /// PATCH /api/conversations/{id}/archive - Archiver/Désarchiver une conversation
  Future<void> toggleArchiveConversation(int conversationId, bool archive) async {
    debugPrint('🔄 MessagingService.toggleArchiveConversation - START');
    debugPrint('💬 conversationId: $conversationId, archive: $archive');
    
    try {
      final token = await _storage.getAccessToken();
      final url = Uri.parse('${BaseUrl.current}/api/conversations/$conversationId/archive');
      
      final response = await http.patch(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'archive': archive,
        }),
      );
      
      debugPrint('📊 Status Code: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        debugPrint('✅ Conversation archivée/désarchivée avec succès');
      } else {
        debugPrint('❌ Erreur HTTP: ${response.statusCode}');
        throw Exception('Erreur lors de l\'archivage: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Exception dans toggleArchiveConversation: $e');
      debugPrint('📋 StackTrace: $stackTrace');
      rethrow;
    }
  }

  /// PATCH /api/conversations/{id}/mute - Activer/Désactiver les notifications
  Future<void> toggleMuteConversation(int conversationId, bool mute) async {
    debugPrint('🔄 MessagingService.toggleMuteConversation - START');
    debugPrint('💬 conversationId: $conversationId, mute: $mute');
    
    try {
      final token = await _storage.getAccessToken();
      final url = Uri.parse('${BaseUrl.current}/api/conversations/$conversationId/mute');
      
      final response = await http.patch(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'mute': mute,
        }),
      );
      
      debugPrint('📊 Status Code: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        debugPrint('✅ Notifications activées/désactivées avec succès');
      } else {
        debugPrint('❌ Erreur HTTP: ${response.statusCode}');
        throw Exception('Erreur lors du mute: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Exception dans toggleMuteConversation: $e');
      debugPrint('📋 StackTrace: $stackTrace');
      rethrow;
    }
  }

  // ==================== MESSAGES ====================

  /// GET /api/conversations/{id}/messages - Récupérer les messages d'une conversation
  Future<List<MessageModel>> getMessages(int conversationId) async {
    debugPrint('🔄 MessagingService.getMessages - START');
    debugPrint('💬 conversationId: $conversationId');
    
    try {
      final token = await _storage.getAccessToken();
      final url = Uri.parse('${BaseUrl.current}/api/conversations/$conversationId/messages');
      
      debugPrint('📡 URL: $url');
      
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      
      debugPrint('📊 Status Code: ${response.statusCode}');
      debugPrint('📦 Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> messagesJson = data is List ? data : (data['data'] ?? data['messages'] ?? []);
        
        debugPrint('✅ ${messagesJson.length} messages récupérés');
        
        final messages = messagesJson
            .map((json) => MessageModel.fromJson(json as Map<String, dynamic>))
            .toList();
        
        return messages;
      } else {
        debugPrint('❌ Erreur HTTP: ${response.statusCode}');
        throw Exception('Erreur lors de la récupération des messages: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Exception dans getMessages: $e');
      debugPrint('📋 StackTrace: $stackTrace');
      rethrow;
    }
  }

  /// POST /api/conversations/{id}/messages - Envoyer un message
  Future<MessageModel> sendMessage({
    required int conversationId,
    required String content,
    int? replyToId,
  }) async {
    debugPrint('🔄 MessagingService.sendMessage - START');
    debugPrint('💬 conversationId: $conversationId');
    debugPrint('📝 content: $content');
    
    try {
      final token = await _storage.getAccessToken();
      final url = Uri.parse('${BaseUrl.current}/api/conversations/$conversationId/messages');
      
      final body = {
        'content': content,
        if (replyToId != null) 'reply_to_id': replyToId,
      };
      
      debugPrint('📤 Request Body: $body');
      
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(body),
      );
      
      debugPrint('📊 Status Code: ${response.statusCode}');
      debugPrint('📦 Response Body: ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        final messageJson = data['data'] ?? data['message'] ?? data;
        
        debugPrint('✅ Message envoyé avec succès');
        return MessageModel.fromJson(messageJson);
      } else {
        debugPrint('❌ Erreur HTTP: ${response.statusCode}');
        throw Exception('Erreur lors de l\'envoi du message: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Exception dans sendMessage: $e');
      debugPrint('📋 StackTrace: $stackTrace');
      rethrow;
    }
  }

  /// PATCH /api/conversations/{id}/messages/{messageId} - Modifier un message
  Future<MessageModel> updateMessage({
    required int conversationId,
    required int messageId,
    required String content,
  }) async {
    debugPrint('🔄 MessagingService.updateMessage - START');
    debugPrint('💬 conversationId: $conversationId, messageId: $messageId');
    
    try {
      final token = await _storage.getAccessToken();
      final url = Uri.parse('${BaseUrl.current}/api/conversations/$conversationId/messages/$messageId');
      
      final response = await http.patch(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'content': content,
        }),
      );
      
      debugPrint('📊 Status Code: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final messageJson = data['data'] ?? data['message'] ?? data;
        
        debugPrint('✅ Message modifié avec succès');
        return MessageModel.fromJson(messageJson);
      } else {
        debugPrint('❌ Erreur HTTP: ${response.statusCode}');
        throw Exception('Erreur lors de la modification: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Exception dans updateMessage: $e');
      debugPrint('📋 StackTrace: $stackTrace');
      rethrow;
    }
  }

  /// DELETE /api/conversations/{id}/messages/{messageId} - Supprimer un message
  Future<void> deleteMessage({
    required int conversationId,
    required int messageId,
  }) async {
    debugPrint('🔄 MessagingService.deleteMessage - START');
    debugPrint('💬 conversationId: $conversationId, messageId: $messageId');
    
    try {
      final token = await _storage.getAccessToken();
      final url = Uri.parse('${BaseUrl.current}/api/conversations/$conversationId/messages/$messageId');
      
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      
      debugPrint('📊 Status Code: ${response.statusCode}');
      
      if (response.statusCode == 200 || response.statusCode == 204) {
        debugPrint('✅ Message supprimé avec succès');
      } else {
        debugPrint('❌ Erreur HTTP: ${response.statusCode}');
        throw Exception('Erreur lors de la suppression: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Exception dans deleteMessage: $e');
      debugPrint('📋 StackTrace: $stackTrace');
      rethrow;
    }
  }

  /// DELETE /api/messages/{id} - Supprimer un message EN TEMPS RÉEL (alternative)
  Future<void> deleteMessageRealTime(int messageId) async {
    debugPrint('🔄 MessagingService.deleteMessageRealTime - START');
    debugPrint('💬 messageId: $messageId');
    
    try {
      final token = await _storage.getAccessToken();
      final url = Uri.parse('${BaseUrl.current}/api/messages/$messageId');
      
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      
      debugPrint('📊 Status Code: ${response.statusCode}');
      
      if (response.statusCode == 200 || response.statusCode == 204) {
        debugPrint('✅ Message supprimé en temps réel avec succès');
      } else {
        debugPrint('❌ Erreur HTTP: ${response.statusCode}');
        throw Exception('Erreur lors de la suppression temps réel: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Exception dans deleteMessageRealTime: $e');
      debugPrint('📋 StackTrace: $stackTrace');
      rethrow;
    }
  }
}
