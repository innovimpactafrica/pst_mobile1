import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:private_school/core/storage/secure_storage.dart';
import 'package:private_school/core/utils/base_url.dart';

class UserService {
  final SecureStorage _storage = SecureStorage();

  ///  Récupérer tous les utilisateurs
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    debugPrint('🔄 UserService.getAllUsers - START');

    try {
      final token = await _storage.getAccessToken();
      debugPrint(' Token récupéré: ${token?.substring(0, 20)}...');

      final url = Uri.parse('${BaseUrl.current}/api/users');
      debugPrint('📡 URL: $url');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      debugPrint(' Status Code: ${response.statusCode}');
      debugPrint(' Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final List<dynamic> usersJson = data is List
            ? data
            : (data['data'] ?? data['users'] ?? []);

        debugPrint(' ${usersJson.length} utilisateurs récupérés');

        final users = usersJson.map((json) {
          return {
            'id': json['id'] as int,
            'name':
                json['full_name'] as String? ??
                json['name'] as String? ??
                'Utilisateur',
            'role': json['role'] as String? ?? 'user',
            'phone': json['phone'] as String?,
            'photo': json['photo'] as String?,
            'email': json['email'] as String?,
          };
        }).toList();

        return users;
      } else {
        debugPrint(' Erreur HTTP: ${response.statusCode}');
        throw Exception(
          'Erreur lors de la récupération des utilisateurs: ${response.statusCode}',
        );
      }
    } catch (e, stackTrace) {
      debugPrint(' Exception dans getAllUsers: $e');
      debugPrint(' StackTrace: $stackTrace');
      rethrow;
    }
  }

  /// Récupérer l'utilisateur actuel
  Future<Map<String, dynamic>?> getCurrentUser() async {
    debugPrint(' UserService.getCurrentUser - START');

    try {
      final userDataRaw = await _storage.getUserData();

      if (userDataRaw == null || userDataRaw.isEmpty) {
        debugPrint(' Aucune donnée utilisateur trouvée');
        return null;
      }

      debugPrint(' User data: $userDataRaw');

      try {
        final decoded = jsonDecode(userDataRaw) as Map<String, dynamic>;
        return {
          'id': decoded['id'],
          'name': decoded['full_name'] ?? decoded['name'] ?? 'Moi',
          'role': decoded['role'] ?? 'parent',
          'phone': decoded['phone'],
          'photo': decoded['photo'],
          'email': decoded['email'],
        };
      } catch (e) {
        debugPrint(' Erreur parsing user data: $e');
        return null;
      }
    } catch (e, stackTrace) {
      debugPrint(' Exception dans getCurrentUser: $e');
      debugPrint(' StackTrace: $stackTrace');
      return null;
    }
  }
}
