import 'package:flutter/material.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/utils/api_constants.dart';
import '../../../../../parents/pages/enfants/data/models/child_model.dart';

class ChildService {
  final ApiClient _apiClient = ApiClient();
  
  Future<List<ChildModel>> getChildrenBySchool(int schoolId) async {
    try {
      final response = await _apiClient.get(ApiConstants.childrenBySchool(schoolId));
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
      
      if (children.isNotEmpty) {
        for (var child in children) {
          debugPrint('Enfant: ${child.firstName} ${child.lastName}');
        }
      }

      return children;
    } catch (e) {
      debugPrint('❌ [ChildService] Error: $e');
      rethrow;
    }
  }

  Future<List<ChildModel>> getAllChildren() async {
    try {
      final response = await _apiClient.get(ApiConstants.children);

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

      return children;
    } catch (e) {
      debugPrint('❌ [ChildService] Error: $e');
      rethrow;
    }
  }
}
