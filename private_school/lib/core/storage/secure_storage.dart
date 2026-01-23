/// Service de stockage sécurisé pour les tokens
/// Chemin: lib/core/storage/secure_storage.dart

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/api_constants.dart';

class SecureStorage {
  static final SecureStorage _instance = SecureStorage._internal();
  factory SecureStorage() => _instance;
  SecureStorage._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  //  Sauvegarder le token d'accès
  Future<void> saveAccessToken(String token) async {
    await _storage.write(
      key: ApiConstants.accessTokenKey,
      value: token,
    );
  }

  //  Récupérer le token d'accès
  Future<String?> getAccessToken() async {
    return await _storage.read(key: ApiConstants.accessTokenKey);
  }

  //  Sauvegarder le refresh token
  Future<void> saveRefreshToken(String token) async {
    await _storage.write(
      key: ApiConstants.refreshTokenKey,
      value: token,
    );
  }

  //  Récupérer le refresh token
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: ApiConstants.refreshTokenKey);
  }

  //  Sauvegarder les données utilisateur
  Future<void> saveUserData(String userData) async {
    await _storage.write(
      key: ApiConstants.userDataKey,
      value: userData,
    );
  }

  //  Récupérer les données utilisateur
  Future<String?> getUserData() async {
    return await _storage.read(key: ApiConstants.userDataKey);
  }

  //  Supprimer tous les tokens (déconnexion)
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  //  Vérifier si l'utilisateur est connecté
  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}