import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import '../../data/repositories/messaging_repository.dart';

// Events
abstract class UnreadMessagesEvent {}

class LoadUnreadCountEvent extends UnreadMessagesEvent {}

class RefreshUnreadCountEvent extends UnreadMessagesEvent {}

class MessageReadEvent extends UnreadMessagesEvent {
  final int conversationId;
  MessageReadEvent(this.conversationId);
}

class NewMessageReceivedEvent extends UnreadMessagesEvent {
  final int conversationId;
  NewMessageReceivedEvent(this.conversationId);
}

// States
abstract class UnreadMessagesState {}

class UnreadMessagesInitial extends UnreadMessagesState {}

class UnreadMessagesLoaded extends UnreadMessagesState {
  final int count;
  UnreadMessagesLoaded(this.count);
}

// BLoC
class UnreadMessagesBloc extends Bloc<UnreadMessagesEvent, UnreadMessagesState> {
  final MessagingRepository repository;
  Timer? _refreshTimer;
  static UnreadMessagesBloc? _instance;

  UnreadMessagesBloc({MessagingRepository? repository})
      : repository = repository ?? MessagingRepository(),
        super(UnreadMessagesInitial()) {
    on<LoadUnreadCountEvent>(_onLoadUnreadCount);
    on<RefreshUnreadCountEvent>(_onRefreshUnreadCount);
    on<MessageReadEvent>(_onMessageRead);
    on<NewMessageReceivedEvent>(_onNewMessageReceived);
    
    _instance = this;
    // Auto-refresh toutes les 30 secondes
    _startAutoRefresh();
  }

  static UnreadMessagesBloc? get instance => _instance;

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      add(RefreshUnreadCountEvent());
    });
  }

  @override
  Future<void> close() {
    _refreshTimer?.cancel();
    _instance = null;
    return super.close();
  }

  Future<void> _onLoadUnreadCount(
    LoadUnreadCountEvent event,
    Emitter<UnreadMessagesState> emit,
  ) async {
    try {
      debugPrint('🔄 [UnreadMessagesBloc] Chargement compteur...');
      final conversations = await repository.getConversations();
      final totalUnread = conversations.fold<int>(
        0,
        (sum, conv) => sum + conv.unreadCount,
      );
      debugPrint('✅ [UnreadMessagesBloc] Compteur: $totalUnread messages non lus');
      emit(UnreadMessagesLoaded(totalUnread));
    } catch (e) {
      debugPrint('❌ Erreur chargement compteur: $e');
      emit(UnreadMessagesLoaded(0));
    }
  }

  Future<void> _onRefreshUnreadCount(
    RefreshUnreadCountEvent event,
    Emitter<UnreadMessagesState> emit,
  ) async {
    try {
      final conversations = await repository.getConversations();
      final totalUnread = conversations.fold<int>(
        0,
        (sum, conv) => sum + conv.unreadCount,
      );
      debugPrint('🔄 [UnreadMessagesBloc] Refresh compteur: $totalUnread');
      emit(UnreadMessagesLoaded(totalUnread));
    } catch (e) {
      debugPrint('❌ Erreur refresh compteur: $e');
      // En cas d'erreur, garder l'état actuel
      if (state is UnreadMessagesLoaded) {
        emit(UnreadMessagesLoaded((state as UnreadMessagesLoaded).count));
      }
    }
  }

  Future<void> _onMessageRead(
  MessageReadEvent event,
  Emitter<UnreadMessagesState> emit,
) async {
  debugPrint('📖 [UnreadMessagesBloc] Messages lus dans conversation ${event.conversationId}');
  
  // ✅ Décrémenter IMMÉDIATEMENT le compteur local (comme WhatsApp)
  if (state is UnreadMessagesLoaded) {
    final currentCount = (state as UnreadMessagesLoaded).count;
    if (currentCount > 0) {
      emit(UnreadMessagesLoaded(currentCount > 1 ? currentCount - 1 : 0));
    }
  }

  // ✅ Puis rafraîchir depuis le serveur après un délai
  await Future.delayed(const Duration(milliseconds: 800));
  try {
    final conversations = await repository.getConversations();
    final totalUnread = conversations.fold<int>(
      0,
      (sum, conv) => sum + conv.unreadCount,
    );
    emit(UnreadMessagesLoaded(totalUnread));
  } catch (e) {
    debugPrint('❌ Erreur refresh après lecture: $e');
  }
}

  Future<void> _onNewMessageReceived(
    NewMessageReceivedEvent event,
    Emitter<UnreadMessagesState> emit,
  ) async {
    debugPrint('📨 [UnreadMessagesBloc] Nouveau message dans conversation ${event.conversationId}');
    add(RefreshUnreadCountEvent());
  }

  // Méthode statique pour notifier depuis n'importe où
  static void notifyMessageRead(int conversationId) {
    _instance?.add(MessageReadEvent(conversationId));
  }

  static void notifyNewMessage(int conversationId) {
    _instance?.add(NewMessageReceivedEvent(conversationId));
  }
}
