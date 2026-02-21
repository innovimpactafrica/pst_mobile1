import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:private_school/core/storage/secure_storage.dart';
import 'package:private_school/core/utils/base_url.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';

class MessagingService {
  final SecureStorage _storage = SecureStorage();

  Future<List<ConversationModel>> getConversations() async {
    try {
      final token = await _storage.getAccessToken();
      final url = Uri.parse('${BaseUrl.current}/api/conversations');
      
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> conversationsJson = data is List ? data : (data['data'] ?? data['conversations'] ?? []);
        return conversationsJson.map((json) => ConversationModel.fromJson(json as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('❌ [MessagingService] Erreur conversations: $e');
      return [];
    }
  }

  Future<ConversationModel?> createOrGetDirectConversation({
    required int otherUserId,
    String? initialMessage,
  }) async {
    try {
      final token = await _storage.getAccessToken();
      final url = Uri.parse('${BaseUrl.current}/api/conversations');
      
      final requestBody = <String, dynamic>{
        'other_user_id': otherUserId,
      };
      
      if (initialMessage != null && initialMessage.trim().isNotEmpty) {
        requestBody['initial_message'] = initialMessage.trim();
      }
      
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(requestBody),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        final conversationJson = data['data'] ?? data['conversation'] ?? data;
        return ConversationModel.fromJson(conversationJson);
      }
      return null;
    } catch (e) {
      debugPrint('❌ [MessagingService] Erreur création: $e');
      return null;
    }
  }

  Future<List<MessageModel>> getMessages(int conversationId) async {
    try {
      final token = await _storage.getAccessToken();
      final url = Uri.parse('${BaseUrl.current}/api/conversations/$conversationId/messages');
      
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> messagesJson = data is List ? data : (data['data'] ?? data['messages'] ?? []);
        return messagesJson.map((json) => MessageModel.fromJson(json as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('❌ [MessagingService] Erreur messages: $e');
      return [];
    }
  }

  Future<MessageModel?> sendMessage({
    required int conversationId,
    required String content,
    int? replyToId,
  }) async {
    try {
      final token = await _storage.getAccessToken();
      final url = Uri.parse('${BaseUrl.current}/api/conversations/$conversationId/messages');
      
      final body = {
        'content': content,
        if (replyToId != null) 'parent_message_id': replyToId,
      };
      
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(body),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        final messageJson = data['data'] ?? data['message'] ?? data;
        return MessageModel.fromJson(messageJson);
      }
      return null;
    } catch (e) {
      debugPrint('❌ [MessagingService] Erreur envoi: $e');
      return null;
    }
  }

  Future<MessageModel?> updateMessage({
    required int conversationId,
    required int messageId,
    required String content,
  }) async {
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
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final messageJson = data['data'] ?? data['message'] ?? data;
        return MessageModel.fromJson(messageJson);
      }
      return null;
    } catch (e) {
      debugPrint('❌ [MessagingService] Erreur modification: $e');
      return null;
    }
  }

  Future<void> deleteMessage({
    required int conversationId,
    required int messageId,
  }) async {
    try {
      final token = await _storage.getAccessToken();
      final url = Uri.parse('${BaseUrl.current}/api/conversations/$conversationId/messages/$messageId');
      
      await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
    } catch (e) {
      debugPrint('❌ [MessagingService] Erreur suppression: $e');
    }
  }

 Future<void> markConversationAsRead(int conversationId) async {
  try {
    final token = await _storage.getAccessToken();
    final url = Uri.parse('${BaseUrl.current}/api/conversations/$conversationId/read');
    
    await http.patch( // ← était POST, maintenant PATCH
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    debugPrint('✅ [MessagingService Chauffeur] Messages marqués comme lus');
  } catch (e) {
    debugPrint('⚠️ [MessagingService Chauffeur] Erreur marquage: $e');
  }
}

  Future<void> toggleArchiveConversation(int conversationId, bool archive) async {
    try {
      final token = await _storage.getAccessToken();
      final url = Uri.parse('${BaseUrl.current}/api/conversations/$conversationId/archive');
      
      await http.patch(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({'archived': archive}),
      );
    } catch (e) {
      debugPrint('❌ [MessagingService] Erreur archivage: $e');
    }
  }
}