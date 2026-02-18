class ConversationModel {
  final String id;
  final String displayName;
  final String? displayAvatar;
  final String lastMessagePreview;
  final String timeAgo;
  final int unreadCount;
  final DateTime? lastMessageTime;
  final String participantId;
  final String participantType; // 'parent' ou 'admin'

  ConversationModel({
    required this.id,
    required this.displayName,
    this.displayAvatar,
    required this.lastMessagePreview,
    required this.timeAgo,
    required this.unreadCount,
    this.lastMessageTime,
    required this.participantId,
    required this.participantType,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id']?.toString() ?? '',
      displayName: json['display_name'] ?? json['participant_name'] ?? 'Utilisateur',
      displayAvatar: json['display_avatar'] ?? json['participant_avatar'],
      lastMessagePreview: json['last_message_preview'] ?? json['last_message'] ?? '',
      timeAgo: json['time_ago'] ?? '',
      unreadCount: json['unread_count'] ?? 0,
      lastMessageTime: json['last_message_time'] != null 
        ? DateTime.tryParse(json['last_message_time']) 
        : null,
      participantId: json['participant_id']?.toString() ?? '',
      participantType: json['participant_type'] ?? 'parent',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'display_name': displayName,
      'display_avatar': displayAvatar,
      'last_message_preview': lastMessagePreview,
      'time_ago': timeAgo,
      'unread_count': unreadCount,
      'last_message_time': lastMessageTime?.toIso8601String(),
      'participant_id': participantId,
      'participant_type': participantType,
    };
  }
}