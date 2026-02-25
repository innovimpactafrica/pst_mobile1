import 'package:flutter/material.dart';
import '../network/api_client.dart';
import '../utils/api_constants.dart';

class ChatService {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> getOrCreateConversation(
    String recipientId,
  ) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.conversations,
        data: {'recipient_id': recipientId},
      );
      return response.data;
    } catch (e) {
      debugPrint('Error creating conversation: $e');
      rethrow;
    }
  }

  Future<List<dynamic>> getMessages(String conversationId) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.conversations}/$conversationId/messages',
      );
      return response.data['messages'] ?? [];
    } catch (e) {
      debugPrint('Error getting messages: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> sendMessage({
    required String conversationId,
    required String content,
    String messageType = 'text',
  }) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.conversations}/$conversationId/messages',
        data: {'content': content, 'message_type': messageType},
      );
      return response.data;
    } catch (e) {
      debugPrint('Error sending message: $e');
      rethrow;
    }
  }
}
