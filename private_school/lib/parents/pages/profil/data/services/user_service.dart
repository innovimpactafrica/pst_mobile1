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

      // API can return either direct object or { data: {...} }
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

  /// Update personal information
  /// Endpoint: PUT /api/parents/account
  Future<UserModel> updateUserProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? email,
    String? address,
  }) async {
    try {
      debugPrint('📝 [UserService] Updating user profile...');

      final response = await _apiClient.put(
        ApiConstants.parentAccount,
        data: {
          if (firstName != null) 'firstName': firstName,
          if (lastName != null) 'lastName': lastName,
          if (phone != null) 'phone': phone,
          if (email != null) 'email': email,
          if (address != null) 'address': address,
        },
      );

      debugPrint('✅ [UserService] Profile updated successfully');

      final userData = response.data is Map
          ? (response.data['data'] ?? response.data)
          : response.data;

      return UserModel.fromJson(userData as Map<String, dynamic>);
    } catch (e) {
      debugPrint('❌ [UserService] Error updating profile: $e');
      throw Exception('Unable to update profile: $e');
    }
  }

  /// Update profile photo
  /// Endpoint: PUT /api/parents/account/photo
  Future<String> updateProfilePhoto(File photoFile) async {
    try {
      debugPrint('📸 [UserService] Uploading profile photo...');

      // Create FormData to send the file
      final formData = FormData.fromMap({
        'photo': await MultipartFile.fromFile(
          photoFile.path,
          filename: photoFile.path.split('/').last,
        ),
      });

      final response = await _apiClient.put(
        ApiConstants.parentAccountPhoto,
        data: formData,
      );

      debugPrint('✅ [UserService] Photo uploaded successfully');

      // API probably returns the photo URL
      final photoUrl = response.data is Map
          ? (response.data['photoUrl'] ??
                response.data['photo'] ??
                response.data['url'])
          : response.data;

      return photoUrl.toString();
    } catch (e) {
      debugPrint('❌ [UserService] Error uploading photo: $e');
      throw Exception('Unable to upload photo: $e');
    }
  }

  /// Update profile photo from file path
  Future<String> updateProfilePhotoFromPath(String photoPath) async {
    try {
      final file = File(photoPath);
      if (!await file.exists()) {
        throw Exception('File does not exist');
      }
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
      // Don't throw exception for logout
      // We want to log out the user even if the API fails
      debugPrint(
        '⚠️ [UserService] Continuing with local logout despite API error',
      );
    }
  }
}
