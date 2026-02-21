abstract class ConversationEvent {}

class LoadConversationsEvent extends ConversationEvent {}

class RefreshConversationsEvent extends ConversationEvent {}

class CreateConversationEvent extends ConversationEvent {
  final int parentId;
  CreateConversationEvent(this.parentId);
}

class MarkConversationAsReadEvent extends ConversationEvent {
  final int conversationId;
  MarkConversationAsReadEvent(this.conversationId);
}