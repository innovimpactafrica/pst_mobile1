import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/utils/api_constants.dart';
import '../models/child_model.dart';

class ChildService {
  final ApiClient _apiClient = ApiClient();

  /// ✅ Récupérer tous les enfants du parent connecté
  Future<List<ChildModel>> fetchChildren() async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🔵 [ChildService] GET CHILDREN');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final response = await _apiClient.get(ApiConstants.children);

      debugPrint('✅ [ChildService] Response received: ${response.statusCode}');
      debugPrint('📦 [ChildService] Data: ${response.data}');

      // Extraire les enfants de la réponse
      final List<dynamic> childrenJson;

      if (response.data is Map<String, dynamic>) {
        // Format: {children: [...]} ou {data: [...]}
        childrenJson = response.data['children'] ?? response.data['data'] ?? [];
      } else if (response.data is List) {
        // Format direct: [...]
        childrenJson = response.data;
      } else {
        throw Exception('Format de réponse invalide');
      }

      debugPrint('✅ [ChildService] ${childrenJson.length} enfant(s) trouvé(s)');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      return childrenJson
          .map((childJson) => ChildModel.fromJson(childJson))
          .toList();
    } catch (e) {
      debugPrint('❌ [ChildService] Error fetching children: $e');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      rethrow;
    }
  }

  /// ✅ Créer un nouvel enfant
  Future<ChildModel> createChild(ChildModel child) async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🟢 [ChildService] POST CREATE CHILD');
      debugPrint('📤 Data to send: ${child.toJson()}');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final response = await _apiClient.post(
        ApiConstants.children,
        data: child.toJson(),
      );

      debugPrint('✅ [ChildService] Response received: ${response.statusCode}');
      debugPrint('📦 [ChildService] Data: ${response.data}');

      // Extraire l'enfant créé
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

      debugPrint('✅ [ChildService] Enfant créé: ${childData['name']}');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      return ChildModel.fromJson(childData);
    } catch (e) {
      debugPrint('❌ [ChildService] Error creating child: $e');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      rethrow;
    }
  }

  /// ✅ Mettre à jour un enfant
  Future<ChildModel> updateChild(ChildModel child) async {
    try {
      if (child.id == null || child.id!.isEmpty) {
        throw Exception('ID de l\'enfant manquant');
      }

      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🟡 [ChildService] PUT UPDATE CHILD');
      debugPrint('📤 Child ID: ${child.id}');
      debugPrint('📤 Data to send: ${child.toJson()}');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final response = await _apiClient.put(
        ApiConstants.childById(child.id!),
        data: child.toJson(),
      );

      debugPrint('✅ [ChildService] Response received: ${response.statusCode}');
      debugPrint('📦 [ChildService] Data: ${response.data}');

      // Extraire l'enfant mis à jour
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

      debugPrint('✅ [ChildService] Enfant mis à jour: ${childData['name']}');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      return ChildModel.fromJson(childData);
    } catch (e) {
      debugPrint('❌ [ChildService] Error updating child: $e');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      rethrow;
    }
  }

  /// ✅ Supprimer un enfant
  Future<void> deleteChild(String childId) async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🔴 [ChildService] DELETE CHILD');
      debugPrint('📤 Child ID: $childId');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final response = await _apiClient.delete(
        ApiConstants.childById(childId),
      );

      debugPrint('✅ [ChildService] Response received: ${response.statusCode}');
      debugPrint('✅ [ChildService] Enfant supprimé');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
    } catch (e) {
      debugPrint('❌ [ChildService] Error deleting child: $e');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      rethrow;
    }
  }

  /// ✅ Récupérer un enfant par ID
  Future<ChildModel> getChildById(String childId) async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🔵 [ChildService] GET CHILD BY ID');
      debugPrint('📤 Child ID: $childId');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final response = await _apiClient.get(
        ApiConstants.childById(childId),
      );

      debugPrint('✅ [ChildService] Response received: ${response.statusCode}');
      debugPrint('📦 [ChildService] Data: ${response.data}');

      // Extraire l'enfant
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

      debugPrint('✅ [ChildService] Enfant trouvé: ${childData['name']}');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      return ChildModel.fromJson(childData);
    } catch (e) {
      debugPrint('❌ [ChildService] Error fetching child by ID: $e');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      rethrow;
    }
  }

  /// 🔥 CORRIGÉ : Mettre à jour les horaires d'un enfant (sans doublons)
  Future<void> updateChildSchedule(String childId, Map<String, DaySchedule> schedule) async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🟡 [ChildService] PUT UPDATE SCHEDULE');
      debugPrint('📤 Child ID: $childId');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      // 🔥 Mapping des jours vers format anglais
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

      // 🔥 CORRECTION : Utiliser un Map pour éviter les doublons
      final Map<String, Map<String, dynamic>> uniqueSchedules = {};

      schedule.forEach((day, daySchedule) {
        if (daySchedule.isOpen) {
          final apiDay = dayMapping[day] ?? day.toLowerCase();
          
          // ✅ Seul le DERNIER horaire de chaque jour sera gardé
          uniqueSchedules[apiDay] = {
            'day': apiDay,
            'arrival_time': daySchedule.startTime ?? '08:00',
            'departure_time': daySchedule.endTime ?? '18:00',
          };
        }
      });

      // ✅ Convertir le Map en List (sans doublons)
      final List<Map<String, dynamic>> scheduleList = uniqueSchedules.values.toList();

      final data = {
        'child_id': int.tryParse(childId) ?? 0,
        'schedules': scheduleList,
      };

      debugPrint('📤 Data to send (API format): $data');
      debugPrint('✅ Unique days count: ${uniqueSchedules.length}');

      final response = await _apiClient.put(
        '/api/parents/children/schedules',
        data: data,
      );

      debugPrint('✅ [ChildService] Response: ${response.statusCode}');
      debugPrint('📦 [ChildService] Data: ${response.data}');
      debugPrint('✅ [ChildService] Horaires mis à jour pour l\'enfant $childId');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
    } catch (e) {
      debugPrint('❌ [ChildService] Error updating schedule: $e');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      rethrow;
    }
  }
}