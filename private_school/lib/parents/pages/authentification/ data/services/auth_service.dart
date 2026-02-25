import 'dart:convert';

import 'package:private_school/core/models/user_model.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/storage/secure_storage.dart';
import '../../../../../core/utils/api_constants.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();
  final SecureStorage _storage = SecureStorage();

  Future<Map<String, dynamic>> registerParent({
    required String firstName,
    required String lastName,
    required String phone,
    required String email,
    String? password,
    String? homeAddress,
  }) async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint(' [AuthService] INSCRIPTION PARENT');
      debugPrint('   firstName: $firstName');
      debugPrint('   lastName: $lastName');
      debugPrint('   phone: $phone');
      debugPrint('   email: $email');
      debugPrint('   password: ${password != null ? "***" : "null"}');
      debugPrint('   homeAddress: $homeAddress');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

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
        debugPrint(' Password included');
      }

      if (homeAddress != null && homeAddress.isNotEmpty) {
        data['home_address'] = homeAddress;
        debugPrint(' Home address included: $homeAddress');
      }

      debugPrint(' Data sent to API: $data');

      final response = await _apiClient.post(
        ApiConstants.registerParent,
        data: data,
      );

      debugPrint(' Registration response:');
      debugPrint('   Status: ${response.statusCode}');
      debugPrint('   Data: ${response.data}');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      final token = response.data['token'] ?? response.data['accessToken'];
      if (token != null) {
        await _storage.saveAccessToken(token);
        debugPrint(' Token saved');
      }

      return {
        'success': true,
        'message': response.data['message'] ?? 'Inscription réussie',
        'data': response.data,
        'token': token,
      };
    } catch (e) {
      debugPrint(' Registration error: $e');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      throw Exception('Erreur lors de l\'inscription: $e');
    }
  }

  Future<Map<String, dynamic>> loginParent({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint(' Logging in parent: $email');
      debugPrint(' Clearing old session...');
      await _storage.clearAll();

      final response = await _apiClient.post(
        ApiConstants.loginParent,
        data: {'email': email, 'password': password},
      );

      debugPrint(' Login successful');
      debugPrint(' Login response: ${response.data}');

      // Extraire le token et les données utilisateur
      final token = response.data['token'] ?? response.data['accessToken'];
      final userData = response.data['user'] ?? response.data['data'];

      // Sauvegarder le token
      if (token != null) {
        await _storage.saveAccessToken(token);
        debugPrint(' Token saved: ${token.substring(0, 20)}...');
      }

      if (userData != null) {
        await _storage.saveUserData(jsonEncode(userData));
        debugPrint(' User data saved: ${userData['id']} - ${userData['name']}');
      }

      return {
        'success': true,
        'token': token,
        'user': userData != null ? UserModel.fromJson(userData) : null,
      };
    } catch (e) {
      debugPrint(' Login error: $e');
      throw Exception('Email ou mot de passe incorrect');
    }
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      debugPrint(' Verifying OTP for: $email');

      final response = await _apiClient.post(
        ApiConstants.verifyOtp,
        data: {'email': email, 'otp': otp},
      );

      debugPrint(' OTP verified successfully');

      return {
        'success': true,
        'message': response.data['message'] ?? 'Code vérifié',
        'token': response.data['token'],
      };
    } catch (e) {
      debugPrint(' OTP verification error: $e');
      throw Exception('Code de vérification invalide');
    }
  }

  Future<Map<String, dynamic>> forgotPassword({required String contact}) async {
    try {
      debugPrint(' Requesting password reset for: $contact');

      final response = await _apiClient.post(
        ApiConstants.forgotPassword,
        data: {
          'contact': contact, // Email ou téléphone
        },
      );

      debugPrint(' Password reset requested');
      debugPrint(' Response: ${response.data}');

      final responseData = response.data is Map
          ? response.data
          : {'data': response.data};

      return responseData;
    } catch (e) {
      debugPrint(' Forgot password error: $e');
      throw Exception('Erreur lors de la demande de réinitialisation');
    }
  }

  ///  RÉINITIALISER le mot de passe avec OTP

  Future<void> resetPassword({
    required int userId,
    required String code,
    required String newPassword,
  }) async {
    try {
      debugPrint(' Resetting password for user: $userId');

      await _apiClient.post(
        ApiConstants.resetPassword,
        data: {'userId': userId, 'code': code, 'newPassword': newPassword},
      );

      debugPrint(' Password reset successful');
    } catch (e) {
      debugPrint(' Reset password error: $e');
      throw Exception('Erreur lors de la réinitialisation');
    }
  }

  ///  DÉCONNEXION
  Future<void> logout() async {
    try {
      debugPrint(' Logging out...');
      await _apiClient.post(ApiConstants.logout);
      debugPrint(' Logout successful');
    } catch (e) {
      debugPrint(' Logout API error (continuing with local logout): $e');
    } finally {
      await _storage.clearAll();
      debugPrint(' Local storage cleared');
    }
  }

  Future<UserModel> getCurrentUser() async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint(' [AuthService] Fetching current user WITH PHOTO...');
      debugPrint(' Endpoint: /api/parents/account');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final response = await _apiClient.get('/api/parents/account');

      debugPrint(' Response Status: ${response.statusCode}');
      debugPrint(' Response Type: ${response.data.runtimeType}');

      final dynamic responseData = response.data;

      if (responseData is Map<String, dynamic>) {
        Map<String, dynamic> userData;

        if (responseData.containsKey('data') && responseData['data'] != null) {
          debugPrint(' Extracting user from response.data');
          userData = responseData['data'];
        } else if (responseData.containsKey('user') &&
            responseData['user'] != null) {
          debugPrint(' Extracting user from response.user');
          userData = responseData['user'];
        } else {
          debugPrint(' Response is directly the user object');
          userData = responseData;
        }

        debugPrint('');
        debugPrint(' USER DATA:');
        debugPrint('   ID: ${userData['id']}');
        debugPrint('   Name: ${userData['name']}');
        debugPrint('   Email: ${userData['email']}');
        debugPrint(
          '   Photo (brut): ${userData['photo_profil'] ?? userData['photo']}',
        );
        debugPrint('');

        final user = UserModel.fromJson(userData);

        debugPrint(' UserModel created:');
        debugPrint('   Full Name: ${user.fullName}');
        debugPrint('   Photo URL: ${user.photo}');
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

        return user;
      }

      throw Exception('Format de réponse invalide: $responseData');
    } catch (e, stackTrace) {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint(' [AuthService] Get current user error');
      debugPrint('Error: $e');
      debugPrint('Stack: $stackTrace');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      throw Exception('Impossible de récupérer le profil: $e');
    }
  }

  Future<bool> isLoggedIn() async {
    return await _storage.isLoggedIn();
  }
}
