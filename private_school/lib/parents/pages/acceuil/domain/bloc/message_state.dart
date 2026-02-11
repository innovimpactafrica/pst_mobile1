// Message States
// Path: parents/pages/acceuil/domain/bloc/message_state.dart

import 'package:equatable/equatable.dart';
import '../../data/models/message_model.dart';

abstract class MessageState extends Equatable {
  const MessageState();

  @override
  List<Object?> get props => [];
}

// ==================== INITIAL STATE ====================

class MessageInitial extends MessageState {
  const MessageInitial();

  @override
  String toString() => 'MessageInitial';
}

// ==================== LOADING STATES ====================

class MessageLoading extends MessageState {
  final int conversationId;

  const MessageLoading({required this.conversationId});

  @override
  List<Object?> get props => [conversationId];

  @override
  String toString() => 'MessageLoading(conversationId: $conversationId)';
}

class MessageRefreshing extends MessageState {
  final int conversationId;
  final List<MessageModel> currentMessages;

  const MessageRefreshing({
    required this.conversationId,
    required this.currentMessages,
  });

  @override
  List<Object?> get props => [conversationId, currentMessages];

  @override
  String toString() =>
      'MessageRefreshing(conversationId: $conversationId, ${currentMessages.length} messages)';
}

// ==================== LOADED STATE ====================

class MessageLoaded extends MessageState {
  final int conversationId;
  final List<MessageModel> messages;
  final int? replyToId;
  final String? replyToContent;
  final String? replyToSenderName;
  final bool isTyping;

  const MessageLoaded({
    required this.conversationId,
    required this.messages,
    this.replyToId,
    this.replyToContent,
    this.replyToSenderName,
    this.isTyping = false,
  });

  bool get isReplying => replyToId != null;

  @override
  List<Object?> get props => [
        conversationId,
        messages,
        replyToId,
        replyToContent,
        replyToSenderName,
        isTyping,
      ];

  MessageLoaded copyWith({
    int? conversationId,
    List<MessageModel>? messages,
    int? replyToId,
    String? replyToContent,
    String? replyToSenderName,
    bool? isTyping,
    bool clearReply = false,
  }) {
    return MessageLoaded(
      conversationId: conversationId ?? this.conversationId,
      messages: messages ?? this.messages,
      replyToId: clearReply ? null : (replyToId ?? this.replyToId),
      replyToContent: clearReply ? null : (replyToContent ?? this.replyToContent),
      replyToSenderName: clearReply ? null : (replyToSenderName ?? this.replyToSenderName),
      isTyping: isTyping ?? this.isTyping,
    );
  }

  @override
  String toString() =>
      'MessageLoaded(conversationId: $conversationId, messages: ${messages.length}, isReplying: $isReplying)';
}

// ==================== SENDING STATE ====================

class MessageSending extends MessageState {
  final int conversationId;
  final String content;
  final List<MessageModel> currentMessages;

  const MessageSending({
    required this.conversationId,
    required this.content,
    required this.currentMessages,
  });

  @override
  List<Object?> get props => [conversationId, content, currentMessages];

  @override
  String toString() => 'MessageSending(conversationId: $conversationId)';
}

class MessageSent extends MessageState {
  final MessageModel message;

  const MessageSent({required this.message});

  @override
  List<Object?> get props => [message];

  @override
  String toString() => 'MessageSent(messageId: ${message.id})';
}

// ==================== UPDATING STATE ====================

class MessageUpdating extends MessageState {
  final int conversationId;
  final int messageId;

  const MessageUpdating({
    required this.conversationId,
    required this.messageId,
  });

  @override
  List<Object?> get props => [conversationId, messageId];

  @override
  String toString() =>
      'MessageUpdating(conversationId: $conversationId, messageId: $messageId)';
}

class MessageUpdated extends MessageState {
  final MessageModel message;

  const MessageUpdated({required this.message});

  @override
  List<Object?> get props => [message];

  @override
  String toString() => 'MessageUpdated(messageId: ${message.id})';
}

// ==================== DELETING STATE ====================

class MessageDeleting extends MessageState {
  final int conversationId;
  final int messageId;

  const MessageDeleting({
    required this.conversationId,
    required this.messageId,
  });

  @override
  List<Object?> get props => [conversationId, messageId];

  @override
  String toString() =>
      'MessageDeleting(conversationId: $conversationId, messageId: $messageId)';
}

class MessageDeleted extends MessageState {
  final int conversationId;
  final int messageId;

  const MessageDeleted({
    required this.conversationId,
    required this.messageId,
  });

  @override
  List<Object?> get props => [conversationId, messageId];

  @override
  String toString() =>
      'MessageDeleted(conversationId: $conversationId, messageId: $messageId)';
}

// ==================== ERROR STATE ====================

class MessageError extends MessageState {
  final String message;
  final String? errorCode;
  final dynamic error;

  const MessageError({
    required this.message,
    this.errorCode,
    this.error,
  });

  @override
  List<Object?> get props => [message, errorCode, error];

  @override
  String toString() => 'MessageError(message: $message, code: $errorCode)';
}

// ==================== EMPTY STATE ====================

class MessageEmpty extends MessageState {
  final int conversationId;

  const MessageEmpty({required this.conversationId});

  @override
  List<Object?> get props => [conversationId];

  @override
  String toString() => 'MessageEmpty(conversationId: $conversationId)';
}