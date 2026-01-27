// Service d'authentification - Appels API
// Chemin: lib/parents/authentification/data/services/auth_service.dart

import 'package:private_school/core/models/user_model.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../core/utils/api_constants.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();
  final SecureStorage _storage = SecureStorage();

  /// ✅ INSCRIPTION d'un parent
  /// Endpoint: POST /api/auth/register-parent
  Future<Map<String, dynamic>> registerParent({
    required String firstName,
    required String lastName,
    required String phone,
    required String email,
  }) async {
    try {
      debugPrint('📤 Registering parent: $email');

      final response = await _apiClient.post(
        ApiConstants.registerParent,
        data: {
          'firstName': firstName,
          'lastName': lastName,
          'phone': phone,
          'email': email,
        },
      );

      debugPrint('✅ Registration successful');

      return {
        'success': true,
        'message': response.data['message'] ?? 'Inscription réussie',
        'data': response.data,
      };
    } catch (e) {
      debugPrint('❌ Registration error: $e');
      throw Exception('Erreur lors de l\'inscription: $e');
    }
  }

  /// ✅ CONNEXION d'un parent
  /// Endpoint: POST /api/auth/login/parent
  Future<Map<String, dynamic>> loginParent({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('📤 Logging in parent: $email');

      final response = await _apiClient.post(
        ApiConstants.loginParent,
        data: {'email': email, 'password': password},
      );

      debugPrint('✅ Login successful');

      // Extraire le token et les données utilisateur
      final token = response.data['token'] ?? response.data['accessToken'];
      final userData = response.data['user'] ?? response.data['data'];

      // Sauvegarder le token
      if (token != null) {
        await _storage.saveAccessToken(token);
        debugPrint('✅ Token saved');
      }

      // Sauvegarder les données utilisateur
      if (userData != null) {
        await _storage.saveUserData(userData.toString());
        debugPrint('✅ User data saved');
      }

      return {
        'success': true,
        'token': token,
        'user': userData != null ? UserModel.fromJson(userData) : null,
      };
    } catch (e) {
      debugPrint('❌ Login error: $e');
      throw Exception('Email ou mot de passe incorrect');
    }
  }

  /// ✅ VÉRIFIER le code OTP
  /// Endpoint: POST /api/auth/verify-otp
  Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      debugPrint('📤 Verifying OTP for: $email');

      final response = await _apiClient.post(
        ApiConstants.verifyOtp,
        data: {'email': email, 'otp': otp},
      );

      debugPrint('✅ OTP verified successfully');

      return {
        'success': true,
        'message': response.data['message'] ?? 'Code vérifié',
        'token': response.data['token'],
      };
    } catch (e) {
      debugPrint('❌ OTP verification error: $e');
      throw Exception('Code de vérification invalide');
    }
  }

  /// ✅ MOT DE PASSE OUBLIÉ - Demander OTP
  /// Endpoint: POST /api/auth/forgot-password
  Future<Map<String, dynamic>> forgotPassword({required String email}) async {
    try {
      debugPrint('📤 Requesting password reset for: $email');

      final response = await _apiClient.post(
        ApiConstants.forgotPassword,
        data: {'email': email},
      );

      debugPrint('✅ OTP sent successfully');

      return {
        'success': true,
        'message': response.data['message'] ?? 'Code OTP envoyé',
      };
    } catch (e) {
      debugPrint('❌ Forgot password error: $e');
      throw Exception('Erreur lors de l\'envoi du code');
    }
  }

  /// ✅ RÉINITIALISER le mot de passe avec OTP
  /// Endpoint: POST /api/auth/reset-password
  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      debugPrint('📤 Resetting password for: $email');

      final response = await _apiClient.post(
        ApiConstants.resetPassword,
        data: {'email': email, 'otp': otp, 'newPassword': newPassword},
      );

      debugPrint('✅ Password reset successfully');

      return {
        'success': true,
        'message': response.data['message'] ?? 'Mot de passe réinitialisé',
      };
    } catch (e) {
      debugPrint('❌ Reset password error: $e');
      throw Exception('Erreur lors de la réinitialisation');
    }
  }

  /// ✅ DÉCONNEXION
  /// Endpoint: POST /api/auth/logout
  Future<void> logout() async {
    try {
      debugPrint('📤 Logging out...');

      await _apiClient.post(ApiConstants.logout);

      // Supprimer le token local
      await _storage.clearAll();

      debugPrint('✅ Logged out successfully');
    } catch (e) {
      debugPrint('❌ Logout error: $e');
      // Même si l'API échoue, on supprime le token local
      await _storage.clearAll();
    }
  }

  /// ✅ RÉCUPÉRER le profil de l'utilisateur connecté
  /// Endpoint: GET /api/auth
  Future<UserModel> getCurrentUser() async {
    try {
      debugPrint('📤 Fetching current user profile...');

      final response = await _apiClient.get('/api/auth');

      debugPrint('✅ User profile received');

      final userData = response.data['user'] ?? response.data['data'];
      return UserModel.fromJson(userData);
    } catch (e) {
      debugPrint('❌ Get current user error: $e');
      throw Exception('Impossible de récupérer le profil');
    }
  }

  /// ✅ VÉRIFIER si l'utilisateur est connecté
  Future<bool> isLoggedIn() async {
    return await _storage.isLoggedIn();
  }
}
