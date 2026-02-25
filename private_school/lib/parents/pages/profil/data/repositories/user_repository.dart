import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../../../../core/storage/secure_storage.dart';
import '../../../../../core/models/user_model.dart';
import '../services/user_service.dart';

class UserRepository {
  final UserService _userService = UserService();
  final SecureStorage _storage = SecureStorage();

  Future<UserModel> getCurrentUser() async {
    try {
      return await _userService.fetchCurrentUser();
    } catch (e) {
      debugPrint(' [UserRepository] Failed to load user - $e');
      throw Exception('Unable to load profile: $e');
    }
  }

  Future<UserModel> updateUser(UserModel user) async {
    try {
      return await _userService.updateUserProfile(
        firstName: user.firstName,
        lastName: user.lastName,
        phone: user.phone,
        email: user.email,
        address: user.address,
      );
    } catch (e) {
      debugPrint(' [UserRepository] Failed to update user - $e');
      throw Exception('Unable to update profile: $e');
    }
  }

  Future<UserModel> updateUserFields({
    String? firstName,
    String? lastName,
    String? phone,
    String? email,
    String? address,
  }) async {
    try {
      return await _userService.updateUserProfile(
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        email: email,
        address: address,
      );
    } catch (e) {
      debugPrint(' [UserRepository] Failed to update user fields - $e');
      throw Exception('Unable to update profile: $e');
    }
  }

  /// Update profile photo
  Future<String> updateProfilePhoto(File photoFile) async {
    try {
      return await _userService.updateProfilePhoto(photoFile);
    } catch (e) {
      debugPrint(' [UserRepository] Failed to update photo - $e');
      throw Exception('Unable to update photo: $e');
    }
  }

  /// Update profile photo from file path
  Future<String> updateProfilePhotoFromPath(String photoPath) async {
    try {
      return await _userService.updateProfilePhotoFromPath(photoPath);
    } catch (e) {
      debugPrint(' [UserRepository] Failed to update photo from path - $e');
      throw Exception('Unable to update photo: $e');
    }
  }

  /// Delete profile photo
  Future<void> deleteProfilePhoto() async {
    try {
      await _userService.deleteProfilePhoto();
    } catch (e) {
      debugPrint(' [UserRepository] Failed to delete photo - $e');
      throw Exception('Unable to delete photo: $e');
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      await _userService.logout();
    } catch (e) {
      debugPrint(
        ' [UserRepository] API logout failed, continuing with local logout - $e',
      );
    } finally {
      await _storage.clearAll();
      debugPrint(' [UserRepository] Local data cleared');
    }
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    try {
      return await _storage.isLoggedIn();
    } catch (e) {
      debugPrint(' [UserRepository] Failed to check login status - $e');
      return false;
    }
  }
}
