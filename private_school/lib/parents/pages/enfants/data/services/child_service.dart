import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/utils/api_constants.dart';
import '../../../../../core/storage/secure_storage.dart';
import '../models/child_model.dart';

class ChildService {
  final ApiClient _apiClient = ApiClient();
  final SecureStorage _storage = SecureStorage();

  Future<void> _debugToken() async {
    try {
      final token = await _storage.getAccessToken();

      if (token == null) {
        debugPrint(' AUCUN TOKEN TROUVÉ !');
        return;
      }

      debugPrint(
        ' Token (30 premiers caractères): ${token.substring(0, 30)}...',
      );

      final parts = token.split('.');
      if (parts.length >= 2) {
        try {
          final payload = utf8.decode(
            base64Url.decode(base64Url.normalize(parts[1])),
          );
          final decoded = jsonDecode(payload);

          debugPrint(' TOKEN PAYLOAD:');
          debugPrint('   User ID: ${decoded['id']}');
          debugPrint('   Role: ${decoded['role']}');

          if (decoded['exp'] != null) {
            final expDate = DateTime.fromMillisecondsSinceEpoch(
              decoded['exp'] * 1000,
            );
            debugPrint('   Expire le: $expDate');
          }
        } catch (e) {
          debugPrint(' Erreur décodage token: $e');
        }
      }
    } catch (e) {
      debugPrint(' Erreur debug token: $e');
    }
  }

  Future<List<ChildModel>> fetchChildren() async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint(' [ChildService] GET CHILDREN');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      await _debugToken();

      debugPrint('');
      debugPrint(' Endpoint: ${ApiConstants.children}');

      final response = await _apiClient.get(ApiConstants.children);

      debugPrint('');
      debugPrint(' Response Status: ${response.statusCode}');
      debugPrint(' Response Type: ${response.data.runtimeType}');
      debugPrint(' Response Data: ${response.data}');

      final List<dynamic> childrenJson;

      if (response.data is Map<String, dynamic>) {
        childrenJson = response.data['children'] ?? response.data['data'] ?? [];
      } else if (response.data is List) {
        childrenJson = response.data;
      } else {
        throw Exception('Format de réponse invalide');
      }

      debugPrint('');
      debugPrint(' ENFANTS TROUVÉS: ${childrenJson.length}');

