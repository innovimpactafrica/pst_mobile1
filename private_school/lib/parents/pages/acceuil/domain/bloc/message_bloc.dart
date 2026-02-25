// Message BLoC - State Management Layer
// Path: parents/pages/acceuil/domain/bloc/message_bloc.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/messaging_repository.dart';
import '../../data/models/message_model.dart';
import 'message_event.dart';
import 'message_state.dart';

class MessageBloc extends Bloc<MessageEvent, MessageState> {
  final MessagingRepository repository;

  MessageBloc({MessagingRepository? repository})
      : repository = repository ?? MessagingRepository(),
        super(const MessageInitial()) {
    on<LoadMessagesEvent>(_onLoadMessages);
    on<RefreshMessagesEvent>(_onRefreshMessages);
    on<SendMessageEvent>(_onSendMessage);
    on<UpdateMessageEvent>(_onUpdateMessage);
    on<DeleteMessageEvent>(_onDeleteMessage);
    on<SetReplyToMessageEvent>(_onSetReplyTo);
    on<CancelReplyToMessageEvent>(_onCancelReplyTo);
    on<UserTypingEvent>(_onUserTyping);
    on<ResetMessagesEvent>(_onResetMessages);
  }

  // ==================== LOAD MESSAGES ====================

  Future<void> _onLoadMessages(
    LoadMessagesEvent event,
    Emitter<MessageState> emit,
  ) async {
    debugPrint('🔄 MessageBloc._onLoadMessages - START');
    debugPrint('💬 conversationId: ${event.conversationId}');

    emit(MessageLoading(conversationId: event.conversationId));

    try {
      final messages = await repository.getMessages(event.conversationId);
      debugPrint('✅ ${messages.length} messages chargés');

      if (messages.isEmpty) {
        emit(MessageEmpty(conversationId: event.conversationId));
      } else {
        // Trier par date (les plus anciens en premier pour l'affichage)
        messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));

        emit(MessageLoaded(
          conversationId: event.conversationId,
          messages: messages,
        ));
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Erreur lors du chargement des messages: $e');
      debugPrint('📋 StackTrace: $stackTrace');
      emit(MessageError(
        message: 'Impossible de charger les messages',
        error: e,
      ));
    }
  }

 Future<void> _onRefreshMessages(
    RefreshMessagesEvent event,
    Emitter<MessageState> emit,
  ) async {
    debugPrint('🔄 MessageBloc._onRefreshMessages - START');
    debugPrint('💬 conversationId: ${event.conversationId}');

    // ✅ Garder l'état actuel visible pendant le refresh (jamais de MessageEmpty)
    final currentState = state;

    try {
      final messages = await repository.getMessages(event.conversationId);
      debugPrint('✅ ${messages.length} messages rafraîchis');

      messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      if (currentState is MessageLoaded) {
        emit(MessageLoaded(
          conversationId: event.conversationId,
          messages: messages,
          replyToId: currentState.replyToId,
          replyToContent: currentState.replyToContent,
          replyToSenderName: currentState.replyToSenderName,
        ));
      } else {
        emit(MessageLoaded(
          conversationId: event.conversationId,
          messages: messages,
        ));
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Erreur lors du rafraîchissement: $e');
      debugPrint('📋 StackTrace: $stackTrace');

      if (currentState is MessageLoaded) {
        emit(currentState);
      } else {
        emit(MessageError(
          message: 'Impossible de rafraîchir les messages',
          error: e,
        ));
      }
    }
  }

  // ==================== SEND MESSAGE ====================

 Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<MessageState> emit,
  ) async {
    debugPrint('🔄 MessageBloc._onSendMessage - START');

    final currentState = state;
    List<MessageModel> currentMessages = [];
    if (currentState is MessageLoaded &&
        currentState.conversationId == event.conversationId) {
      currentMessages = List.from(currentState.messages);
    }

    // ✅ Message temporaire affiché immédiatement
    final tempMessage = MessageModel(
      id: -1,
      conversationId: event.conversationId,
      senderId: event.currentUserId,
      senderName: '',
      senderRole: 'parent',
      content: event.content,
      isEdited: false,
      isDeleted: false,
      createdAt: DateTime.now(),
    );

    if (currentState is MessageLoaded) {
      emit(currentState.copyWith(
        messages: [...currentMessages, tempMessage],
        clearReply: true,
      ));
    }

    try {
      final message = await repository.sendMessage(
        conversationId: event.conversationId,
        content: event.content,
        replyToId: event.replyToId,
      );
      debugPrint('✅ Message envoyé: ${message.id}');

      // ✅ Remplacer le message temporaire par le vrai
      final finalMessages = [
        ...currentMessages,
        message,
      ];

      if (currentState is MessageLoaded) {
        emit(currentState.copyWith(messages: finalMessages));
      }

      add(RefreshMessagesEvent(conversationId: event.conversationId));
      emit(MessageSent(message: message));
    } catch (e, stackTrace) {
      debugPrint('❌ Erreur lors de l\'envoi: $e');
      debugPrint('📋 StackTrace: $stackTrace');

      // Rollback
      if (currentState is MessageLoaded) {
        emit(currentState);
      }
      emit(MessageError(
        message: 'Impossible d\'envoyer le message',
        error: e,
      ));
    }
  }

  // ==================== UPDATE MESSAGE ====================

 Future<void> _onUpdateMessage(
    UpdateMessageEvent event,
    Emitter<MessageState> emit,
  ) async {
    debugPrint('🔄 MessageBloc._onUpdateMessage - START');
    debugPrint('💬 conversationId: ${event.conversationId}, messageId: ${event.messageId}');

    final currentState = state;
    if (currentState is! MessageLoaded) return;

    // ✅ Mise à jour immédiate de l'UI (optimistic update)
    final updatedMessages = currentState.messages.map((msg) {
      if (msg.id == event.messageId) {
        return msg.copyWith(content: event.content, isEdited: true);
      }
      return msg;
    }).toList();

    emit(currentState.copyWith(messages: updatedMessages));

    // Appel API en arrière-plan
    try {
      await repository.updateMessage(
        conversationId: event.conversationId,
        messageId: event.messageId,
        content: event.content,
      );
      debugPrint('✅ Message modifié côté serveur');
      add(RefreshMessagesEvent(conversationId: event.conversationId));
    } catch (e, stackTrace) {
      debugPrint('❌ Erreur lors de la modification: $e');
      debugPrint('📋 StackTrace: $stackTrace');
      // Rollback en cas d'erreur
      emit(currentState);
      emit(MessageError(message: 'Impossible de modifier le message', error: e));
    }
  }

  // ==================== DELETE MESSAGE ====================

  Future<void> _onDeleteMessage(
    DeleteMessageEvent event,
    Emitter<MessageState> emit,
  ) async {
    debugPrint('🔄 MessageBloc._onDeleteMessage - START');
    debugPrint('💬 conversationId: ${event.conversationId}, messageId: ${event.messageId}');

    final currentState = state;
    if (currentState is! MessageLoaded) return;

    // ✅ Suppression immédiate de l'UI (optimistic update)
    final updatedMessages = currentState.messages
        .where((msg) => msg.id != event.messageId)
        .toList();

    emit(currentState.copyWith(messages: updatedMessages));

    // Appel API en arrière-plan
    try {
      await repository.deleteMessage(
        conversationId: event.conversationId,
        messageId: event.messageId,
      );
      debugPrint('✅ Message supprimé côté serveur');
      add(RefreshMessagesEvent(conversationId: event.conversationId));
    } catch (e, stackTrace) {
      debugPrint('❌ Erreur lors de la suppression: $e');
      debugPrint('📋 StackTrace: $stackTrace');
      // Rollback en cas d'erreur
      emit(currentState);
      emit(MessageError(message: 'Impossible de supprimer le message', error: e));
    }
  }

  // ==================== REPLY TO MESSAGE ====================

  void _onSetReplyTo(
    SetReplyToMessageEvent event,
    Emitter<MessageState> emit,
  ) {
    debugPrint('🔄 MessageBloc._onSetReplyTo - START');
    debugPrint('💬 messageId: ${event.messageId}');

    final currentState = state;
    if (currentState is MessageLoaded) {
      emit(currentState.copyWith(
        replyToId: event.messageId,
        replyToContent: event.messageContent,
        replyToSenderName: event.senderName,
      ));
    }
  }

  void _onCancelReplyTo(
    CancelReplyToMessageEvent event,
    Emitter<MessageState> emit,
  ) {
    debugPrint('🔄 MessageBloc._onCancelReplyTo - START');

    final currentState = state;
    if (currentState is MessageLoaded) {
      emit(currentState.copyWith(clearReply: true));
    }
  }

  // ==================== TYPING INDICATOR ====================

  void _onUserTyping(
    UserTypingEvent event,
    Emitter<MessageState> emit,
  ) {
    final currentState = state;
    if (currentState is MessageLoaded) {
      emit(currentState.copyWith(isTyping: event.isTyping));
    }
  }

  // ==================== RESET ====================

  void _onResetMessages(
    ResetMessagesEvent event,
    Emitter<MessageState> emit,
  ) {
    debugPrint('🔄 MessageBloc._onResetMessages - START');
    emit(const MessageInitial());
  }
}