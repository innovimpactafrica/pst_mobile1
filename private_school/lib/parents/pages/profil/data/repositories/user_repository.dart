/// Repository pour gérer la logique métier du profil utilisateur
/// Chemin: lib/parents/profil/data/repositories/user_repository.dart

import 'dart:io';
import '../../../../../core/storage/secure_storage.dart';
import '../models/ user_model.dart';
import '../services/user_service.dart';

class UserRepository {
  final UserService _userService = UserService();
  final SecureStorage _storage = SecureStorage();

  /// Récupère les infos de l'utilisateur connecté
  Future<UserModel> getCurrentUser() async {
    try {
      return await _userService.fetchCurrentUser();
    } catch (e) {
      print('❌ Repository: Failed to load user - $e');
      throw Exception('Impossible de charger le profil: $e');
    }
  }

  /// Met à jour les informations de l'utilisateur
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
      print('❌ Repository: Failed to update user - $e');
      throw Exception('Impossible de mettre à jour le profil: $e');
    }
  }

  /// Met à jour uniquement certains champs
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
      print('❌ Repository: Failed to update user fields - $e');
      throw Exception('Impossible de mettre à jour le profil: $e');
    }
  }

  /// Met à jour la photo de profil
  Future<String> updateProfilePhoto(File photoFile) async {
    try {
      return await _userService.updateProfilePhoto(photoFile);
    } catch (e) {
      print('❌ Repository: Failed to update photo - $e');
      throw Exception('Impossible de mettre à jour la photo: $e');
    }
  }

  /// Met à jour la photo de profil depuis un chemin
  Future<String> updateProfilePhotoFromPath(String photoPath) async {
    try {
      return await _userService.updateProfilePhotoFromPath(photoPath);
    } catch (e) {
      print('❌ Repository: Failed to update photo from path - $e');
      throw Exception('Impossible de mettre à jour la photo: $e');
    }
  }

  /// Supprime la photo de profil
  Future<void> deleteProfilePhoto() async {
    try {
      await _userService.deleteProfilePhoto();
    } catch (e) {
      print('❌ Repository: Failed to delete photo - $e');
      throw Exception('Impossible de supprimer la photo: $e');
    }
  }

  /// Déconnexion
  Future<void> logout() async {
    try {
      // Appeler l'API pour déconnecter côté serveur
      await _userService.logout();
    } catch (e) {
      print('⚠️ Repository: API logout failed, continuing with local logout - $e');
      // On continue quand même avec la déconnexion locale
    } finally {
      // Supprimer tous les tokens localement (TOUJOURS exécuté)
      await _storage.clearAll();
      print('✅ Local data cleared');
    }
  }

  /// Vérifie si l'utilisateur est connecté
  Future<bool> isLoggedIn() async {
    try {
      return await _storage.isLoggedIn();
    } catch (e) {
      print('❌ Repository: Failed to check login status - $e');
      return false;
    }
  }
}