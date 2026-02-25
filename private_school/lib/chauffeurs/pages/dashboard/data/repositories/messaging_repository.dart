import '../models/conversation_model.dart';
import '../models/message_model.dart';
import '../services/messaging_service.dart';

class MessagingRepository {
  final MessagingService _service = MessagingService();

  Future<List<ConversationModel>> getConversations() async {
    try {
      return await _service.getConversations();
    } catch (e) {
      rethrow;
    }
  }

  Future<int> getUnreadCount() async {
    try {
      final conversations = await _service.getConversations();
      return conversations.fold<int>(0, (sum, conv) => sum + conv.unreadCount);
    } catch (e) {
      return 0;
    }
  }

  Future<List<MessageModel>> getMessages(int conversationId) async {
    try {
      return await _service.getMessages(conversationId);
    } catch (e) {
      rethrow;
    }
  }

  Future<MessageModel?> sendMessage({
    required int conversationId,
    required String content,
    int? replyToId,
  }) async {
    try {
      return await _service.sendMessage(
        conversationId: conversationId,
        content: content,
        replyToId: replyToId,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<MessageModel?> updateMessage({
    required int conversationId,
    required int messageId,
    required String content,
  }) async {
    try {
      return await _service.updateMessage(
        conversationId: conversationId,
        messageId: messageId,
        content: content,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteMessage({
    required int conversationId,
    required int messageId,
  }) async {
    try {
      await _service.deleteMessage(
        conversationId: conversationId,
        messageId: messageId,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> markConversationAsRead(int conversationId) async {
    try {
      await _service.markConversationAsRead(conversationId);
      await Future.delayed(const Duration(milliseconds: 300));
    } catch (e) {
      //
    }
  }

  Future<void> archiveConversation(int conversationId) async {
    try {
      await _service.toggleArchiveConversation(conversationId, true);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> unarchiveConversation(int conversationId) async {
    try {
      await _service.toggleArchiveConversation(conversationId, false);
    } catch (e) {
      rethrow;
    }
  }
}
