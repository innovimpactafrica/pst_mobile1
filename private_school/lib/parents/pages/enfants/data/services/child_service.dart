import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../../core/storage/secure_storage.dart';
import '../../../../../core/utils/api_constants.dart';
import '../models/child_model.dart';

class ChildService {
  final SecureStorage _secureStorage = SecureStorage();

  /// Récupérer les headers avec le token d'authentification
  Future<Map<String, String>> _getHeaders() async {
    final token = await _secureStorage.getAccessToken();
    return {
      'Content-Type': ApiConstants.contentType,
      'Authorization': 'Bearer $token',
    };
  }

  /// Récupérer la liste de tous les enfants du parent
  Future<List<ChildModel>> fetchChildren() async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.children}');

      final response = await http.get(
        url,
        headers: headers,
      ).timeout(ApiConstants.connectTimeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        // L'API retourne: { "children": [...] }
        final List<dynamic> childrenJson = jsonResponse['children'] ?? [];

        return childrenJson
            .map((childJson) => ChildModel.fromJson(childJson))
            .toList();
      } else if (response.statusCode == 401) {
        throw Exception('Session expirée. Veuillez vous reconnecter.');
      } else {
        throw Exception('Erreur lors du chargement des enfants');
      }
    } catch (e) {
      throw Exception('Erreur réseau: ${e.toString()}');
    }
  }

  /// Créer un nouvel enfant
  Future<ChildModel> createChild(ChildModel child) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.children}');

      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(child.toJson()),
      ).timeout(ApiConstants.connectTimeout);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        // L'API retourne: { "child": {...} }
        return ChildModel.fromJson(jsonResponse['child']);
      } else if (response.statusCode == 401) {
        throw Exception('Session expirée. Veuillez vous reconnecter.');
      } else {
        final errorMessage = json.decode(response.body)['message'] ?? 'Erreur lors de la création';
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('Erreur réseau: ${e.toString()}');
    }
  }

  /// Modifier les informations d'un enfant
  Future<ChildModel> updateChild(ChildModel child) async {
    try {
      final headers = await _getHeaders();

      // Vérifier que l'ID existe
      if (child.id == null || child.id!.isEmpty) {
        throw Exception('ID de l\'enfant manquant');
      }

      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.childById(child.id!)}');

      final response = await http.put(
        url,
        headers: headers,
        body: json.encode(child.toJson()),
      ).timeout(ApiConstants.connectTimeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        // L'API retourne: { "child": {...} }
        return ChildModel.fromJson(jsonResponse['child']);
      } else if (response.statusCode == 401) {
        throw Exception('Session expirée. Veuillez vous reconnecter.');
      } else {
        final errorMessage = json.decode(response.body)['message'] ?? 'Erreur lors de la modification';
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('Erreur réseau: ${e.toString()}');
    }
  }

  /// Supprimer un enfant
  Future<void> deleteChild(String childId) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.childById(childId)}');

      final response = await http.delete(
        url,
        headers: headers,
      ).timeout(ApiConstants.connectTimeout);

      if (response.statusCode == 200) {
        // Suppression réussie
        return;
      } else if (response.statusCode == 401) {
        throw Exception('Session expirée. Veuillez vous reconnecter.');
      } else {
        final errorMessage = json.decode(response.body)['message'] ?? 'Erreur lors de la suppression';
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('Erreur réseau: ${e.toString()}');
    }
  }

  /// Récupérer les détails d'un enfant spécifique
  Future<ChildModel> getChildById(String childId) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.childById(childId)}');

      final response = await http.get(
        url,
        headers: headers,
      ).timeout(ApiConstants.connectTimeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        // L'API retourne: { "child": {...} }
        return ChildModel.fromJson(jsonResponse['child']);
      } else if (response.statusCode == 401) {
        throw Exception('Session expirée. Veuillez vous reconnecter.');
      } else {
        throw Exception('Erreur lors du chargement des détails');
      }
    } catch (e) {
      throw Exception('Erreur réseau: ${e.toString()}');
    }
  }
}