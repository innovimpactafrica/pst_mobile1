// Conversation BLoC - State Management Layer
// Path: parents/pages/acceuil/domain/bloc/conversation_bloc.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/messaging_repository.dart';
import 'conversation_event.dart';
import 'conversation_state.dart';

class ConversationBloc extends Bloc<ConversationEvent, ConversationState> {
  final MessagingRepository repository;

  ConversationBloc({MessagingRepository? repository})
      : repository = repository ?? MessagingRepository(),
        super(const ConversationInitial()) {
    on<LoadConversationsEvent>(_onLoadConversations);
    on<RefreshConversationsEvent>(_onRefreshConversations);
    on<CreateDirectConversationEvent>(_onCreateDirectConversation);
    on<CreateGroupConversationEvent>(_onCreateGroupConversation);
    on<ArchiveConversationEvent>(_onArchiveConversation);
    on<UnarchiveConversationEvent>(_onUnarchiveConversation);
    on<MuteConversationEvent>(_onMuteConversation);
    on<UnmuteConversationEvent>(_onUnmuteConversation);
    on<FilterConversationsEvent>(_onFilterConversations);
    on<ShowArchivedConversationsEvent>(_onShowArchivedConversations);
    on<ShowActiveConversationsEvent>(_onShowActiveConversations);
  }

  // ==================== LOAD CONVERSATIONS ====================

