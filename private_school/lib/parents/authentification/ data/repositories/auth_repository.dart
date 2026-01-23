/// Repository d'authentification - Logique métier
/// Chemin: lib/parents/authentification/data/repositories/auth_repository.dart

import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthRepository {
  final AuthService _authService = AuthService();

  /// Inscription
  Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String phone,
    required String email,
  }) async {
    try {
      return await _authService.registerParent(
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        email: email,
      );
    } catch (e) {
      print('❌ Repository: Register failed - $e');
      throw Exception('Inscription échouée: $e');
    }
  }

  /// Connexion
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      return await _authService.loginParent(
        email: email,
        password: password,
      );
    } catch (e) {
      print('❌ Repository: Login failed - $e');
      throw Exception('Connexion échouée: $e');
    }
  }

  /// Vérifier OTP
  Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      return await _authService.verifyOtp(email: email, otp: otp);
    } catch (e) {
      print('❌ Repository: OTP verification failed - $e');
      throw Exception('Vérification échouée: $e');
    }
  }

  /// Mot de passe oublié
  Future<Map<String, dynamic>> forgotPassword({
    required String email,
  }) async {
    try {
      return await _authService.forgotPassword(email: email);
    } catch (e) {
      print('❌ Repository: Forgot password failed - $e');
      throw Exception('Erreur: $e');
    }
  }

  /// Réinitialiser mot de passe
  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      return await _authService.resetPassword(
        email: email,
        otp: otp,
        newPassword: newPassword,
      );
    } catch (e) {
      print('❌ Repository: Reset password failed - $e');
      throw Exception('Réinitialisation échouée: $e');
    }
  }

  /// Déconnexion
  Future<void> logout() async {
    try {
      await _authService.logout();
    } catch (e) {
      print('❌ Repository: Logout failed - $e');
      throw Exception('Déconnexion échouée: $e');
    }
  }

  /// Récupérer l'utilisateur actuel
  Future<UserModel> getCurrentUser() async {
    try {
      return await _authService.getCurrentUser();
    } catch (e) {
      print('❌ Repository: Get user failed - $e');
      throw Exception('Impossible de récupérer l\'utilisateur: $e');
    }
  }

  /// Vérifier si connecté
  Future<bool> isLoggedIn() async {
    return await _authService.isLoggedIn();
  }
}