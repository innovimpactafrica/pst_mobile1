import 'package:flutter/material.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../parents/pages/enfants/data/models/child_model.dart';

/// Service pour récupérer les enfants (pour les chauffeurs)
/// ✅ OPTIMISÉ: Utilise l'endpoint dédié /api/schools/{schoolId}/children
class ChildService {
  final ApiClient _apiClient = ApiClient();

  /// ✅ NOUVEAU: Récupérer tous les enfants d'une école spécifique
  /// Endpoint optimisé: GET /api/schools/{schoolId}/children
  Future<List<ChildModel>> getChildrenBySchool(int schoolId) async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🔵 [ChildService] GET CHILDREN BY SCHOOL');
      debugPrint('📤 School ID: $schoolId');
      debugPrint('📍 Endpoint: /api/schools/$schoolId/children');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      // ✅ Appel direct à l'endpoint optimisé
      final response = await _apiClient.get('/api/schools/$schoolId/children');

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

      // Parser les enfants
      final children = childrenJson
          .map((json) => ChildModel.fromJson(json))
          .toList();

      debugPrint('✅ [ChildService] ${children.length} enfant(s) dans l\'école $schoolId');
      
      if (children.isNotEmpty) {
        debugPrint('📋 Liste des enfants:');
        for (var child in children) {
          debugPrint('   - ${child.name} (${child.address})');
        }
      } else {
        debugPrint('⚠️ Aucun enfant trouvé dans cette école');
      }
      
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      return children;
    } catch (e) {
      debugPrint('❌ [ChildService] Error fetching children: $e');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      rethrow;
    }
  }

  /// Récupérer tous les enfants (toutes écoles confondues)
  /// Endpoint: GET /api/parents/children
  /// Note: Utilisez getChildrenBySchool() pour de meilleures performances
  Future<List<ChildModel>> getAllChildren() async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🔵 [ChildService] GET ALL CHILDREN');
      debugPrint('⚠️ Attention: Récupération de TOUS les enfants (non optimisé)');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

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

      debugPrint('✅ [ChildService] ${children.length} enfant(s) total');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      return children;
    } catch (e) {
      debugPrint('❌ [ChildService] Error: $e');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      rethrow;
    }
  }
}