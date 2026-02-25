import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../../../core/network/api_client.dart';
import '../models/school_model.dart';

class SchoolService {
  final ApiClient _apiClient = ApiClient();

  /// Récupérer toutes les écoles
  Future<List<SchoolModel>> fetchSchools() async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint(' [SchoolService] GET SCHOOLS');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final response = await _apiClient.get('/api/schools');

      debugPrint(' [SchoolService] Response: ${response.statusCode}');
      debugPrint(' [SchoolService] Data: ${response.data}');

      final List<dynamic> schoolsJson;

      if (response.data is Map<String, dynamic>) {
        schoolsJson = response.data['schools'] ?? response.data['data'] ?? [];
      } else if (response.data is List) {
        schoolsJson = response.data;
      } else {
        throw Exception('Format de réponse invalide');
      }

      debugPrint(' [SchoolService] ${schoolsJson.length} école(s) trouvée(s)');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      return schoolsJson.map((json) => SchoolModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint(' [SchoolService] Error fetching schools: $e');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      rethrow;
    }
  }

  Future<SchoolModel> createSchool(SchoolModel school) async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint(' [SchoolService] POST CREATE SCHOOL');
      debugPrint(' Data: ${school.toJson()}');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final formData = FormData.fromMap({
        'name': school.name,
        'address': school.address,
        'opening_time': school.openingTime ?? '08:00:00',
        'closing_time': school.closingTime ?? '18:00:00',
      });

      debugPrint(' Sending as FormData (multipart/form-data)');

      final response = await _apiClient.post('/api/schools', data: formData);

      debugPrint(' [SchoolService] Response: ${response.statusCode}');
      debugPrint(' [SchoolService] Data: ${response.data}');

      final Map<String, dynamic> schoolData;

      if (response.data is Map<String, dynamic>) {
        if (response.data.containsKey('school')) {
          schoolData = response.data['school'];
        } else if (response.data.containsKey('data')) {
          schoolData = response.data['data'];
        } else {
          schoolData = response.data;
        }
      } else {
        throw Exception('Format de réponse invalide');
      }

      debugPrint(
        ' [SchoolService] École créée: ${schoolData['name']} (ID: ${schoolData['id']})',
      );
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      return SchoolModel.fromJson(schoolData);
    } catch (e) {
      debugPrint(' [SchoolService] Error creating school: $e');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      rethrow;
    }
  }

  /// Mettre à jour une école
  Future<SchoolModel> updateSchool(SchoolModel school) async {
    try {
      if (school.id == null) {
        throw Exception('ID de l\'école manquant');
      }

      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint(' [SchoolService] PUT UPDATE SCHOOL');
      debugPrint(' School ID: ${school.id}');
      debugPrint(' Data: ${school.toJson()}');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final response = await _apiClient.put(
        '/api/schools/${school.id}',
        data: school.toJson(),
      );

      debugPrint(' [SchoolService] Response: ${response.statusCode}');
      debugPrint(' [SchoolService] Data: ${response.data}');

      final Map<String, dynamic> schoolData;

      if (response.data is Map<String, dynamic>) {
        if (response.data.containsKey('school')) {
          schoolData = response.data['school'];
        } else if (response.data.containsKey('data')) {
          schoolData = response.data['data'];
        } else {
          schoolData = response.data;
        }
      } else {
        throw Exception('Format de réponse invalide');
      }

      debugPrint(' [SchoolService] École mise à jour: ${schoolData['name']}');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      return SchoolModel.fromJson(schoolData);
    } catch (e) {
      debugPrint(' [SchoolService] Error updating school: $e');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      rethrow;
    }
  }

  Future<SchoolModel> findOrCreateSchool(
    String schoolName,
    String address,
  ) async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint(' [SchoolService] FIND OR CREATE SCHOOL');
      debugPrint(' Name: $schoolName');
      debugPrint(' Address: $address');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      //  Récupérer toutes les écoles
      final schools = await fetchSchools();

      //  Chercher si l'école existe déjà
      try {
        final existingSchool = schools.firstWhere(
          (school) =>
              school.name.trim().toLowerCase() ==
              schoolName.trim().toLowerCase(),
        );

        debugPrint(
          ' École trouvée: ${existingSchool.name} (ID: ${existingSchool.id})',
        );
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
        return existingSchool;
      } catch (e) {
        debugPrint(' École non trouvée, création...');
      }

      //  Créer une nouvelle école
      debugPrint(' Création d\'une nouvelle école: $schoolName');
      final newSchool = SchoolModel(
        name: schoolName.trim(),
        address: address.trim(),
        openingTime: '08:00:00',
        closingTime: '18:00:00',
      );

      return await createSchool(newSchool);
    } catch (e) {
      debugPrint(' [SchoolService] Error in findOrCreateSchool: $e');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      rethrow;
    }
  }
}
