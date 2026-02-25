import 'dart:async';
import 'package:flutter/material.dart';
import '../repositories/messaging_repository.dart';
import '../../domain/bloc/unread_messages_bloc.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final MessagingRepository _repository = MessagingRepository();
  Timer? _pollTimer;
  int _lastUnreadCount = 0;

  void startPolling() {
    debugPrint(' [NotificationService] Démarrage du polling...');

    // Arrêter le timer existant s'il y en a un
    _pollTimer?.cancel();

    // Polling toutes les 15 secondes
    _pollTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      _checkForNewMessages();
    });
  }

  // Arrêter le polling
  void stopPolling() {
    debugPrint(' [NotificationService] Arrêt du polling');
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  // Vérifier s'il y a de nouveaux messages
  Future<void> _checkForNewMessages() async {
    try {
      final conversations = await _repository.getConversations();
      final currentUnreadCount = conversations.fold<int>(
        0,
        (sum, conv) => sum + conv.unreadCount,
      );

      if (currentUnreadCount != _lastUnreadCount) {
        debugPrint(
          ' [NotificationService] Changement détecté: $_lastUnreadCount → $currentUnreadCount',
        );

        // Mettre à jour le compteur
        UnreadMessagesBloc.instance?.add(RefreshUnreadCountEvent());

        // Si il y a plus de messages qu'avant, c'est un nouveau message
        if (currentUnreadCount > _lastUnreadCount) {
          debugPrint(' [NotificationService] Nouveau(x) message(s) détecté(s)');
          _showNewMessageNotification(currentUnreadCount - _lastUnreadCount);
        }

        _lastUnreadCount = currentUnreadCount;
      }
    } catch (e) {
      debugPrint(' [NotificationService] Erreur polling: $e');
    }
  }

  // Afficher une notification pour les nouveaux messages
  void _showNewMessageNotification(int newMessageCount) {
    debugPrint(' [NotificationService] $newMessageCount nouveau(x) message(s)');
  }

  Future<void> checkNow() async {
    debugPrint(' [NotificationService] Vérification forcée');
    await _checkForNewMessages();
  }

  void resetCounter() {
    debugPrint(' [NotificationService] Reset compteur');
    _lastUnreadCount = 0;
  }

  // Nettoyer les ressources
  void dispose() {
    debugPrint(' [NotificationService] Nettoyage');
    stopPolling();
  }
}
