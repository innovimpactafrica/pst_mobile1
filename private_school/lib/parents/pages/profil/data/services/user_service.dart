/// Service pour gérer les appels API du profil parent
/// Chemin: lib/parents/profil/data/services/user_service.dart

import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/utils/api_constants.dart';
import '../models/ user_model.dart';


class UserService {
  final ApiClient _apiClient = ApiClient();

  /// ✅ Récupérer les informations du compte parent connecté
  /// Endpoint: GET /api/parents/account
  Future<UserModel> fetchCurrentUser() async {
    try {
      print('🔍 Fetching current user profile from API...');

      final response = await _apiClient.get(ApiConstants.account);

      print('✅ Response received: ${response.statusCode}');
      print('📦 Data: ${response.data}');

      // L'API peut retourner soit l'objet direct, soit { data: {...} }
      final userData = response.data is Map
          ? (response.data['data'] ?? response.data)
          : response.data;

      final user = UserModel.fromJson(userData as Map<String, dynamic>);

      print('✅ User profile loaded: ${user.fullName}');
      return user;
    } catch (e) {
      print('❌ Error fetching user profile: $e');
      throw Exception('Impossible de charger le profil: $e');
    }
  }

  /// ✅ Mettre à jour les informations personnelles
  /// Endpoint: PUT /api/parents/account
  Future<UserModel> updateUserProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? email,
    String? address,
  }) async {
    try {
      print('📝 Updating user profile...');

      final response = await _apiClient.put(
        ApiConstants.account,
        data: {
          if (firstName != null) 'firstName': firstName,
          if (lastName != null) 'lastName': lastName,
          if (phone != null) 'phone': phone,
          if (email != null) 'email': email,
          if (address != null) 'address': address,
        },
      );

      print('✅ Profile updated successfully');

      final userData = response.data is Map
          ? (response.data['data'] ?? response.data)
          : response.data;

      return UserModel.fromJson(userData as Map<String, dynamic>);
    } catch (e) {
      print('❌ Error updating profile: $e');
      throw Exception('Impossible de mettre à jour le profil: $e');
    }
  }

  /// ✅ Modifier la photo de profil
  /// Endpoint: PUT /api/parents/account/photo
  Future<String> updateProfilePhoto(File photoFile) async {
    try {
      print('📸 Uploading profile photo...');

      // Créer un FormData pour envoyer le fichier
      final formData = FormData.fromMap({
        'photo': await MultipartFile.fromFile(
          photoFile.path,
          filename: photoFile.path.split('/').last,
        ),
      });

      final response = await _apiClient.put(
        ApiConstants.accountPhoto,
        data: formData,
      );

      print('✅ Photo uploaded successfully');

      // L'API retourne probablement l'URL de la photo
      final photoUrl = response.data is Map
          ? (response.data['photoUrl'] ?? response.data['photo'] ?? response.data['url'])
          : response.data;

      return photoUrl.toString();
    } catch (e) {
      print('❌ Error uploading photo: $e');
      throw Exception('Impossible de télécharger la photo: $e');
    }
  }

  /// ✅ Modifier la photo de profil (depuis un chemin de fichier)
  Future<String> updateProfilePhotoFromPath(String photoPath) async {
    try {
      final file = File(photoPath);
      if (!await file.exists()) {
        throw Exception('Le fichier n\'existe pas');
      }
      return await updateProfilePhoto(file);
    } catch (e) {
      print('❌ Error updating photo from path: $e');
      throw Exception('Impossible de mettre à jour la photo: $e');
    }
  }

  /// ✅ Supprimer la photo de profil
  /// Endpoint: DELETE /api/parents/account/photo
  Future<void> deleteProfilePhoto() async {
    try {
      print('🗑️ Deleting profile photo...');

      await _apiClient.delete(ApiConstants.accountPhoto);

      print('✅ Photo deleted successfully');
    } catch (e) {
      print('❌ Error deleting photo: $e');
      throw Exception('Impossible de supprimer la photo: $e');
    }
  }

  /// ✅ Déconnexion
  /// Endpoint: POST /api/auth/logout
  Future<void> logout() async {
    try {
      print('👋 Logging out...');

      await _apiClient.post(ApiConstants.logout);

      print('✅ Logged out successfully');
    } catch (e) {
      print('❌ Error logging out: $e');
      // Ne pas throw d'exception pour la déconnexion
      // On veut déconnecter l'utilisateur même si l'API échoue
      print('⚠️ Continuing with local logout despite API error');
    }
  }
}