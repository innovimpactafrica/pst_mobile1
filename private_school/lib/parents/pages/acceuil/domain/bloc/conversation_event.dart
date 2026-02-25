import 'package:equatable/equatable.dart';

abstract class ConversationEvent extends Equatable {
  const ConversationEvent();

  @override
  List<Object?> get props => [];
}

// ==================== LOAD CONVERSATIONS ====================

class LoadConversationsEvent extends ConversationEvent {
  const LoadConversationsEvent();

  @override
  String toString() => 'LoadConversationsEvent';
}

class RefreshConversationsEvent extends ConversationEvent {
  const RefreshConversationsEvent();

  @override
  String toString() => 'RefreshConversationsEvent';
}

class EnrichConversationsWithAvatarsEvent extends ConversationEvent {
  final List<Map<String, dynamic>> drivers;
  const EnrichConversationsWithAvatarsEvent({required this.drivers});
}

// ==================== CREATE CONVERSATION ====================

class CreateDirectConversationEvent extends ConversationEvent {
  final int otherUserId;
  final String? initialMessage;
  final String? otherUserAvatar;
  const CreateDirectConversationEvent({
    required this.otherUserId,
    this.initialMessage,
    this.otherUserAvatar,
  });

  @override
  List<Object?> get props => [otherUserId, initialMessage];
}

class CreateGroupConversationEvent extends ConversationEvent {
  final String name;
  final List<int> memberIds;

  const CreateGroupConversationEvent({
    required this.name,
    required this.memberIds,
  });

  @override
  List<Object?> get props => [name, memberIds];

  @override
  String toString() =>
      'CreateGroupConversationEvent(name: $name, members: ${memberIds.length})';
}

// ==================== ARCHIVE/MUTE CONVERSATION ====================

class ArchiveConversationEvent extends ConversationEvent {
  final int conversationId;

  const ArchiveConversationEvent({required this.conversationId});

  @override
  List<Object?> get props => [conversationId];

  @override
  String toString() =>
      'ArchiveConversationEvent(conversationId: $conversationId)';
}

class UnarchiveConversationEvent extends ConversationEvent {
  final int conversationId;

  const UnarchiveConversationEvent({required this.conversationId});

  @override
  List<Object?> get props => [conversationId];

  @override
  String toString() =>
      'UnarchiveConversationEvent(conversationId: $conversationId)';
}

class MuteConversationEvent extends ConversationEvent {
  final int conversationId;

  const MuteConversationEvent({required this.conversationId});

  @override
  List<Object?> get props => [conversationId];

  @override
  String toString() => 'MuteConversationEvent(conversationId: $conversationId)';
}

class UnmuteConversationEvent extends ConversationEvent {
  final int conversationId;

  const UnmuteConversationEvent({required this.conversationId});

  @override
  List<Object?> get props => [conversationId];

  @override
  String toString() =>
      'UnmuteConversationEvent(conversationId: $conversationId)';
}

// ==================== FILTER/SEARCH CONVERSATIONS ====================

class FilterConversationsEvent extends ConversationEvent {
  final String query;

  const FilterConversationsEvent({required this.query});

  @override
  List<Object?> get props => [query];

  @override
  String toString() => 'FilterConversationsEvent(query: $query)';
}

class ShowArchivedConversationsEvent extends ConversationEvent {
  const ShowArchivedConversationsEvent();

  @override
  String toString() => 'ShowArchivedConversationsEvent';
}

class ShowActiveConversationsEvent extends ConversationEvent {
  const ShowActiveConversationsEvent();

  @override
  String toString() => 'ShowActiveConversationsEvent';
}
