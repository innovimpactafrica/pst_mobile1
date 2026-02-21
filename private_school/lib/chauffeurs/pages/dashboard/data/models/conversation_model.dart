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
  // Calculer timeAgo depuis last_message_at
  String timeAgo = '';
  final lastMsgAt = json['last_message_at'] ?? json['last_message_time'];
  if (lastMsgAt != null) {
    final date = DateTime.tryParse(lastMsgAt);
    if (date != null) {
      final diff = DateTime.now().difference(date);
      if (diff.inMinutes < 60) {
        timeAgo = 'Il y a ${diff.inMinutes}m';
      } else if (diff.inHours < 24) {
        timeAgo = 'Il y a ${diff.inHours}h';
      } else {
        timeAgo = 'Il y a ${diff.inDays}j';
      }
    }
  }

  return ConversationModel(
    id: json['id']?.toString() ?? '',
    
    // ✅ Champs corrects selon l'API
    displayName: json['other_participant_name']    // ← correct
        ?? json['display_name'] 
        ?? json['participant_name'] 
        ?? 'Utilisateur',
        
    displayAvatar: json['other_participant_avatar'] 
        ?? json['display_avatar'] 
        ?? json['participant_avatar'],
        
    lastMessagePreview: json['last_message']        // ← correct
        ?? json['last_message_preview'] 
        ?? '',
        
    timeAgo: json['time_ago'] ?? timeAgo,           // ← calculé si absent
    
    unreadCount: json['unread_count'] ?? 0,         // ← déjà correct
    
    lastMessageTime: lastMsgAt != null 
        ? DateTime.tryParse(lastMsgAt) 
        : null,
        
    participantId: (json['other_participant_id']    // ← correct
        ?? json['participant_id'])?.toString() ?? '',
        
    participantType: json['other_participant_role'] // ← correct
        ?? json['participant_type'] 
        ?? 'parent',
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