import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/utils/api_constants.dart';
import '../../../../../core/models/user_model.dart';

class UserService {
  final ApiClient _apiClient = ApiClient();

  Future<UserModel> fetchCurrentUser() async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint(' [UserService] CHARGEMENT PROFIL');

      final response = await _apiClient.get(ApiConstants.parentAccount);

      debugPrint(' Response Status: ${response.statusCode}');
      debugPrint(' Response Type: ${response.data.runtimeType}');
      debugPrint(' Response Data: ${response.data}');

      final userData = response.data is Map
          ? (response.data['data'] ?? response.data)
          : response.data;

      debugPrint('');
      debugPrint(' ADRESSE DANS LA RÉPONSE API:');
      debugPrint('   address: ${userData['address']}');
      debugPrint('   adresse: ${userData['adresse']}');
      debugPrint('   home_address: ${userData['home_address']}');
      debugPrint('   homeAddress: ${userData['homeAddress']}');
      debugPrint('');

      final user = UserModel.fromJson(userData as Map<String, dynamic>);

      debugPrint(' UserModel créé:');
      debugPrint('   fullName: ${user.fullName}');
      debugPrint('   email: ${user.email}');
      debugPrint('   phone: ${user.phone}');
      debugPrint('   address: ${user.address}');
      debugPrint('   photo: ${user.photo}');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      return user;
    } catch (e) {
      debugPrint(' [UserService] Error fetching user: $e');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      throw Exception('Unable to load profile: $e');
    }
  }

  Future<UserModel> updateUserProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? email,
    String? address,
  }) async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint(' [UserService] MISE À JOUR PROFIL');

      String? fullName;
      if (firstName != null && lastName != null) {
        fullName = '$firstName $lastName';
      } else if (firstName != null) {
        fullName = firstName;
      } else if (lastName != null) {
        fullName = lastName;
      }

      final requestData = {
        if (fullName != null) 'name': fullName,
        if (phone != null) 'phone': phone,
        if (email != null) 'email': email,
        if (address != null) 'home_address': address,
        if (address != null) 'address': address,
      };

      debugPrint(' Request data:');
      debugPrint('   name: $fullName');
      debugPrint('   phone: $phone');
      debugPrint('   email: $email');
      debugPrint('   home_address: $address');
      debugPrint('   address: $address');

      final response = await _apiClient.put(
        ApiConstants.parentAccount,
        data: requestData,
      );

      debugPrint(' Profile updated successfully');
      debugPrint(' Response: ${response.data}');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      final userData = response.data is Map
          ? (response.data['data'] ?? response.data)
          : response.data;

      return UserModel.fromJson(userData as Map<String, dynamic>);
    } catch (e) {
      if (e is DioException && e.response != null) {
        final errorMsg =
            e.response!.data['error'] ??
            e.response!.data['message'] ??
            'Erreur serveur';
        debugPrint(' [UserService] Error: $errorMsg');
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
        throw Exception('Requête invalide: $errorMsg');
      }
      debugPrint(' [UserService] Error: $e');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      throw Exception('Unable to update profile: $e');
    }
  }

  Future<String> updateProfilePhoto(File photoFile) async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint(' [UserService] Uploading profile photo...');
      debugPrint(' File path: ${photoFile.path}');
      debugPrint(' File size: ${await photoFile.length()} bytes');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final formData = FormData.fromMap({
        'photo': await MultipartFile.fromFile(
          photoFile.path,
          filename: photoFile.path.split('/').last,
        ),
      });

      debugPrint(' Sending FormData with photo field');

      final response = await _apiClient.post(
        ApiConstants.parentAccountPhoto,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      debugPrint(' [UserService] Photo uploaded successfully');
      debugPrint(' Response: ${response.data}');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      final photoUrl = response.data is Map
          ? (response.data['data']?['photo_url'] ??
                response.data['photoUrl'] ??
                response.data['photo'] ??
                response.data['photo_profil'] ??
                response.data['url'])
          : response.data;

      return photoUrl.toString();
    } catch (e) {
      debugPrint(' [UserService] Error uploading photo: $e');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      throw Exception('Unable to upload photo: $e');
    }
  }

  Future<String> updateProfilePhotoFromPath(String photoPath) async {
    try {
      debugPrint(' [UserService] Preparing to upload photo from: $photoPath');

      final file = File(photoPath);
      if (!await file.exists()) {
        throw Exception('File does not exist at path: $photoPath');
      }

      debugPrint(' File exists, proceeding with upload...');
      return await updateProfilePhoto(file);
    } catch (e) {
      debugPrint(' [UserService] Error updating photo from path: $e');
      throw Exception('Unable to update photo: $e');
    }
  }

  Future<void> deleteProfilePhoto() async {
    try {
      debugPrint(' [UserService] Deleting profile photo...');

      await _apiClient.delete(ApiConstants.parentAccountPhoto);

      debugPrint('[UserService] Photo deleted successfully');
    } catch (e) {
      debugPrint(' [UserService] Error deleting photo: $e');
      throw Exception('Unable to delete photo: $e');
    }
  }

  Future<void> logout() async {
    try {
      debugPrint(' [UserService] Logging out...');

      await _apiClient.post(ApiConstants.logout);

      debugPrint(' [UserService] Logged out successfully');
    } catch (e) {
      debugPrint(' [UserService] Error logging out: $e');
      debugPrint(
        ' [UserService] Continuing with local logout despite API error',
      );
    }
  }
}
