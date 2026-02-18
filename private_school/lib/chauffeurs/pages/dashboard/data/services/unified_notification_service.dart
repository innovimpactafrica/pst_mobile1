import 'dart:async';
import 'package:flutter/material.dart';
import '../repositories/messaging_repository.dart';
import '../repositories/notifications_repository.dart';
import '../../domain/bloc/unread_messages_bloc.dart' as messages;
import '../../domain/bloc/unread_notifications_bloc.dart' as notifications;

/// Service unifié pour gérer les notifications et messages des chauffeurs
/// Centralise la vérification périodique et la synchronisation des compteurs
class UnifiedNotificationService {
  static final UnifiedNotificationService _instance = UnifiedNotificationService._internal();
  factory UnifiedNotificationService() => _instance;
  UnifiedNotificationService._internal();

  Timer? _pollingTimer;
  messages.UnreadMessagesBloc? _messagesBloc;
  notifications.UnreadNotificationsBloc? _notificationsBloc;
  
  final MessagingRepository _messagingRepo = MessagingRepository();
  final NotificationsRepository _notificationsRepo = NotificationsRepository();
  
  bool _isPolling = false;
  static const Duration _pollingInterval = Duration(seconds: 30);

  /// Enregistrer les blocs pour la synchronisation
  void registerBlocs({
    required messages.UnreadMessagesBloc messagesBloc,
    required notifications.UnreadNotificationsBloc notificationsBloc,
  }) {
    _messagesBloc = messagesBloc;
    _notificationsBloc = notificationsBloc;
    debugPrint('🔧 [UnifiedNotificationService] Blocs enregistrés pour chauffeur');
  }

  /// Démarrer la vérification périodique
  void startPolling() {
    if (_isPolling) return;
    
    _isPolling = true;
    _pollingTimer = Timer.periodic(_pollingInterval, (_) => checkNow());
    debugPrint('🔄 [UnifiedNotificationService] Polling démarré (chauffeur)');
  }

  /// Arrêter la vérification périodique
  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _isPolling = false;
    debugPrint('⏹️ [UnifiedNotificationService] Polling arrêté (chauffeur)');
  }

  /// Vérifier immédiatement les nouveaux messages et notifications
  Future<void> checkNow() async {
    if (_messagesBloc == null || _notificationsBloc == null) {
      debugPrint('⚠️ [UnifiedNotificationService] Blocs non enregistrés');
      return;
    }

    try {
      debugPrint('🔍 [UnifiedNotificationService] Vérification en cours...');
      
      // Vérifier les messages en parallèle
      final results = await Future.wait([
        _messagingRepo.getUnreadCount(),
        _notificationsRepo.getUnreadCount(),
      ]);

      final messagesCount = results[0];
      final notificationsCount = results[1];

      debugPrint('📊 [UnifiedNotificationService] Résultats:');
      debugPrint('   💬 Messages non lus: $messagesCount');
      debugPrint('   🔔 Notifications non lues: $notificationsCount');

      // Mettre à jour les blocs si nécessaire
      _messagesBloc!.add(messages.UpdateUnreadCountEvent(messagesCount));
      _notificationsBloc!.add(notifications.UpdateUnreadCountEvent(notificationsCount));

    } catch (e) {
      debugPrint('❌ [UnifiedNotificationService] Erreur: $e');
    }
  }

  /// Nettoyer les ressources
  void dispose() {
    stopPolling();
    _messagesBloc = null;
    _notificationsBloc = null;
    debugPrint('🧹 [UnifiedNotificationService] Service nettoyé (chauffeur)');
  }
}