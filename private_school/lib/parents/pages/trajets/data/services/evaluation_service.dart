import 'package:flutter/material.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/utils/api_constants.dart';
import '../models/evaluation_model.dart';

class EvaluationService {
  final ApiClient _apiClient = ApiClient();

  /// Créer une nouvelle évaluation
  /// POST /api/evaluations
  Future<EvaluationModel> createEvaluation({
    required int tripId,
    required int rating,
    String? badge,
    String? comment,
  }) async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🟢 [EvaluationService] CREATE EVALUATION');
      debugPrint('📤 Trip ID: $tripId');
      debugPrint('📤 Rating: $rating');
      debugPrint('📤 Badge: $badge');
      debugPrint('📤 Comment: $comment');
      debugPrint('📍 Endpoint: ${ApiConstants.evaluations}');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final requestBody = {
        'trip_id': tripId,
        'rating': rating,
        if (badge != null && badge.isNotEmpty) 'badge': badge,
        if (comment != null && comment.isNotEmpty) 'comment': comment,
      };

      debugPrint('📦 Request Body:');
      debugPrint('   $requestBody');

      final response = await _apiClient.post(
        ApiConstants.evaluations,
        data: requestBody,
      );

      debugPrint('✅ Response Status: ${response.statusCode}');
      debugPrint('📦 Response Data: ${response.data}');

      // Parser la réponse
      final evaluationData = response.data['evaluation'] ?? 
                            response.data['data'] ?? 
                            response.data;

      final evaluation = EvaluationModel.fromJson(evaluationData);

      debugPrint('✅ Évaluation créée avec succès');
      debugPrint('   ID: ${evaluation.id}');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      return evaluation;
    } catch (e, stackTrace) {
      debugPrint('');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('❌ [EvaluationService] ERREUR CRÉATION');
      debugPrint('Error: $e');
      debugPrint('Stack: $stackTrace');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      rethrow;
    }
  }

  /// Récupérer toutes les évaluations
  /// GET /api/evaluations
  Future<List<EvaluationModel>> getAllEvaluations() async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🔵 [EvaluationService] GET ALL EVALUATIONS');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final response = await _apiClient.get(ApiConstants.evaluations);

      debugPrint('✅ Response Status: ${response.statusCode}');

      final List<dynamic> evaluationsJson;

      if (response.data is Map<String, dynamic>) {
        evaluationsJson = response.data['evaluations'] ?? 
                         response.data['data'] ?? 
                         [];
      } else if (response.data is List) {
        evaluationsJson = response.data;
      } else {
        throw Exception('Format de réponse invalide');
      }

      final evaluations = evaluationsJson
          .map((json) => EvaluationModel.fromJson(json))
          .toList();

      debugPrint('✅ ${evaluations.length} évaluation(s) récupérée(s)');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      return evaluations;
    } catch (e) {
      debugPrint('❌ Error loading evaluations: $e\n');
      rethrow;
    }
  }

  /// Récupérer une évaluation par ID
  /// GET /api/evaluations/{id}
  Future<EvaluationModel> getEvaluationById(int id) async {
    try {
      debugPrint('🔍 [EvaluationService] GET EVALUATION BY ID: $id');

      final response = await _apiClient.get(
        ApiConstants.evaluationById(id.toString()),
      );

      final evaluationData = response.data['evaluation'] ?? 
                            response.data['data'] ?? 
                            response.data;

      return EvaluationModel.fromJson(evaluationData);
    } catch (e) {
      debugPrint('❌ Error loading evaluation: $e\n');
      rethrow;
    }
  }

  /// Modifier une évaluation
  /// PUT /api/evaluations/{id}
  Future<EvaluationModel> updateEvaluation({
    required int id,
    int? rating,
    String? badge,
    String? comment,
  }) async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🟡 [EvaluationService] UPDATE EVALUATION');
      debugPrint('📤 ID: $id');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final requestBody = <String, dynamic>{};
      if (rating != null) requestBody['rating'] = rating;
      if (badge != null) requestBody['badge'] = badge;
      if (comment != null) requestBody['comment'] = comment;

      final response = await _apiClient.put(
        ApiConstants.evaluationById(id.toString()),
        data: requestBody,
      );

      final evaluationData = response.data['evaluation'] ?? 
                            response.data['data'] ?? 
                            response.data;

      debugPrint('✅ Évaluation mise à jour');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      return EvaluationModel.fromJson(evaluationData);
    } catch (e) {
      debugPrint('❌ Error updating evaluation: $e\n');
      rethrow;
    }
  }
}