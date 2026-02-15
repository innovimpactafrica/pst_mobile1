// Service d'authentification - CORRIGÉ pour récupérer la photo
// Chemin: lib/parents/authentification/data/services/auth_service.dart

import 'package:private_school/core/models/user_model.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/storage/secure_storage.dart';
import '../../../../../core/utils/api_constants.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();
  final SecureStorage _storage = SecureStorage();

  /// ✅ INSCRIPTION d'un parent - FORMAT CORRIGÉ
  /// Endpoint: POST /api/auth/register-parent
  Future<Map<String, dynamic>> registerParent({
    required String firstName,
    required String lastName,
    required String phone,
    required String email,
    String? password,
    String? homeAddress,
  }) async {
    try {
      debugPrint('📤 Registering parent: $email');

      final fullName = '$firstName $lastName'.trim();

      String formattedPhone = phone.trim();
      if (!formattedPhone.startsWith('+')) {
        if (formattedPhone.startsWith('221')) {
          formattedPhone = '+$formattedPhone';
        } else {
          formattedPhone = '+221$formattedPhone';
        }
      }

      final Map<String, dynamic> data = {
        'name': fullName,
        'phone': formattedPhone,
        'email': email,
      };

      if (password != null && password.isNotEmpty) {
        data['password'] = password;
        debugPrint('🔐 Password included in registration');
      }

      if (homeAddress != null && homeAddress.isNotEmpty) {
        data['home_address'] = homeAddress;
        debugPrint('🏠 Home address included: $homeAddress');
      }

      debugPrint('📤 Sending data: $data');

      final response = await _apiClient.post(
        ApiConstants.registerParent,
        data: data,
      );

      debugPrint('✅ Registration successful');

      final token = response.data['token'] ?? response.data['accessToken'];
      if (token != null) {
        await _storage.saveAccessToken(token);
        debugPrint('✅ Token saved from registration');
      }

      return {
        'success': true,
        'message': response.data['message'] ?? 'Inscription réussie',
        'data': response.data,
        'token': token,
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
      debugPrint('📦 Login response: ${response.data}');

      // Extraire le token et les données utilisateur
      final token = response.data['token'] ?? response.data['accessToken'];
      final userData = response.data['user'] ?? response.data['data'];

      // Sauvegarder le token
      if (token != null) {
        await _storage.saveAccessToken(token);
        debugPrint('✅ Token saved');
      }

      // Sauvegarder les données utilisateur (en JSON)
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
  /// Forgot Password - Returns userId
  Future<Map<String, dynamic>> forgotPassword({required String contact}) async {
    try {
      debugPrint('📤 Requesting password reset for: $contact');

      final response = await _apiClient.post(
        ApiConstants.forgotPassword,
        data: {
          'contact': contact, // Email ou téléphone
        },
      );

      debugPrint('✅ Password reset requested');
      debugPrint('📦 Response: ${response.data}');

      final responseData = response.data is Map
          ? response.data
          : {'data': response.data};

      return responseData; // Contient userId
    } catch (e) {
      debugPrint('❌ Forgot password error: $e');
      throw Exception('Erreur lors de la demande de réinitialisation');
    }
  }

  /// ✅ RÉINITIALISER le mot de passe avec OTP
  /// Reset Password
  Future<void> resetPassword({
    required int userId,
    required String code,
    required String newPassword,
  }) async {
    try {
      debugPrint('📤 Resetting password for user: $userId');

      await _apiClient.post(
        ApiConstants.resetPassword,
        data: {
          'userId': userId,
          'code': code,
          'newPassword': newPassword,
        },
      );

      debugPrint('✅ Password reset successful');
    } catch (e) {
      debugPrint('❌ Reset password error: $e');
      throw Exception('Erreur lors de la réinitialisation');
    }
  }

  /// ✅ DÉCONNEXION
  Future<void> logout() async {
    try {
      debugPrint('📤 Logging out...');
      await _apiClient.post(ApiConstants.logout);
      debugPrint('✅ Logout successful');
    } catch (e) {
      debugPrint('⚠️ Logout API error (continuing with local logout): $e');
    } finally {
      await _storage.clearAll();
      debugPrint('✅ Local storage cleared');
    }
  }

  /// ✅ MODIFIÉ : Récupérer l'utilisateur actuel AVEC PHOTO
  /// Utilise /api/parents/account au lieu de /api/auth
  Future<UserModel> getCurrentUser() async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('📤 [AuthService] Fetching current user WITH PHOTO...');
      debugPrint('📍 Endpoint: /api/parents/account');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      // ✅ UTILISER /api/parents/account pour avoir la photo
      final response = await _apiClient.get('/api/parents/account');

      debugPrint('✅ Response Status: ${response.statusCode}');
      debugPrint('📦 Response Type: ${response.data.runtimeType}');

      final dynamic responseData = response.data;
      
      // Vérifier la structure de la réponse
      if (responseData is Map<String, dynamic>) {
        Map<String, dynamic> userData;

        // Cas 1 : {success: true, data: {...}}
        if (responseData.containsKey('data') && responseData['data'] != null) {
          debugPrint('✅ Extracting user from response.data');
          userData = responseData['data'];
        } 
        // Cas 2 : {user: {...}}
        else if (responseData.containsKey('user') && responseData['user'] != null) {
          debugPrint('✅ Extracting user from response.user');
          userData = responseData['user'];
        } 
        // Cas 3 : La réponse est directement l'utilisateur
        else {
          debugPrint('✅ Response is directly the user object');
          userData = responseData;
        }

        // ✅ LOG : Vérifier si la photo est présente
        debugPrint('');
        debugPrint('👤 USER DATA:');
        debugPrint('   ID: ${userData['id']}');
        debugPrint('   Name: ${userData['name']}');
        debugPrint('   Email: ${userData['email']}');
        debugPrint('   Photo (brut): ${userData['photo_profil'] ?? userData['photo']}');
        debugPrint('');

        final user = UserModel.fromJson(userData);

        debugPrint('✅ UserModel created:');
        debugPrint('   Full Name: ${user.fullName}');
        debugPrint('   Photo URL: ${user.photo}');
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

        return user;
      }
      
      throw Exception('Format de réponse invalide: $responseData');
    } catch (e, stackTrace) {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('❌ [AuthService] Get current user error');
      debugPrint('Error: $e');
      debugPrint('Stack: $stackTrace');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      throw Exception('Impossible de récupérer le profil: $e');
    }
  }

  /// ✅ Vérifier si l'utilisateur est connecté
  Future<bool> isLoggedIn() async {
    return await _storage.isLoggedIn();
  }
}