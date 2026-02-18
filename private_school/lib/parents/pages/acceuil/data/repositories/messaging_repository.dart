// Messaging Repository - Business Logic Layer
// Path: parents/pages/acceuil/data/repositories/messaging_repository.dart

import 'package:flutter/material.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';
import '../services/messaging_service.dart';

class MessagingRepository {
  final MessagingService _service = MessagingService();

  // ==================== CONVERSATIONS ====================

  Future<List<ConversationModel>> getConversations() async {
    debugPrint('🔄 MessagingRepository.getConversations');
    try {
      final conversations = await _service.getConversations();
      debugPrint('✅ Repository: ${conversations.length} conversations récupérées');
      return conversations;
    } catch (e) {
      debugPrint('❌ Repository Error: $e');
      rethrow;
    }
  }

  Future<ConversationModel> createOrGetDirectConversation({
  required int otherUserId,
  String? initialMessage,
}) async {
  debugPrint('🔄 MessagingRepository.createOrGetDirectConversation');
  debugPrint('👤 otherUserId: $otherUserId');
  debugPrint('💬 initialMessage: ${initialMessage ?? "null"}');
  
  try {
    final conversation = await _service.createOrGetDirectConversation(
      otherUserId: otherUserId,
      initialMessage: initialMessage,
    );
    debugPrint('✅ Repository: Conversation créée/récupérée');
    return conversation;
  } catch (e) {
    debugPrint('❌ Repository Error: $e');
    rethrow;
  }
}

  Future<ConversationModel> createGroupConversation({
    required String name,
    required List<int> memberIds,
  }) async {
    debugPrint('🔄 MessagingRepository.createGroupConversation');
    try {
      final conversation = await _service.createGroupConversation(
        name: name,
        memberIds: memberIds,
      );
      debugPrint('✅ Repository: Groupe créé');
      return conversation;
    } catch (e) {
      debugPrint('❌ Repository Error: $e');
      rethrow;
    }
  }

  Future<void> archiveConversation(int conversationId) async {
    debugPrint('🔄 MessagingRepository.archiveConversation: $conversationId');
    try {
      await _service.toggleArchiveConversation(conversationId, true);
      debugPrint('✅ Repository: Conversation archivée');
    } catch (e) {
      debugPrint('❌ Repository Error: $e');
      rethrow;
    }
  }

  Future<void> unarchiveConversation(int conversationId) async {
    debugPrint('🔄 MessagingRepository.unarchiveConversation: $conversationId');
    try {
      await _service.toggleArchiveConversation(conversationId, false);
      debugPrint('✅ Repository: Conversation désarchivée');
    } catch (e) {
      debugPrint('❌ Repository Error: $e');
      rethrow;
    }
  }

  Future<void> muteConversation(int conversationId) async {
    debugPrint('🔄 MessagingRepository.muteConversation: $conversationId');
    try {
      await _service.toggleMuteConversation(conversationId, true);
      debugPrint('✅ Repository: Notifications désactivées');
    } catch (e) {
      debugPrint('❌ Repository Error: $e');
      rethrow;
    }
  }

  Future<void> unmuteConversation(int conversationId) async {
    debugPrint('🔄 MessagingRepository.unmuteConversation: $conversationId');
    try {
      await _service.toggleMuteConversation(conversationId, false);
      debugPrint('✅ Repository: Notifications activées');
    } catch (e) {
      debugPrint('❌ Repository Error: $e');
      rethrow;
    }
  }

  // ==================== MESSAGES ====================

  Future<List<MessageModel>> getMessages(int conversationId) async {
    debugPrint('🔄 MessagingRepository.getMessages: $conversationId');
    try {
      final messages = await _service.getMessages(conversationId);
      debugPrint('✅ Repository: ${messages.length} messages récupérés');
      return messages;
    } catch (e) {
      debugPrint('❌ Repository Error: $e');
      rethrow;
    }
  }

  Future<MessageModel> sendMessage({
    required int conversationId,
    required String content,
    int? replyToId,
  }) async {
    debugPrint('🔄 MessagingRepository.sendMessage');
    try {
      final message = await _service.sendMessage(
        conversationId: conversationId,
        content: content,
        replyToId: replyToId,
      );
      debugPrint('✅ Repository: Message envoyé');
      return message;
    } catch (e) {
      debugPrint('❌ Repository Error: $e');
      rethrow;
    }
  }

  Future<MessageModel> updateMessage({
    required int conversationId,
    required int messageId,
    required String content,
  }) async {
    debugPrint('🔄 MessagingRepository.updateMessage');
    try {
      final message = await _service.updateMessage(
        conversationId: conversationId,
        messageId: messageId,
        content: content,
      );
      debugPrint('✅ Repository: Message modifié');
      return message;
    } catch (e) {
      debugPrint('❌ Repository Error: $e');
      rethrow;
    }
  }

  Future<void> deleteMessage({
    required int conversationId,
    required int messageId,
  }) async {
    debugPrint('🔄 MessagingRepository.deleteMessage');
    try {
      await _service.deleteMessage(
        conversationId: conversationId,
        messageId: messageId,
      );
      debugPrint('✅ Repository: Message supprimé');
    } catch (e) {
      debugPrint('❌ Repository Error: $e');
      rethrow;
    }
  }

  Future<void> markConversationAsRead(int conversationId) async {
    debugPrint('🔄 MessagingRepository.markConversationAsRead: $conversationId');
    try {
      await _service.markConversationAsRead(conversationId);
      debugPrint('✅ Repository: Messages marqués comme lus');
      
      // Attendre un peu pour que le serveur traite la requête
      await Future.delayed(const Duration(milliseconds: 300));
    } catch (e) {
      debugPrint('⚠️ Repository Error (non-bloquant): $e');
      // Ne pas rethrow car ce n'est pas bloquant
    }
  }
}