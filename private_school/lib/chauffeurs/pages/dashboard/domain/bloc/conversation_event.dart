abstract class ConversationEvent {}

class LoadConversationsEvent extends ConversationEvent {}

class RefreshConversationsEvent extends ConversationEvent {}

class CreateConversationEvent extends ConversationEvent {
  final String parentId;
  CreateConversationEvent(this.parentId);
}

class MarkConversationAsReadEvent extends ConversationEvent {
  final String conversationId;
  MarkConversationAsReadEvent(this.conversationId);
}