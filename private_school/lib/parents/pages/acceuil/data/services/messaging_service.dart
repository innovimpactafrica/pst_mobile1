// Messaging Service - FINAL CORRECTED VERSION
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
    String? initialMessage,
  }) async {
    debugPrint('🔄 MessagingService.createOrGetDirectConversation - START');
    debugPrint('👤 otherUserId: $otherUserId');
    debugPrint('💬 initialMessage: ${initialMessage ?? "null"}');
    
    try {
      final token = await _storage.getAccessToken();
      debugPrint('🔑 Token récupéré: ${token?.substring(0, 20)}...');
      
      final url = Uri.parse('${BaseUrl.current}/api/conversations');
      debugPrint('📡 URL: $url');
      
      // ✅ FIX : N'envoyer initial_message QUE s'il n'est pas vide
      final requestBody = <String, dynamic>{
        'other_user_id': otherUserId,
      };
      
      // N'ajouter initial_message que s'il existe et n'est pas vide
      if (initialMessage != null && initialMessage.trim().isNotEmpty) {
        requestBody['initial_message'] = initialMessage.trim();
      }
      
      debugPrint('📤 Request Body: $requestBody');
      
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(requestBody),
      );
      
      debugPrint('📊 Status Code: ${response.statusCode}');
      debugPrint('📦 Response Body: ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        final conversationJson = data['data'] ?? data['conversation'] ?? data;
        
        debugPrint('✅ Conversation créée/récupérée avec succès');
        return ConversationModel.fromJson(conversationJson);
      } else if (response.statusCode == 400) {
        final errorData = json.decode(response.body);
        final errorMessage = errorData['message'] ?? 'Requête invalide';
        debugPrint('❌ Erreur de validation: $errorMessage');
        throw Exception('Validation échouée: $errorMessage');
      } else if (response.statusCode == 404) {
        debugPrint('❌ Utilisateur $otherUserId non trouvé');
        throw Exception('Utilisateur introuvable');
      } else if (response.statusCode == 500) {
        final errorData = json.decode(response.body);
        final errorMessage = errorData['message'] ?? 'Erreur serveur';
        debugPrint('❌ Erreur serveur: $errorMessage');
        throw Exception('Erreur serveur: $errorMessage');
      } else {
        debugPrint('❌ Erreur HTTP inattendue: ${response.statusCode}');
        throw Exception('Erreur HTTP: ${response.statusCode}');
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
    int? tripId,
  }) async {
    debugPrint('🔄 MessagingService.createGroupConversation - START');
    debugPrint('📛 Nom du groupe: $name');
    debugPrint('👥 Membres: $memberIds (${memberIds.length} membres)');
    debugPrint('🚗 Trip ID: ${tripId ?? "null"}');
    
    try {
      final token = await _storage.getAccessToken();
      final url = Uri.parse('${BaseUrl.current}/api/conversations/group');
      
      // ✅ FIX : Vérifier qu'il y a au moins 2 membres
      if (memberIds.length < 2) {
        debugPrint('⚠️ ATTENTION: Moins de 2 membres sélectionnés!');
        throw Exception('Au moins 2 membres sont requis pour créer un groupe');
      }
      
      // ✅ FIX CRITIQUE : Utiliser "participant_ids" au lieu de "member_ids"
      final requestBody = <String, dynamic>{
        'title': name.trim(),  // ✅ FIX : "title" au lieu de "name"
        'participant_ids': memberIds,  // ✅ FIX : "participant_ids" au lieu de "member_ids"
      };
      
      // Ajouter trip_id seulement s'il est fourni
      if (tripId != null) {
        requestBody['trip_id'] = tripId;
      }
      
      debugPrint('📤 Request Body: $requestBody');
      
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(requestBody),
      );
      
      debugPrint('📊 Status Code: ${response.statusCode}');
      debugPrint('📦 Response Body: ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        final conversationJson = data['data'] ?? data['conversation'] ?? data;
        
        debugPrint('✅ Conversation de groupe créée avec succès');
        return ConversationModel.fromJson(conversationJson);
      } else if (response.statusCode == 400) {
        final errorData = json.decode(response.body);
        final errorMessage = errorData['message'] ?? 'Requête invalide';
        debugPrint('❌ Erreur de validation: $errorMessage');
        throw Exception(errorMessage);
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

  /// PATCH /api/conversations/{id}/archive
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
        body: json.encode({'archived': archive}),
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

  /// PATCH /api/conversations/{id}/mute
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
        body: json.encode({'mute': mute}),
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

  /// GET /api/conversations/{id}/messages
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

  /// POST /api/conversations/{id}/messages
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
        if (replyToId != null) 'parent_message_id': replyToId,
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

  /// PATCH /api/conversations/{id}/messages/{messageId}
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
        body: json.encode({'content': content}),
      );
      
    debugPrint('📊 Status Code: ${response.statusCode}');
debugPrint('📦 Response Body UPDATE: ${response.body}'); // ← Ajouter cette ligne
      
     if (response.statusCode == 200) {
  final data = json.decode(response.body);

  // Si le serveur renvoie l'objet complet dans 'data'
  if (data['data'] != null && data['data'] is Map) {
    debugPrint('✅ Message modifié avec succès (via data)');
    return MessageModel.fromJson(data['data'] as Map<String, dynamic>);
  }

  // Sinon le serveur renvoie juste {"success":true,"message":"Message modifié"}
  // On reconstruit un MessageModel minimal depuis les paramètres qu'on connaît déjà
  debugPrint('✅ Message modifié avec succès (réponse simple)');
  return MessageModel(
    id: messageId,
    conversationId: conversationId,
    senderId: 0,
    senderName: '',
    senderRole: '',
    content: content,
    isEdited: true,
    isDeleted: false,
    createdAt: DateTime.now(),
  );
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

  /// DELETE /api/conversations/{id}/messages/{messageId}
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
debugPrint('📦 Response Body DELETE: ${response.body}'); // ← Ajouter cette ligne
      
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

  /// DELETE /api/messages/{id} - Supprimer un message en temps réel
  Future<void> deleteMessageRealtime(int messageId) async {
    debugPrint('🔄 MessagingService.deleteMessageRealtime - START');
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
        throw Exception('Erreur lors de la suppression: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Exception dans deleteMessageRealtime: $e');
      debugPrint('📋 StackTrace: $stackTrace');
      rethrow;
    }
  }

  /// POST /api/conversations/{id}/read - Marquer les messages comme lus
  Future<void> markConversationAsRead(int conversationId) async {
    debugPrint('🔄 MessagingService.markConversationAsRead - START');
    debugPrint('💬 conversationId: $conversationId');
    
    try {
      final token = await _storage.getAccessToken();
      final url = Uri.parse('${BaseUrl.current}/api/conversations/$conversationId/read');
      
      final response = await http.patch(  // ✅ POST → PATCH
  url,
  headers: {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  },
);
      
      debugPrint('📊 Status Code: ${response.statusCode}');
      
      if (response.statusCode == 200 || response.statusCode == 204) {
        debugPrint('✅ Messages marqués comme lus');
      } else {
        debugPrint('⚠️ Erreur HTTP: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('⚠️ Exception dans markConversationAsRead: $e');
    }
  }
}