  Future<void> _onLoadConversations(
    LoadConversationsEvent event,
    Emitter<ConversationState> emit,
  ) async {
    debugPrint('🔄 ConversationBloc._onLoadConversations - START');
    
    emit(const ConversationLoading());

    try {
      final conversations = await repository.getConversations();
      debugPrint('✅ ${conversations.length} conversations chargées');

      if (conversations.isEmpty) {
        emit(const ConversationEmpty());
      } else {
        // Trier par date du dernier message (les plus récents en premier)
        conversations.sort((a, b) {
          if (a.lastMessageTime == null && b.lastMessageTime == null) return 0;
          if (a.lastMessageTime == null) return 1;
          if (b.lastMessageTime == null) return -1;
          return b.lastMessageTime!.compareTo(a.lastMessageTime!);
        });

        emit(ConversationLoaded(conversations: conversations));
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Erreur lors du chargement des conversations: $e');
      debugPrint('📋 StackTrace: $stackTrace');
      emit(ConversationError(
        message: 'Impossible de charger les conversations',
        error: e,
      ));
    }
  }

  Future<void> _onRefreshConversations(
    RefreshConversationsEvent event,
    Emitter<ConversationState> emit,
  ) async {
    debugPrint('🔄 ConversationBloc._onRefreshConversations - START');

    // Garder les conversations actuelles pendant le refresh
    final currentState = state;
    if (currentState is ConversationLoaded) {
      emit(ConversationRefreshing(currentConversations: currentState.conversations));
    }

    try {
      final conversations = await repository.getConversations();
      debugPrint('✅ ${conversations.length} conversations rafraîchies');

      if (conversations.isEmpty) {
        emit(const ConversationEmpty());
      } else {
        conversations.sort((a, b) {
          if (a.lastMessageTime == null && b.lastMessageTime == null) return 0;
          if (a.lastMessageTime == null) return 1;
          if (b.lastMessageTime == null) return -1;
          return b.lastMessageTime!.compareTo(a.lastMessageTime!);
        });

        emit(ConversationLoaded(conversations: conversations));
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Erreur lors du rafraîchissement: $e');
      debugPrint('📋 StackTrace: $stackTrace');
      
      // Remettre l'état précédent en cas d'erreur
      if (currentState is ConversationLoaded) {
        emit(currentState);
      } else {
        emit(ConversationError(
          message: 'Impossible de rafraîchir les conversations',
          error: e,
        ));
      }
    }
  }

  // ==================== CREATE CONVERSATIONS ====================

  Future<void> _onCreateDirectConversation(
    CreateDirectConversationEvent event,
    Emitter<ConversationState> emit,
  ) async {
    debugPrint('🔄 ConversationBloc._onCreateDirectConversation - START');
    debugPrint('👤 otherUserId: ${event.otherUserId}');

    emit(const ConversationCreating());

    try {
      final conversation = await repository.createOrGetDirectConversation(
        otherUserId: event.otherUserId,
      );
      debugPrint('✅ Conversation directe créée: ${conversation.displayName}');

      emit(ConversationCreated(conversation: conversation));

      // Recharger toutes les conversations
      add(const LoadConversationsEvent());
    } catch (e, stackTrace) {
      debugPrint('❌ Erreur lors de la création de la conversation: $e');
      debugPrint('📋 StackTrace: $stackTrace');
      emit(ConversationError(
        message: 'Impossible de créer la conversation',
        error: e,
      ));
    }
  }

  Future<void> _onCreateGroupConversation(
    CreateGroupConversationEvent event,
    Emitter<ConversationState> emit,
  ) async {
    debugPrint('🔄 ConversationBloc._onCreateGroupConversation - START');
    debugPrint('📛 Nom: ${event.name}, Membres: ${event.memberIds.length}');

    emit(const ConversationCreating());

    try {
      final conversation = await repository.createGroupConversation(
        name: event.name,
        memberIds: event.memberIds,
      );
      debugPrint('✅ Conversation de groupe créée: ${conversation.displayName}');

      emit(ConversationCreated(conversation: conversation));

      // Recharger toutes les conversations
      add(const LoadConversationsEvent());
    } catch (e, stackTrace) {
      debugPrint('❌ Erreur lors de la création du groupe: $e');
      debugPrint('📋 StackTrace: $stackTrace');
      emit(ConversationError(
        message: 'Impossible de créer le groupe',
        error: e,
      ));
    }
  }

  // ==================== ARCHIVE CONVERSATIONS ====================

  Future<void> _onArchiveConversation(
    ArchiveConversationEvent event,
    Emitter<ConversationState> emit,
  ) async {
    debugPrint('🔄 ConversationBloc._onArchiveConversation - START');
    debugPrint('💬 conversationId: ${event.conversationId}');

    final currentState = state;
    if (currentState is! ConversationLoaded) return;

    emit(ConversationUpdating(conversationId: event.conversationId));

    try {
      await repository.archiveConversation(event.conversationId);
      debugPrint('✅ Conversation archivée');

      // Mettre à jour la conversation dans la liste
      final updatedConversations = currentState.conversations.map((c) {
        if (c.id == event.conversationId) {
          return c.copyWith(isArchived: true);
        }
        return c;
      }).toList();

      final updatedConversation = updatedConversations.firstWhere(
        (c) => c.id == event.conversationId,
      );

      emit(ConversationUpdated(
        conversation: updatedConversation,
        action: 'archived',
      ));

      emit(currentState.copyWith(conversations: updatedConversations));
    } catch (e, stackTrace) {
      debugPrint('❌ Erreur lors de l\'archivage: $e');
      debugPrint('📋 StackTrace: $stackTrace');
      emit(currentState);
      emit(ConversationError(
        message: 'Impossible d\'archiver la conversation',
        error: e,
      ));
    }
  }

  Future<void> _onUnarchiveConversation(
    UnarchiveConversationEvent event,
    Emitter<ConversationState> emit,
  ) async {
    debugPrint('🔄 ConversationBloc._onUnarchiveConversation - START');
    debugPrint('💬 conversationId: ${event.conversationId}');

    final currentState = state;
    if (currentState is! ConversationLoaded) return;

    emit(ConversationUpdating(conversationId: event.conversationId));

    try {
      await repository.unarchiveConversation(event.conversationId);
      debugPrint('✅ Conversation désarchivée');

      final updatedConversations = currentState.conversations.map((c) {
        if (c.id == event.conversationId) {
          return c.copyWith(isArchived: false);
        }
        return c;
      }).toList();

      final updatedConversation = updatedConversations.firstWhere(
        (c) => c.id == event.conversationId,
      );

      emit(ConversationUpdated(
        conversation: updatedConversation,
        action: 'unarchived',
      ));

      emit(currentState.copyWith(conversations: updatedConversations));
    } catch (e, stackTrace) {
      debugPrint('❌ Erreur lors du désarchivage: $e');
      debugPrint('📋 StackTrace: $stackTrace');
      emit(currentState);
      emit(ConversationError(
        message: 'Impossible de désarchiver la conversation',
        error: e,
      ));
    }
  }

  // ==================== MUTE CONVERSATIONS ====================

  Future<void> _onMuteConversation(
    MuteConversationEvent event,
    Emitter<ConversationState> emit,
  ) async {
    debugPrint('🔄 ConversationBloc._onMuteConversation - START');
    debugPrint('💬 conversationId: ${event.conversationId}');

    final currentState = state;
    if (currentState is! ConversationLoaded) return;

    emit(ConversationUpdating(conversationId: event.conversationId));

    try {
      await repository.muteConversation(event.conversationId);
      debugPrint('✅ Conversation en sourdine');

      final updatedConversations = currentState.conversations.map((c) {
        if (c.id == event.conversationId) {
          return c.copyWith(isMuted: true);
        }
        return c;
      }).toList();

      final updatedConversation = updatedConversations.firstWhere(
        (c) => c.id == event.conversationId,
      );

      emit(ConversationUpdated(
        conversation: updatedConversation,
        action: 'muted',
      ));

      emit(currentState.copyWith(conversations: updatedConversations));
    } catch (e, stackTrace) {
      debugPrint('❌ Erreur lors de la mise en sourdine: $e');
      debugPrint('📋 StackTrace: $stackTrace');
      emit(currentState);
      emit(ConversationError(
        message: 'Impossible de mettre en sourdine',
        error: e,
      ));
    }
  }

  Future<void> _onUnmuteConversation(
    UnmuteConversationEvent event,
    Emitter<ConversationState> emit,
  ) async {
    debugPrint('🔄 ConversationBloc._onUnmuteConversation - START');
    debugPrint('💬 conversationId: ${event.conversationId}');

    final currentState = state;
    if (currentState is! ConversationLoaded) return;

    emit(ConversationUpdating(conversationId: event.conversationId));

    try {
      await repository.unmuteConversation(event.conversationId);
      debugPrint('✅ Sourdine désactivée');

      final updatedConversations = currentState.conversations.map((c) {
        if (c.id == event.conversationId) {
          return c.copyWith(isMuted: false);
        }
        return c;
      }).toList();

      final updatedConversation = updatedConversations.firstWhere(
        (c) => c.id == event.conversationId,
      );

      emit(ConversationUpdated(
        conversation: updatedConversation,
        action: 'unmuted',
      ));

      emit(currentState.copyWith(conversations: updatedConversations));
    } catch (e, stackTrace) {
      debugPrint('❌ Erreur lors de la réactivation: $e');
      debugPrint('📋 StackTrace: $stackTrace');
      emit(currentState);
      emit(ConversationError(
        message: 'Impossible de réactiver les notifications',
        error: e,
      ));
    }
  }

  // ==================== FILTER CONVERSATIONS ====================

  void _onFilterConversations(
    FilterConversationsEvent event,
    Emitter<ConversationState> emit,
  ) {
    debugPrint('🔄 ConversationBloc._onFilterConversations - START');
    debugPrint('🔍 Query: ${event.query}');

    final currentState = state;
    if (currentState is! ConversationLoaded) return;

    if (event.query.isEmpty) {
      emit(currentState.copyWith(
        searchQuery: '',
        filteredConversations: currentState.conversations,
      ));
      return;
    }

    final query = event.query.toLowerCase();
    final filtered = currentState.conversations.where((c) {
      return c.displayName.toLowerCase().contains(query) ||
          (c.lastMessageContent?.toLowerCase().contains(query) ?? false);
    }).toList();

    debugPrint('✅ ${filtered.length} conversations filtrées');

    emit(currentState.copyWith(
      searchQuery: event.query,
      filteredConversations: filtered,
    ));
  }

  // ==================== SHOW ARCHIVED ====================

  void _onShowArchivedConversations(
    ShowArchivedConversationsEvent event,
    Emitter<ConversationState> emit,
  ) {
    debugPrint('🔄 ConversationBloc._onShowArchivedConversations - START');

    final currentState = state;
    if (currentState is! ConversationLoaded) return;

    emit(currentState.copyWith(showArchived: true));
  }

  void _onShowActiveConversations(
    ShowActiveConversationsEvent event,
    Emitter<ConversationState> emit,
  ) {
    debugPrint('🔄 ConversationBloc._onShowActiveConversations - START');

    final currentState = state;
    if (currentState is! ConversationLoaded) return;

    emit(currentState.copyWith(showArchived: false));
  }
}