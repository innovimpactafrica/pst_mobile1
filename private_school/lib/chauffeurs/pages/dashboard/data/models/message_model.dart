class MessageModel {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderType; 
  final String content;
  final DateTime createdAt;
  final bool isRead;
  final String? senderName;
  final String? senderAvatar;

  MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderType,
    required this.content,
    required this.createdAt,
    required this.isRead,
    this.senderName,
    this.senderAvatar,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id']?.toString() ?? '',
      conversationId: json['conversation_id']?.toString() ?? '',
      senderId: json['sender_id']?.toString() ?? '',
      senderType: json['sender_type'] ?? 'driver',
      content: json['content'] ?? '',
      createdAt: json['created_at'] != null 
        ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
        : DateTime.now(),
      isRead: json['is_read'] ?? false,
      senderName: json['sender_name'],
      senderAvatar: json['sender_avatar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'sender_id': senderId,
      'sender_type': senderType,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'is_read': isRead,
      'sender_name': senderName,
      'sender_avatar': senderAvatar,
    };
  }

  bool get isFromCurrentUser => senderType == 'driver';
}