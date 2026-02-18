// Service unifié pour les notifications et messages
// Path: parents/pages/acceuil/data/services/unified_notification_service.dart

import 'dart:async';
import 'package:flutter/material.dart';
import '../repositories/messaging_repository.dart';
import '../../../profil/data/repositories/notifications_repository.dart';
import '../../domain/bloc/unread_messages_bloc.dart';
import '../../../profil/domain/bloc/unread_notifications_bloc.dart';

class UnifiedNotificationService {
  static final UnifiedNotificationService _instance = UnifiedNotificationService._internal();
  factory UnifiedNotificationService() => _instance;
  UnifiedNotificationService._internal();

  final MessagingRepository _messagingRepository = MessagingRepository();
  final NotificationRepository _notificationRepository = NotificationRepository();
  Timer? _pollTimer;
  int _lastUnreadMessagesCount = 0;
  int _lastUnreadNotificationsCount = 0;

  // Références aux blocs pour les mises à jour
  UnreadMessagesBloc? _messagesBloc;
  UnreadNotificationsBloc? _notificationsBloc;

  // Enregistrer les blocs
  void registerBlocs({
    UnreadMessagesBloc? messagesBloc,
    UnreadNotificationsBloc? notificationsBloc,
  }) {
    _messagesBloc = messagesBloc;
    _notificationsBloc = notificationsBloc;
    debugPrint('📋 [UnifiedNotificationService] Blocs enregistrés');
  }

  // Démarrer le polling pour les nouveaux messages et notifications
  void startPolling() {
    debugPrint('🔄 [UnifiedNotificationService] Démarrage du polling...');
    
    // Arrêter le timer existant s'il y en a un
    _pollTimer?.cancel();
    
    // Polling toutes les 15 secondes
    _pollTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      _checkForUpdates();
    });
  }

  // Arrêter le polling
  void stopPolling() {
    debugPrint('⏹️ [UnifiedNotificationService] Arrêt du polling');
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  // Vérifier s'il y a de nouveaux messages et notifications
  Future<void> _checkForUpdates() async {
    await Future.wait([
      _checkForNewMessages(),
      _checkForNewNotifications(),
    ]);
  }

  // Vérifier s'il y a de nouveaux messages
  Future<void> _checkForNewMessages() async {
    try {
      final conversations = await _messagingRepository.getConversations();
      final currentUnreadCount = conversations.fold<int>(
        0,
        (sum, conv) => sum + conv.unreadCount,
      );

      // Si le nombre de messages non lus a changé
      if (currentUnreadCount != _lastUnreadMessagesCount) {
        debugPrint('📊 [UnifiedNotificationService] Messages: $_lastUnreadMessagesCount → $currentUnreadCount');
        
        // Mettre à jour le compteur
        _messagesBloc?.add(RefreshUnreadCountEvent());
        
        // Si il y a plus de messages qu'avant, c'est un nouveau message
        if (currentUnreadCount > _lastUnreadMessagesCount) {
          debugPrint('📨 [UnifiedNotificationService] Nouveau(x) message(s) détecté(s)');
        }
        
        _lastUnreadMessagesCount = currentUnreadCount;
      }
    } catch (e) {
      debugPrint('❌ [UnifiedNotificationService] Erreur polling messages: $e');
    }
  }

  // Vérifier s'il y a de nouvelles notifications
  Future<void> _checkForNewNotifications() async {
    try {
      final notifications = await _notificationRepository.getNotifications();
      final currentUnreadCount = notifications.where((n) => !n.isRead).length;

      // Si le nombre de notifications non lues a changé
      if (currentUnreadCount != _lastUnreadNotificationsCount) {
        debugPrint('🔔 [UnifiedNotificationService] Notifications: $_lastUnreadNotificationsCount → $currentUnreadCount');
        
        // Mettre à jour le compteur
        _notificationsBloc?.add(RefreshUnreadNotificationsCountEvent());
        
        // Si il y a plus de notifications qu'avant, c'est une nouvelle notification
        if (currentUnreadCount > _lastUnreadNotificationsCount) {
          debugPrint('🔔 [UnifiedNotificationService] Nouvelle(s) notification(s) détectée(s)');
        }
        
        _lastUnreadNotificationsCount = currentUnreadCount;
      }
    } catch (e) {
      debugPrint('❌ [UnifiedNotificationService] Erreur polling notifications: $e');
    }
  }

  // Forcer une vérification immédiate
  Future<void> checkNow() async {
    debugPrint('⚡ [UnifiedNotificationService] Vérification forcée');
    await _checkForUpdates();
  }

  // Réinitialiser les compteurs (utile lors de la connexion)
  void resetCounters() {
    debugPrint('🔄 [UnifiedNotificationService] Reset compteurs');
    _lastUnreadMessagesCount = 0;
    _lastUnreadNotificationsCount = 0;
  }

  // Nettoyer les ressources
  void dispose() {
    debugPrint('🧹 [UnifiedNotificationService] Nettoyage');
    stopPolling();
    _messagesBloc = null;
    _notificationsBloc = null;
  }
}