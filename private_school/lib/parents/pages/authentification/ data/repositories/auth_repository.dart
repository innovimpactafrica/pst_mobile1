import 'package:flutter/foundation.dart';
import 'package:private_school/core/models/user_model.dart';
import '../services/auth_service.dart';

class AuthRepository {
  final AuthService _authService = AuthService();
  Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String phone,
    required String email,
    String? password,
    String? homeAddress,
  }) async {
    try {
      return await _authService.registerParent(
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        email: email,
        password: password,
        homeAddress: homeAddress,
      );
    } catch (e) {
      debugPrint(' Repository: Register failed - $e');
      throw Exception('Inscription échouée: $e');
    }
  }

  ///  Connexion
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      return await _authService.loginParent(email: email, password: password);
    } catch (e) {
      debugPrint(' Repository: Login failed - $e');
      throw Exception('Connexion échouée: $e');
    }
  }

  ///  Vérifier OTP
  Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      return await _authService.verifyOtp(email: email, otp: otp);
    } catch (e) {
      debugPrint(' Repository: OTP verification failed - $e');
      throw Exception('Vérification échouée: $e');
    }
  }

  ///  Mot de passe oublié
  Future<Map<String, dynamic>> forgotPassword({required String contact}) async {
    return await _authService.forgotPassword(contact: contact);
  }

  ///  Réinitialiser mot de passe
  Future<void> resetPassword({
    required int userId,
    required String code,
    required String newPassword,
  }) async {
    try {
      await _authService.resetPassword(
        userId: userId,
        code: code,
        newPassword: newPassword,
      );
    } catch (e) {
      debugPrint(' Repository: Reset password failed - $e');
      throw Exception('Réinitialisation échouée: $e');
    }
  }

  ///  Déconnexion
  Future<void> logout() async {
    try {
      await _authService.logout();
    } catch (e) {
      debugPrint(' Repository: Logout failed - $e');
      throw Exception('Déconnexion échouée: $e');
    }
  }

  ///  Récupérer l'utilisateur actuel
  Future<UserModel> getCurrentUser() async {
    try {
      return await _authService.getCurrentUser();
    } catch (e) {
      debugPrint(' Repository: Get user failed - $e');
      throw Exception('Impossible de récupérer l\'utilisateur: $e');
    }
  }

  ///  Vérifier si connecté
  Future<bool> isLoggedIn() async {
    return await _authService.isLoggedIn();
  }
}
