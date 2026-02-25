import 'package:http/http.dart' as http;
import 'dart:convert';
import '../storage/secure_storage.dart';
import '../utils/base_url.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final SecureStorage _storage = SecureStorage();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _storage.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${BaseUrl.baseUrl}$endpoint'),
        headers: headers,
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Erreur de connexion'};
    }
  }

  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('${BaseUrl.baseUrl}$endpoint'),
        headers: headers,
        body: json.encode(data),
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Erreur de connexion'};
    }
  }

  Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? data,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('${BaseUrl.baseUrl}$endpoint'),
        headers: headers,
        body: data != null ? json.encode(data) : null,
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Erreur de connexion'};
    }
  }

  Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('${BaseUrl.baseUrl}$endpoint'),
        headers: headers,
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Erreur de connexion'};
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final data = json.decode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data;
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Erreur serveur',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur de traitement des données'};
    }
  }
}
