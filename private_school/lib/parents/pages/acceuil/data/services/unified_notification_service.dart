import 'dart:async';
import 'package:flutter/material.dart';
import '../repositories/messaging_repository.dart';
import '../../domain/bloc/unread_messages_bloc.dart';
import '../../../profil/domain/bloc/unread_notifications_bloc.dart';

class UnifiedNotificationService {
  static final UnifiedNotificationService _instance = UnifiedNotificationService._internal();
  factory UnifiedNotificationService() => _instance;
  UnifiedNotificationService._internal();

  final MessagingRepository _messagingRepository = MessagingRepository();
  Timer? _pollTimer;
  int _lastUnreadMessagesCount = 0;

  UnreadMessagesBloc? _messagesBloc;
  UnreadNotificationsBloc? _notificationsBloc;

  void registerBlocs({
    UnreadMessagesBloc? messagesBloc,
    UnreadNotificationsBloc? notificationsBloc,
  }) {
    _messagesBloc = messagesBloc;
    _notificationsBloc = notificationsBloc;
    debugPrint('📋 [UnifiedNotificationService] Blocs enregistrés');
  }

  void startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _checkForNewMessages();
    });
  }

  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  Future<void> _checkForNewMessages() async {
    try {
      final conversations = await _messagingRepository.getConversations();
      final currentUnreadCount = conversations.fold<int>(
        0, (sum, conv) => sum + conv.unreadCount,
      );
      if (currentUnreadCount != _lastUnreadMessagesCount) {
        debugPrint('📊 Messages: $_lastUnreadMessagesCount → $currentUnreadCount');
        _messagesBloc?.add(RefreshUnreadCountEvent());
        _lastUnreadMessagesCount = currentUnreadCount;
      }
    } catch (e) {
      debugPrint('❌ [UnifiedNotificationService] Erreur: $e');
    }
  }

  Future<void> checkNow() async {
    await _checkForNewMessages();
  }

  void resetCounters() {
    _lastUnreadMessagesCount = 0;
  }

  void dispose() {
    stopPolling();
    _messagesBloc = null;
    _notificationsBloc = null;
  }
}