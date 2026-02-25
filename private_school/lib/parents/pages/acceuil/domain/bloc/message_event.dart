// Message Events
// Path: parents/pages/acceuil/domain/bloc/message_event.dart

import 'package:equatable/equatable.dart';

abstract class MessageEvent extends Equatable {
  const MessageEvent();

  @override
  List<Object?> get props => [];
}

// ==================== LOAD MESSAGES ====================

class LoadMessagesEvent extends MessageEvent {
  final int conversationId;

  const LoadMessagesEvent({required this.conversationId});

  @override
  List<Object?> get props => [conversationId];

  @override
  String toString() => 'LoadMessagesEvent(conversationId: $conversationId)';
}

class RefreshMessagesEvent extends MessageEvent {
  final int conversationId;

  const RefreshMessagesEvent({required this.conversationId});

  @override
  List<Object?> get props => [conversationId];

  @override
  String toString() => 'RefreshMessagesEvent(conversationId: $conversationId)';
}

// ==================== SEND MESSAGE ====================

class SendMessageEvent extends MessageEvent {
  final int conversationId;
  final String content;
  final int? replyToId;
  final int currentUserId; // ✅ ajout
  const SendMessageEvent({
    required this.conversationId,
    required this.content,
    this.replyToId,
    this.currentUserId = 0, // ✅ valeur par défaut
  });

  @override
  List<Object?> get props => [conversationId, content, replyToId];

  @override
  String toString() =>
      'SendMessageEvent(conversationId: $conversationId, content: ${content.substring(0, content.length > 20 ? 20 : content.length)}...)';
}

// ==================== UPDATE MESSAGE ====================

class UpdateMessageEvent extends MessageEvent {
  final int conversationId;
  final int messageId;
  final String content;

  const UpdateMessageEvent({
    required this.conversationId,
    required this.messageId,
    required this.content,
  });

  @override
  List<Object?> get props => [conversationId, messageId, content];

  @override
  String toString() =>
      'UpdateMessageEvent(conversationId: $conversationId, messageId: $messageId)';
}

// ==================== DELETE MESSAGE ====================

class DeleteMessageEvent extends MessageEvent {
  final int conversationId;
  final int messageId;

  const DeleteMessageEvent({
    required this.conversationId,
    required this.messageId,
  });

  @override
  List<Object?> get props => [conversationId, messageId];

  @override
  String toString() =>
      'DeleteMessageEvent(conversationId: $conversationId, messageId: $messageId)';
}

// ==================== REPLY TO MESSAGE ====================

class SetReplyToMessageEvent extends MessageEvent {
  final int messageId;
  final String messageContent;
  final String senderName;

  const SetReplyToMessageEvent({
    required this.messageId,
    required this.messageContent,
    required this.senderName,
  });

  @override
  List<Object?> get props => [messageId, messageContent, senderName];

  @override
  String toString() => 'SetReplyToMessageEvent(messageId: $messageId)';
}

class CancelReplyToMessageEvent extends MessageEvent {
  const CancelReplyToMessageEvent();

  @override
  String toString() => 'CancelReplyToMessageEvent';
}

// ==================== TYPING INDICATOR ====================

class UserTypingEvent extends MessageEvent {
  final bool isTyping;

  const UserTypingEvent({required this.isTyping});

  @override
  List<Object?> get props => [isTyping];

  @override
  String toString() => 'UserTypingEvent(isTyping: $isTyping)';
}

// ==================== RESET ====================

class ResetMessagesEvent extends MessageEvent {
  const ResetMessagesEvent();

  @override
  String toString() => 'ResetMessagesEvent';
}