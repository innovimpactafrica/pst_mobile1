import 'package:flutter/material.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../parents/pages/enfants/data/models/child_model.dart';

/// Service pour récupérer les enfants (pour les chauffeurs)
class ChildService {
  final ApiClient _apiClient = ApiClient();

  /// Récupérer tous les enfants d'une école spécifique
  /// Utilisé pour peupler automatiquement les passagers d'un trajet
  Future<List<ChildModel>> getChildrenBySchool(int schoolId) async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🔵 [ChildService] GET CHILDREN BY SCHOOL');
      debugPrint('📤 School ID: $schoolId');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

  
      final response = await _apiClient.get('/api/parents/children');

      debugPrint('✅ [ChildService] Response: ${response.statusCode}');

      final List<dynamic> childrenJson;

      if (response.data is Map<String, dynamic>) {
        childrenJson = response.data['children'] ?? 
                      response.data['data'] ?? 
                      [];
      } else if (response.data is List) {
        childrenJson = response.data;
      } else {
        throw Exception('Format de réponse invalide');
      }

      // Parser tous les enfants
      final allChildren = childrenJson
          .map((json) => ChildModel.fromJson(json))
          .toList();

      // Filtrer par school_id
      final childrenInSchool = allChildren
          .where((child) => child.schoolId == schoolId)
          .toList();

      debugPrint('✅ [ChildService] ${allChildren.length} enfant(s) total');
      debugPrint('✅ [ChildService] ${childrenInSchool.length} enfant(s) dans l\'école $schoolId');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      return childrenInSchool;
    } catch (e) {
      debugPrint('❌ [ChildService] Error fetching children: $e');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      rethrow;
    }
  }

  /// Récupérer tous les enfants (toutes écoles confondues)
  Future<List<ChildModel>> getAllChildren() async {
    try {
      debugPrint('🔵 [ChildService] GET ALL CHILDREN');

      final response = await _apiClient.get('/api/parents/children');

      final List<dynamic> childrenJson;

      if (response.data is Map<String, dynamic>) {
        childrenJson = response.data['children'] ?? 
                      response.data['data'] ?? 
                      [];
      } else if (response.data is List) {
        childrenJson = response.data;
      } else {
        throw Exception('Format de réponse invalide');
      }

      final children = childrenJson
          .map((json) => ChildModel.fromJson(json))
          .toList();

      debugPrint('✅ [ChildService] ${children.length} enfant(s) trouvé(s)\n');

      return children;
    } catch (e) {
      debugPrint('❌ [ChildService] Error: $e\n');
      rethrow;
    }
  }
}