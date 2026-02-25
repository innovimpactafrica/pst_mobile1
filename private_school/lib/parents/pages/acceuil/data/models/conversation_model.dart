

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class ConversationModel extends Equatable {
  final int id;
  final int? lastMessageId;
  final String? lastMessageContent;
  final DateTime? lastMessageTime;
  final bool isMuted;
  final bool isArchived;
  final String type; // 'direct' ou 'group'
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Participant info (pour les conversations directes)
  final int? otherUserId;
  final String? otherUserName;
  final String? otherUserAvatar;
  final String? otherUserRole; // 'parent' ou 'driver'
  
  // Group info (pour les conversations de groupe)
  final int? groupId;
  final String? groupName;
  final String? groupAvatar;
  final int? memberCount;
  
  // Message stats
  final int unreadCount;

  const ConversationModel({
    required this.id,
    this.lastMessageId,
    this.lastMessageContent,
    this.lastMessageTime,
    this.isMuted = false,
    this.isArchived = false,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    this.otherUserId,
    this.otherUserName,
    this.otherUserAvatar,
    this.otherUserRole,
    this.groupId,
    this.groupName,
    this.groupAvatar,
    this.memberCount,
    this.unreadCount = 0,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    debugPrint('📥 ConversationModel.fromJson: $json');
    
    try {
     
      final type = (json['type'] as String?) ?? 'direct';
      
    
      DateTime parseDate(dynamic value) {
        if (value == null) return DateTime.now();
        try {
          return DateTime.parse(value.toString());
        } catch (e) {
          debugPrint('⚠️ Erreur parsing date: $value');
          return DateTime.now();
        }
      }
      
      return ConversationModel(
        id: json['id'] as int,
        lastMessageId: json['last_message_id'] as int?,
        lastMessageContent: json['last_message'] as String? ?? 
                           json['last_message_content'] as String?,
        lastMessageTime: json['last_message_at'] != null 
            ? parseDate(json['last_message_at'])
            : (json['last_message_date'] != null
                ? parseDate(json['last_message_date'])
                : (json['last_message_time'] != null
                    ? parseDate(json['last_message_time'])
                    : null)),
        
        isMuted: json['is_muted'] as bool? ?? false,
        isArchived: json['is_archived'] as bool? ?? false,
        type: type,
        
        createdAt: json['created_at'] != null 
            ? parseDate(json['created_at'])
            : DateTime.now(),
        updatedAt: json['updated_at'] != null
            ? parseDate(json['updated_at'])
            : (json['last_message_at'] != null
                ? parseDate(json['last_message_at'])
                : DateTime.now()),
  
        otherUserId: json['other_participant_id'] as int? ?? 
                    json['other_user_id'] as int?,
        otherUserName: json['other_participant_name'] as String? ?? 
                      json['other_user_name'] as String?,
        otherUserAvatar: json['other_participant_avatar'] as String? ?? 
                        json['other_user_avatar'] as String?,
        otherUserRole: json['other_participant_role'] as String? ?? 
                      json['other_user_role'] as String?,
        
        
        groupId: json['group_id'] as int? ?? json['trip_id'] as int?,
        groupName: json['group_name'] as String? ?? 
                  (json['title'] as String?),
        groupAvatar: json['group_avatar'] as String?,
        memberCount: json['member_count'] != null
            ? int.tryParse(json['member_count'].toString())
            : (json['participant_count'] != null
                ? int.tryParse(json['participant_count'].toString())
                : null),
        
        unreadCount: json['unread_count'] as int? ?? 0,
      );
    } catch (e, stackTrace) {
      debugPrint('❌ Erreur lors du parsing de ConversationModel: $e');
      debugPrint('📋 StackTrace: $stackTrace');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'last_message_id': lastMessageId,
      'last_message_content': lastMessageContent,
      'last_message_time': lastMessageTime?.toIso8601String(),
      'is_muted': isMuted,
      'is_archived': isArchived,
      'type': type,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'other_user_id': otherUserId,
      'other_user_name': otherUserName,
      'other_user_avatar': otherUserAvatar,
      'other_user_role': otherUserRole,
      'group_id': groupId,
      'group_name': groupName,
      'group_avatar': groupAvatar,
      'member_count': memberCount,
      'unread_count': unreadCount,
    };
  }

  
  String get displayName {
    if (type == 'group') {
      return groupName ?? 'Groupe sans nom';
    }
    return otherUserName ?? 'Utilisateur inconnu';
  }

  String? get displayAvatar {
    if (type == 'group') {
      return groupAvatar;
    }
    return otherUserAvatar;
  }

  String get lastMessagePreview {
    if (lastMessageContent == null || lastMessageContent!.isEmpty) {
      return 'Aucun message';
    }
    if (lastMessageContent!.length > 50) {
      return '${lastMessageContent!.substring(0, 50)}...';
    }
    return lastMessageContent!;
  }

  String get timeAgo {
    if (lastMessageTime == null) return '';
    
    final now = DateTime.now();
    final difference = now.difference(lastMessageTime!);
    
    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return 'Il y a $years an${years > 1 ? 's' : ''}';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return 'Il y a $months mois';
    } else if (difference.inDays > 0) {
      return 'Il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'Il y a ${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return 'Il y a ${difference.inMinutes}min';
    } else {
      return 'À l\'instant';
    }
  }

  ConversationModel copyWith({
    int? id,
    int? lastMessageId,
    String? lastMessageContent,
    DateTime? lastMessageTime,
    bool? isMuted,
    bool? isArchived,
    String? type,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? otherUserId,
    String? otherUserName,
    String? otherUserAvatar,
    String? otherUserRole,
    int? groupId,
    String? groupName,
    String? groupAvatar,
    int? memberCount,
    int? unreadCount,
  }) {
    return ConversationModel(
      id: id ?? this.id,
      lastMessageId: lastMessageId ?? this.lastMessageId,
      lastMessageContent: lastMessageContent ?? this.lastMessageContent,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      isMuted: isMuted ?? this.isMuted,
      isArchived: isArchived ?? this.isArchived,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      otherUserId: otherUserId ?? this.otherUserId,
      otherUserName: otherUserName ?? this.otherUserName,
      otherUserAvatar: otherUserAvatar ?? this.otherUserAvatar,
      otherUserRole: otherUserRole ?? this.otherUserRole,
      groupId: groupId ?? this.groupId,
      groupName: groupName ?? this.groupName,
      groupAvatar: groupAvatar ?? this.groupAvatar,
      memberCount: memberCount ?? this.memberCount,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  @override
  List<Object?> get props => [
        id,
        lastMessageId,
        lastMessageContent,
        lastMessageTime,
        isMuted,
        isArchived,
        type,
        createdAt,
        updatedAt,
        otherUserId,
        otherUserName,
        otherUserAvatar,
        otherUserRole,
        groupId,
        groupName,
        groupAvatar,
        memberCount,
        unreadCount,
      ];

  @override
  String toString() {
    return 'ConversationModel(id: $id, type: $type, displayName: $displayName, unreadCount: $unreadCount)';
  }
}