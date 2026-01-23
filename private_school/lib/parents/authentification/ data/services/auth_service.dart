/// Service d'authentification - Appels API
/// Chemin: lib/parents/authentification/data/services/auth_service.dart

import '../../../../core/network/api_client.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../core/utils/api_constants.dart';
import '../models/user_model.dart';

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
      print('📤 Registering parent: $email');

      final response = await _apiClient.post(
        ApiConstants.registerParent,
        data: {
          'firstName': firstName,
          'lastName': lastName,
          'phone': phone,
          'email': email,
        },
      );

      print('✅ Registration successful');

      return {
        'success': true,
        'message': response.data['message'] ?? 'Inscription réussie',
        'data': response.data,
      };
    } catch (e) {
      print('❌ Registration error: $e');
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
      print('📤 Logging in parent: $email');

      final response = await _apiClient.post(
        ApiConstants.loginParent,
        data: {
          'email': email,
          'password': password,
        },
      );

      print('✅ Login successful');

      // Extraire le token et les données utilisateur
      final token = response.data['token'] ?? response.data['accessToken'];
      final userData = response.data['user'] ?? response.data['data'];

      // Sauvegarder le token
      if (token != null) {
        await _storage.saveAccessToken(token);
        print('✅ Token saved');
      }

      // Sauvegarder les données utilisateur
      if (userData != null) {
        await _storage.saveUserData(userData.toString());
        print('✅ User data saved');
      }

      return {
        'success': true,
        'token': token,
        'user': userData != null ? UserModel.fromJson(userData) : null,
      };
    } catch (e) {
      print('❌ Login error: $e');
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
      print('📤 Verifying OTP for: $email');

      final response = await _apiClient.post(
        ApiConstants.verifyOtp,
        data: {
          'email': email,
          'otp': otp,
        },
      );

      print('✅ OTP verified successfully');

      return {
        'success': true,
        'message': response.data['message'] ?? 'Code vérifié',
        'token': response.data['token'],
      };
    } catch (e) {
      print('❌ OTP verification error: $e');
      throw Exception('Code de vérification invalide');
    }
  }

  /// ✅ MOT DE PASSE OUBLIÉ - Demander OTP
  /// Endpoint: POST /api/auth/forgot-password
  Future<Map<String, dynamic>> forgotPassword({
    required String email,
  }) async {
    try {
      print('📤 Requesting password reset for: $email');

      final response = await _apiClient.post(
        ApiConstants.forgotPassword,
        data: {'email': email},
      );

      print('✅ OTP sent successfully');

      return {
        'success': true,
        'message': response.data['message'] ?? 'Code OTP envoyé',
      };
    } catch (e) {
      print('❌ Forgot password error: $e');
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
      print('📤 Resetting password for: $email');

      final response = await _apiClient.post(
        ApiConstants.resetPassword,
        data: {
          'email': email,
          'otp': otp,
          'newPassword': newPassword,
        },
      );

      print('✅ Password reset successfully');

      return {
        'success': true,
        'message': response.data['message'] ?? 'Mot de passe réinitialisé',
      };
    } catch (e) {
      print('❌ Reset password error: $e');
      throw Exception('Erreur lors de la réinitialisation');
    }
  }

  /// ✅ DÉCONNEXION
  /// Endpoint: POST /api/auth/logout
  Future<void> logout() async {
    try {
      print('📤 Logging out...');

      await _apiClient.post(ApiConstants.logout);

      // Supprimer le token local
      await _storage.clearAll();

      print('✅ Logged out successfully');
    } catch (e) {
      print('❌ Logout error: $e');
      // Même si l'API échoue, on supprime le token local
      await _storage.clearAll();
    }
  }

  /// ✅ RÉCUPÉRER le profil de l'utilisateur connecté
  /// Endpoint: GET /api/auth
  Future<UserModel> getCurrentUser() async {
    try {
      print('📤 Fetching current user profile...');

      final response = await _apiClient.get('/api/auth');

      print('✅ User profile received');

      final userData = response.data['user'] ?? response.data['data'];
      return UserModel.fromJson(userData);
    } catch (e) {
      print('❌ Get current user error: $e');
      throw Exception('Impossible de récupérer le profil');
    }
  }

  /// ✅ VÉRIFIER si l'utilisateur est connecté
  Future<bool> isLoggedIn() async {
    return await _storage.isLoggedIn();
  }
}