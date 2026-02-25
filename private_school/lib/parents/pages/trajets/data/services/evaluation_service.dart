import 'package:flutter/material.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/utils/api_constants.dart';
import '../models/evaluation_model.dart';

class EvaluationService {
  final ApiClient _apiClient = ApiClient();

  /// Créer une nouvelle évaluation
  Future<EvaluationModel> createEvaluation({
    required int tripId,
    required int driverId,
    required int rating,
    String? comment,
  }) async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint(' [EvaluationService] CREATE EVALUATION');
      debugPrint(' Trip ID: $tripId');
      debugPrint(' Driver ID: $driverId');
      debugPrint(' Rating: $rating');
      debugPrint(' Comment: $comment');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final requestBody = {
        'trip_id': tripId,
        'driver_id': driverId,
        'rating': rating,
        if (comment != null && comment.isNotEmpty) 'comment': comment,
      };

      final response = await _apiClient.post(
        ApiConstants.evaluations,
        data: requestBody,
      );

      debugPrint(' Response Status: ${response.statusCode}');

      final evaluationData =
          response.data['evaluation'] ?? response.data['data'] ?? response.data;

      final evaluation = EvaluationModel.fromJson(evaluationData);

      debugPrint(' Évaluation créée avec succès');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      return evaluation;
    } catch (e) {
      debugPrint(' [EvaluationService] ERREUR: $e\n');
      rethrow;
    }
  }

  /// Récupérer les évaluations d'un chauffeur

  Future<List<EvaluationModel>> getDriverEvaluations({
    required int driverId,
    int? minRating,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      debugPrint(' [EvaluationService] GET DRIVER EVALUATIONS: $driverId');

      final response = await _apiClient.get(
        ApiConstants.evaluations,
        queryParameters: {
          'driver_id': driverId,
          if (minRating != null) 'min_rating': minRating,
          'limit': limit,
          'offset': offset,
        },
      );

      List<dynamic> evaluationsJson = [];

      if (response.data['data'] != null && response.data['data'] is List) {
        evaluationsJson = response.data['data'] as List<dynamic>;
      } else if (response.data['evaluations'] != null &&
          response.data['evaluations'] is List) {
        evaluationsJson = response.data['evaluations'] as List<dynamic>;
      }

      debugPrint(
        ' [EvaluationService] ${evaluationsJson.length} évaluation(s) trouvée(s) dans la réponse',
      );

      final evaluations = evaluationsJson
          .map((json) => EvaluationModel.fromJson(json))
          .toList();

      debugPrint('${evaluations.length} évaluation(s) récupérée(s)\n');

      return evaluations;
    } catch (e) {
      debugPrint(' Error: $e\n');
      rethrow;
    }
  }

  /// Modifier une évaluation
  Future<EvaluationModel> updateEvaluation({
    required int id,
    int? rating,
    String? comment,
  }) async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint(' [EvaluationService] UPDATE EVALUATION');
      debugPrint(' ID: $id');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final requestBody = <String, dynamic>{};
      if (rating != null) requestBody['rating'] = rating;
      if (comment != null) requestBody['comment'] = comment;

      final response = await _apiClient.put(
        ApiConstants.evaluationById(id.toString()),
        data: requestBody,
      );

      final evaluationData =
          response.data['evaluation'] ?? response.data['data'] ?? response.data;

      debugPrint(' Évaluation mise à jour');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      return EvaluationModel.fromJson(evaluationData);
    } catch (e) {
      debugPrint(' Error: $e\n');
      rethrow;
    }
  }
}
