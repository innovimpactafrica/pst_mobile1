import 'package:equatable/equatable.dart';
import '../../data/models/conversation_model.dart';

abstract class ConversationState extends Equatable {
  const ConversationState();

  @override
  List<Object?> get props => [];
}

// ==================== INITIAL STATE ====================

class ConversationInitial extends ConversationState {
  const ConversationInitial();

  @override
  String toString() => 'ConversationInitial';
}

// ==================== LOADING STATES ====================

class ConversationLoading extends ConversationState {
  const ConversationLoading();

  @override
  String toString() => 'ConversationLoading';
}

class ConversationRefreshing extends ConversationState {
  final List<ConversationModel> currentConversations;

  const ConversationRefreshing({required this.currentConversations});

  @override
  List<Object?> get props => [currentConversations];

  @override
  String toString() =>
      'ConversationRefreshing(${currentConversations.length} conversations)';
}

// ==================== LOADED STATE ====================

class ConversationLoaded extends ConversationState {
  final List<ConversationModel> conversations;
  final List<ConversationModel> filteredConversations;
  final bool showArchived;
  final String searchQuery;

  const ConversationLoaded({
    required this.conversations,
    List<ConversationModel>? filteredConversations,
    this.showArchived = false,
    this.searchQuery = '',
  }) : filteredConversations = filteredConversations ?? conversations;

  // Getters pour faciliter l'accès
  List<ConversationModel> get activeConversations =>
      conversations.where((c) => !c.isArchived).toList();

  List<ConversationModel> get archivedConversations =>
      conversations.where((c) => c.isArchived).toList();

  List<ConversationModel> get displayedConversations {
    final source = showArchived ? archivedConversations : activeConversations;
    if (searchQuery.isEmpty) {
      return source;
    }
    return filteredConversations;
  }

  int get unreadCount => conversations
      .where((c) => !c.isArchived)
      .fold(0, (sum, c) => sum + c.unreadCount);

  @override
  List<Object?> get props => [
    conversations,
    filteredConversations,
    showArchived,
    searchQuery,
  ];

  ConversationLoaded copyWith({
    List<ConversationModel>? conversations,
    List<ConversationModel>? filteredConversations,
    bool? showArchived,
    String? searchQuery,
  }) {
    return ConversationLoaded(
      conversations: conversations ?? this.conversations,
      filteredConversations:
          filteredConversations ?? this.filteredConversations,
      showArchived: showArchived ?? this.showArchived,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  String toString() =>
      'ConversationLoaded(total: ${conversations.length}, active: ${activeConversations.length}, archived: ${archivedConversations.length}, unread: $unreadCount)';
}

// ==================== OPERATION STATES ====================

class ConversationCreating extends ConversationState {
  const ConversationCreating();

  @override
  String toString() => 'ConversationCreating';
}

class ConversationCreated extends ConversationState {
  final ConversationModel conversation;

  const ConversationCreated({required this.conversation});

  @override
  List<Object?> get props => [conversation];

  @override
  String toString() => 'ConversationCreated(${conversation.displayName})';
}

class ConversationUpdating extends ConversationState {
  final int conversationId;

  const ConversationUpdating({required this.conversationId});

  @override
  List<Object?> get props => [conversationId];

  @override
  String toString() => 'ConversationUpdating(conversationId: $conversationId)';
}

class ConversationUpdated extends ConversationState {
  final ConversationModel conversation;
  final String action;

  const ConversationUpdated({required this.conversation, required this.action});

  @override
  List<Object?> get props => [conversation, action];

  @override
  String toString() =>
      'ConversationUpdated(${conversation.displayName}, action: $action)';
}

// ==================== ERROR STATE ====================

class ConversationError extends ConversationState {
  final String message;
  final String? errorCode;
  final dynamic error;

  const ConversationError({required this.message, this.errorCode, this.error});

  @override
  List<Object?> get props => [message, errorCode, error];

  @override
  String toString() => 'ConversationError(message: $message, code: $errorCode)';
}

// ==================== EMPTY STATE ====================

class ConversationEmpty extends ConversationState {
  final bool showArchived;

  const ConversationEmpty({this.showArchived = false});

  @override
  List<Object?> get props => [showArchived];

  @override
  String toString() => 'ConversationEmpty(showArchived: $showArchived)';
}
