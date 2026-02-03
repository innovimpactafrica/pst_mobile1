// Logout Service
// Path: lib/chauffeurs/pages/logout/data/services/logout_service.dart

import 'package:flutter/material.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/storage/secure_storage.dart';
import '../../../../../core/utils/api_constants.dart';

class LogoutService {
  final ApiClient _apiClient = ApiClient();
  final SecureStorage _storage = SecureStorage();

  /// Déconnexion complète de l'utilisateur
  Future<void> logout() async {
    try {
      debugPrint('═══════════════════════════════════════════════════════');
      debugPrint('🚪 [LOGOUT] Début de la déconnexion');
      debugPrint('═══════════════════════════════════════════════════════');

      // 1. Appeler l'API de déconnexion (invalide le token côté serveur)
      try {
        await _apiClient.post(ApiConstants.logout);
        debugPrint('✅ [LOGOUT] Token invalidé côté serveur');
      } catch (e) {
        // Si l'API échoue, on continue quand même pour nettoyer localement
        debugPrint('⚠️ [LOGOUT] Échec API (on continue): $e');
      }

      // 2. Supprimer TOUTES les données locales
      await _storage.clearAll();
      debugPrint('✅ [LOGOUT] Données locales supprimées');

      debugPrint('═══════════════════════════════════════════════════════');
      debugPrint('✅ [LOGOUT] Déconnexion terminée avec succès');
      debugPrint('═══════════════════════════════════════════════════════');
    } catch (e) {
      debugPrint('═══════════════════════════════════════════════════════');
      debugPrint('❌ [LOGOUT] Erreur: $e');
      debugPrint('═══════════════════════════════════════════════════════');
      throw Exception('Erreur lors de la déconnexion: $e');
    }
  }
}