      for (var i = 0; i < childrenJson.length; i++) {
        final child = childrenJson[i];
        debugPrint('   Enfant $i:');
        debugPrint('      - ID: ${child['id']}');
        debugPrint(
          '      - Nom: ${child['name'] ?? child['firstname']} ${child['lastname'] ?? ''}',
        );
        debugPrint('      - Parent ID: ${child['parent_id']}');
      }

      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      return childrenJson
          .map((childJson) => ChildModel.fromJson(childJson))
          .toList();
    } catch (e) {
      debugPrint(' [ChildService] Error fetching children: $e');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      rethrow;
    }
  }

  ///  Créer un nouvel enfant
  Future<ChildModel> createChild(ChildModel child) async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint(' [ChildService] POST CREATE CHILD');

      await _debugToken();

      debugPrint('');
      debugPrint(' Data to send: ${child.toJson()}');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final response = await _apiClient.post(
        ApiConstants.children,
        data: child.toJson(),
      );

      debugPrint(' Response Status: ${response.statusCode}');
      debugPrint(' Response Data: ${response.data}');

      final Map<String, dynamic> childData;

      if (response.data is Map<String, dynamic>) {
        if (response.data.containsKey('child')) {
          childData = response.data['child'];
        } else if (response.data.containsKey('data')) {
          childData = response.data['data'];
        } else {
          childData = response.data;
        }
      } else {
        throw Exception('Format de réponse invalide');
      }

      debugPrint(' Enfant créé: ${childData['name']}');
      debugPrint('   Parent ID: ${childData['parent_id']}');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      return ChildModel.fromJson(childData);
    } catch (e) {
      debugPrint(' [ChildService] Error creating child: $e');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      rethrow;
    }
  }

  ///  Mettre à jour un enfant
  Future<ChildModel> updateChild(ChildModel child) async {
    try {
      if (child.id == null || child.id!.isEmpty) {
        throw Exception('ID de l\'enfant manquant');
      }

      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint(' [ChildService] PUT UPDATE CHILD');
      debugPrint(' Child ID: ${child.id}');
      debugPrint(' Data to send: ${child.toJson()}');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final response = await _apiClient.put(
        ApiConstants.childById(child.id!),
        data: child.toJson(),
      );

      debugPrint(' Response Status: ${response.statusCode}');
      debugPrint(' Response Data: ${response.data}');

      final Map<String, dynamic> childData;

      if (response.data is Map<String, dynamic>) {
        if (response.data.containsKey('child')) {
          childData = response.data['child'];
        } else if (response.data.containsKey('data')) {
          childData = response.data['data'];
        } else {
          childData = response.data;
        }
      } else {
        throw Exception('Format de réponse invalide');
      }

      debugPrint(' Enfant mis à jour: ${childData['name']}');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      return ChildModel.fromJson(childData);
    } catch (e) {
      debugPrint(' [ChildService] Error updating child: $e');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      rethrow;
    }
  }

  ///  Supprimer un enfant
  Future<void> deleteChild(String childId) async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint(' [ChildService] DELETE CHILD');
      debugPrint(' Child ID: $childId');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final response = await _apiClient.delete(ApiConstants.childById(childId));

      debugPrint(' Response Status: ${response.statusCode}');
      debugPrint(' Enfant supprimé');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
    } catch (e) {
      debugPrint(' [ChildService] Error deleting child: $e');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      rethrow;
    }
  }

  ///  Récupérer un enfant par ID
  Future<ChildModel> getChildById(String childId) async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint(' [ChildService] GET CHILD BY ID');
      debugPrint(' Child ID: $childId');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final response = await _apiClient.get(ApiConstants.childById(childId));

      debugPrint(' Response Status: ${response.statusCode}');
      debugPrint(' Response Data: ${response.data}');

      final Map<String, dynamic> childData;

      if (response.data is Map<String, dynamic>) {
        if (response.data.containsKey('child')) {
          childData = response.data['child'];
        } else if (response.data.containsKey('data')) {
          childData = response.data['data'];
        } else {
          childData = response.data;
        }
      } else {
        throw Exception('Format de réponse invalide');
      }

      debugPrint(' Enfant trouvé: ${childData['name']}');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      return ChildModel.fromJson(childData);
    } catch (e) {
      debugPrint(' [ChildService] Error fetching child by ID: $e');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      rethrow;
    }
  }

  Future<void> updateChildSchedule(
    String childId,
    Map<String, DaySchedule> schedule,
  ) async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint(' [ChildService] PUT UPDATE SCHEDULE');
      debugPrint(' Child ID: $childId');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final Map<String, String> dayMapping = {
        'Lun.': 'monday',
        'Mar': 'tuesday',
        'Mer.': 'wednesday',
        'Jeu': 'thursday',
        'Ven.': 'friday',
        'Sam.': 'saturday',
        'Dim.': 'sunday',
        'Lundi': 'monday',
        'Mardi': 'tuesday',
        'Mercredi': 'wednesday',
        'Jeudi': 'thursday',
        'Vendredi': 'friday',
        'Samedi': 'saturday',
        'Dimanche': 'sunday',
      };

      final Map<String, Map<String, dynamic>> uniqueSchedules = {};

      schedule.forEach((day, daySchedule) {
        if (daySchedule.isOpen) {
          final apiDay = dayMapping[day] ?? day.toLowerCase();

          uniqueSchedules[apiDay] = {
            'day': apiDay,
            'arrival_time': daySchedule.startTime ?? '08:00',
            'departure_time': daySchedule.endTime ?? '18:00',
          };
        }
      });

      final List<Map<String, dynamic>> scheduleList = uniqueSchedules.values
          .toList();

      final data = {
        'child_id': int.tryParse(childId) ?? 0,
        'schedules': scheduleList,
      };

      debugPrint(' Data to send (API format): $data');
      debugPrint(' Unique days count: ${uniqueSchedules.length}');

      final response = await _apiClient.put(
        '/api/parents/children/schedules',
        data: data,
      );

      debugPrint(' Response Status: ${response.statusCode}');
      debugPrint(' Response Data: ${response.data}');
      debugPrint(' Horaires mis à jour pour l\'enfant $childId');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
    } catch (e) {
      debugPrint(' [ChildService] Error updating schedule: $e');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      rethrow;
    }
  }
}
