// Message Model - CORRECTED
// Path: parents/pages/acceuil/data/models/message_model.dart

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class MessageModel extends Equatable {
  final int id;
  final int conversationId;
  final int senderId;
  final String senderName;
  final String? senderAvatar;
  final String senderRole; // 'parent' ou 'driver'
  final String content;
  final String? type; // 'text', 'image', 'file', etc.
  final bool isRead;
  final bool isEdited;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  
  // Pour les réponses/citations
  final int? replyToId;
  final String? replyToContent;
  final String? replyToSenderName;

  const MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
    required this.senderRole,
    required this.content,
    this.type = 'text',
    this.isRead = false,
    this.isEdited = false,
    this.isDeleted = false,
    required this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.replyToId,
    this.replyToContent,
    this.replyToSenderName,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    debugPrint('📥 MessageModel.fromJson: $json');
    
    try {
      // ✅ Helper pour parser les dates
      DateTime parseDate(dynamic value) {
        if (value == null) return DateTime.now();
        try {
          return DateTime.parse(value.toString());
        } catch (e) {
          debugPrint('⚠️ Erreur parsing date: $value');
          return DateTime.now();
        }
      }

      // ✅ Helper pour parser les int (gère null et String)
      int? safeInt(dynamic value) {
        if (value == null) return null;
        if (value is int) return value;
        return int.tryParse(value.toString());
      }

      return MessageModel(
        id: json['id'] as int,
        
        // ✅ FIX: conversation_id peut ne pas être dans la réponse
        conversationId: safeInt(json['conversation_id']) ?? 0,
        
        senderId: json['sender_id'] as int,
        senderName: json['sender_name'] as String? ?? 'Inconnu',
        senderAvatar: json['sender_avatar'] as String?,
        senderRole: json['sender_role'] as String? ?? 'parent',
        content: json['content'] as String? ?? '',
        
        // ✅ FIX: Mapper message_type vers type
        type: json['message_type'] as String? ?? 
              json['type'] as String? ?? 
              'text',
        
        // ✅ FIX: Mapper is_read_by_me vers isRead
        isRead: json['is_read_by_me'] as bool? ?? 
                json['is_read'] as bool? ?? 
                false,
        
        isEdited: json['is_edited'] as bool? ?? false,
        isDeleted: json['is_deleted'] as bool? ?? false,
        
        createdAt: parseDate(json['created_at']),
        updatedAt: json['updated_at'] != null ? parseDate(json['updated_at']) : null,
        deletedAt: json['deleted_at'] != null ? parseDate(json['deleted_at']) : null,
        
        // ✅ FIX: Mapper parent_message_id vers replyToId
        replyToId: safeInt(json['parent_message_id']) ?? 
                   safeInt(json['reply_to_id']),
        replyToContent: json['reply_to_content'] as String?,
        replyToSenderName: json['reply_to_sender_name'] as String?,
      );
    } catch (e, stackTrace) {
      debugPrint('❌ Erreur lors du parsing de MessageModel: $e');
      debugPrint('📋 StackTrace: $stackTrace');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'sender_id': senderId,
      'sender_name': senderName,
      'sender_avatar': senderAvatar,
      'sender_role': senderRole,
      'content': content,
      'type': type,
      'is_read': isRead,
      'is_edited': isEdited,
      'is_deleted': isDeleted,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'reply_to_id': replyToId,
      'reply_to_content': replyToContent,
      'reply_to_sender_name': replyToSenderName,
    };
  }

  String get formattedTime {
    final hour = createdAt.hour.toString().padLeft(2, '0');
    final minute = createdAt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String get formattedDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(createdAt.year, createdAt.month, createdAt.day);
    
    if (messageDate == today) {
      return 'Aujourd\'hui';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Hier';
    } else if (createdAt.year == now.year) {
      return '${createdAt.day}/${createdAt.month}';
    } else {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
  }

  bool isSentByCurrentUser(int currentUserId) {
    return senderId == currentUserId;
  }

  MessageModel copyWith({
    int? id,
    int? conversationId,
    int? senderId,
    String? senderName,
    String? senderAvatar,
    String? senderRole,
    String? content,
    String? type,
    bool? isRead,
    bool? isEdited,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    int? replyToId,
    String? replyToContent,
    String? replyToSenderName,
  }) {
    return MessageModel(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderAvatar: senderAvatar ?? this.senderAvatar,
      senderRole: senderRole ?? this.senderRole,
      content: content ?? this.content,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      isEdited: isEdited ?? this.isEdited,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      replyToId: replyToId ?? this.replyToId,
      replyToContent: replyToContent ?? this.replyToContent,
      replyToSenderName: replyToSenderName ?? this.replyToSenderName,
    );
  }

  @override
  List<Object?> get props => [
        id,
        conversationId,
        senderId,
        senderName,
        senderAvatar,
        senderRole,
        content,
        type,
        isRead,
        isEdited,
        isDeleted,
        createdAt,
        updatedAt,
        deletedAt,
        replyToId,
        replyToContent,
        replyToSenderName,
      ];

  @override
  String toString() {
    return 'MessageModel(id: $id, sender: $senderName, content: ${content.substring(0, content.length > 20 ? 20 : content.length)}...)';
  }
}