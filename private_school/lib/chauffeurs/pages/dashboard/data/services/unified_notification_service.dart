import 'dart:async';
import '../repositories/messaging_repository.dart';
import '../repositories/notifications_repository.dart';
import '../../domain/bloc/unread_messages_bloc.dart' as messages;
import '../../domain/bloc/unread_notifications_bloc.dart' as notifications;

class UnifiedNotificationService {
  static final UnifiedNotificationService _instance =
      UnifiedNotificationService._internal();
  factory UnifiedNotificationService() => _instance;
  UnifiedNotificationService._internal();

  Timer? _pollingTimer;
  messages.UnreadMessagesBloc? _messagesBloc;
  notifications.UnreadNotificationsBloc? _notificationsBloc;

  final MessagingRepository _messagingRepo = MessagingRepository();
  final NotificationsRepository _notificationsRepo = NotificationsRepository();

  bool _isPolling = false;
  static const Duration _pollingInterval = Duration(seconds: 30);

  void registerBlocs({
    required messages.UnreadMessagesBloc messagesBloc,
    required notifications.UnreadNotificationsBloc notificationsBloc,
  }) {
    _messagesBloc = messagesBloc;
    _notificationsBloc = notificationsBloc;
  }

  /// Démarrer la vérification périodique
  void startPolling() {
    if (_isPolling) return;

    _isPolling = true;
    _pollingTimer = Timer.periodic(_pollingInterval, (_) => checkNow());
  }

  /// Arrêter la vérification périodique
  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _isPolling = false;
  }

  /// Vérifier immédiatement les nouveaux messages et notifications
  Future<void> checkNow() async {
    if (_messagesBloc == null || _notificationsBloc == null) {
      return;
    }

    try {
      final results = await Future.wait([
        _messagingRepo.getUnreadCount(),
        _notificationsRepo.getUnreadCount(),
      ]);

      final messagesCount = results[0];
      final notificationsCount = results[1];
      _messagesBloc!.add(messages.UpdateUnreadCountEvent(messagesCount));
      _notificationsBloc!.add(
        notifications.UpdateUnreadCountEvent(notificationsCount),
      );
    } catch (e) {
      //
    }
  }

  void dispose() {
    stopPolling();
    _messagesBloc = null;
    _notificationsBloc = null;
  }
}
