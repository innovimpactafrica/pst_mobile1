abstract class MessageEvent {}

class LoadMessagesEvent extends MessageEvent {
  final String conversationId;
  LoadMessagesEvent(this.conversationId);
}

class SendMessageEvent extends MessageEvent {
  final String conversationId;
  final String content;
  SendMessageEvent(this.conversationId, this.content);
}

class RefreshMessagesEvent extends MessageEvent {
  final String conversationId;
  RefreshMessagesEvent(this.conversationId);
}