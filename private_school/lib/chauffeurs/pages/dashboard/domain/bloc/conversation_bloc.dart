import 'package:flutter_bloc/flutter_bloc.dart';
import 'conversation_event.dart';
import 'conversation_state.dart';
import '../../data/services/messaging_service.dart';

class ConversationBloc extends Bloc<ConversationEvent, ConversationState> {
  final MessagingService _messagingService = MessagingService();

  ConversationBloc() : super(ConversationInitial()) {
    on<LoadConversationsEvent>(_onLoadConversations);
    on<RefreshConversationsEvent>(_onRefreshConversations);
    on<CreateConversationEvent>(_onCreateConversation);
    on<MarkConversationAsReadEvent>(_onMarkAsRead);
  }

  Future<void> _onLoadConversations(
    LoadConversationsEvent event,
    Emitter<ConversationState> emit,
  ) async {
    emit(ConversationLoading());
    try {
      final conversations = await _messagingService.getConversations();
      emit(ConversationLoaded(conversations));
    } catch (e) {
      emit(ConversationError('Erreur lors du chargement des conversations'));
    }
  }

  Future<void> _onRefreshConversations(
    RefreshConversationsEvent event,
    Emitter<ConversationState> emit,
  ) async {
    try {
      final conversations = await _messagingService.getConversations();
      emit(ConversationLoaded(conversations));
    } catch (e) {
      emit(ConversationError('Erreur lors du rafraîchissement'));
    }
  }

  Future<void> _onCreateConversation(
    CreateConversationEvent event,
    Emitter<ConversationState> emit,
  ) async {
    try {
      final conversation = await _messagingService
          .createOrGetDirectConversation(otherUserId: event.parentId);
      if (conversation != null) {
        emit(ConversationCreated(conversation));
        add(LoadConversationsEvent());
      } else {
        emit(ConversationError('Impossible de créer la conversation'));
      }
    } catch (e) {
      emit(ConversationError('Erreur lors de la création'));
    }
  }

  Future<void> _onMarkAsRead(
    MarkConversationAsReadEvent event,
    Emitter<ConversationState> emit,
  ) async {
    try {
      await _messagingService.markConversationAsRead(event.conversationId);

      add(RefreshConversationsEvent());
    } catch (e) {
      //
    }
  }
}
