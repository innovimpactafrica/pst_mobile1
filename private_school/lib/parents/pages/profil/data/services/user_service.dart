import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/utils/api_constants.dart';
import '../../../../../core/models/user_model.dart';

/// Service for managing parent profile API calls
/// Handles profile retrieval, updates, and photo management
class UserService {
  final ApiClient _apiClient = ApiClient();

  /// Fetch current parent account information
  /// Endpoint: GET /api/parents/account
  Future<UserModel> fetchCurrentUser() async {
    try {
      debugPrint('🔍 [UserService] Fetching current user profile from API...');

      final response = await _apiClient.get(ApiConstants.parentAccount);

      debugPrint('✅ [UserService] Response received: ${response.statusCode}');
      debugPrint('📦 [UserService] Data: ${response.data}');

      final userData = response.data is Map
          ? (response.data['data'] ?? response.data)
          : response.data;

      final user = UserModel.fromJson(userData as Map<String, dynamic>);

      debugPrint('✅ [UserService] User profile loaded: ${user.fullName}');
      return user;
    } catch (e) {
      debugPrint('❌ [UserService] Error fetching user profile: $e');
      throw Exception('Unable to load profile: $e');
    }
  }

  /// ✅ CORRIGÉ: Update personal information
  /// L'API attend 'name' (nom complet), pas firstName/lastName séparés
  /// Endpoint: PUT /api/parents/account
  Future<UserModel> updateUserProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? email,
    String? address,
  }) async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('📝 [UserService] Updating user profile...');

      // ✅ CORRECTION: Combiner firstName + lastName en 'name'
      String? fullName;
      if (firstName != null && lastName != null) {
        fullName = '$firstName $lastName';
      } else if (firstName != null) {
        fullName = firstName;
      } else if (lastName != null) {
        fullName = lastName;
      }

      final requestData = {
        if (fullName != null) 'name': fullName, // ✅ 'name' au lieu de firstName/lastName
        if (phone != null) 'phone': phone,
        if (email != null) 'email': email,
        if (address != null) 'address': address,
      };

      debugPrint('📤 Request data: $requestData');

      final response = await _apiClient.put(
        ApiConstants.parentAccount,
        data: requestData,
      );

      debugPrint('✅ [UserService] Profile updated successfully');
      debugPrint('📦 Response: ${response.data}');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      final userData = response.data is Map
          ? (response.data['data'] ?? response.data)
          : response.data;

      return UserModel.fromJson(userData as Map<String, dynamic>);
    } catch (e) {
      if (e is DioException && e.response != null) {
        final errorMsg = e.response!.data['error'] ?? 
                        e.response!.data['message'] ?? 
                        'Erreur serveur';
        debugPrint('❌ [UserService] Error updating profile: $errorMsg');
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
        throw Exception('Requête invalide: $errorMsg');
      }
      debugPrint('❌ [UserService] Error updating profile: $e');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      throw Exception('Unable to update profile: $e');
    }
  }

  /// Update profile photo
  /// Endpoint: POST /api/parents/account/photo
  Future<String> updateProfilePhoto(File photoFile) async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('📸 [UserService] Uploading profile photo...');
      debugPrint('📂 File path: ${photoFile.path}');
      debugPrint('📏 File size: ${await photoFile.length()} bytes');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final formData = FormData.fromMap({
        'photo': await MultipartFile.fromFile(
          photoFile.path,
          filename: photoFile.path.split('/').last,
        ),
      });

      debugPrint('📤 Sending FormData with photo field');

      final response = await _apiClient.post(
        ApiConstants.parentAccountPhoto,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      debugPrint('✅ [UserService] Photo uploaded successfully');
      debugPrint('📦 Response: ${response.data}');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      // L'API retourne {data: {photo_url: "..."}}
      final photoUrl = response.data is Map
          ? (response.data['data']?['photo_url'] ??
                response.data['photoUrl'] ??
                response.data['photo'] ??
                response.data['photo_profil'] ??
                response.data['url'])
          : response.data;

      return photoUrl.toString();
    } catch (e) {
      debugPrint('❌ [UserService] Error uploading photo: $e');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      throw Exception('Unable to upload photo: $e');
    }
  }

  /// Update profile photo from file path
  Future<String> updateProfilePhotoFromPath(String photoPath) async {
    try {
      debugPrint('📂 [UserService] Preparing to upload photo from: $photoPath');
      
      final file = File(photoPath);
      if (!await file.exists()) {
        throw Exception('File does not exist at path: $photoPath');
      }

      debugPrint('✅ File exists, proceeding with upload...');
      return await updateProfilePhoto(file);
    } catch (e) {
      debugPrint('❌ [UserService] Error updating photo from path: $e');
      throw Exception('Unable to update photo: $e');
    }
  }

  /// Delete profile photo
  /// Endpoint: DELETE /api/parents/account/photo
  Future<void> deleteProfilePhoto() async {
    try {
      debugPrint('🗑️ [UserService] Deleting profile photo...');

      await _apiClient.delete(ApiConstants.parentAccountPhoto);

      debugPrint('✅ [UserService] Photo deleted successfully');
    } catch (e) {
      debugPrint('❌ [UserService] Error deleting photo: $e');
      throw Exception('Unable to delete photo: $e');
    }
  }

  /// Logout
  /// Endpoint: POST /api/auth/logout
  Future<void> logout() async {
    try {
      debugPrint('👋 [UserService] Logging out...');

      await _apiClient.post(ApiConstants.logout);

      debugPrint('✅ [UserService] Logged out successfully');
    } catch (e) {
      debugPrint('❌ [UserService] Error logging out: $e');
      debugPrint(
        '⚠️ [UserService] Continuing with local logout despite API error',
      );
    }
  }
}