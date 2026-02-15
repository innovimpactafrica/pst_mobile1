import '../services/evaluation_service.dart';
import '../models/evaluation_model.dart';

class EvaluationRepository {
  final EvaluationService _service = EvaluationService();

  Future<EvaluationModel> createEvaluation({
    required int tripId,
    required int driverId,
    required int rating,
    String? comment,
  }) async {
    return await _service.createEvaluation(
      tripId: tripId,
      driverId: driverId,
      rating: rating,
      comment: comment,
    );
  }

  Future<List<EvaluationModel>> getDriverEvaluations({
    required int driverId,
    int? minRating,
    int limit = 20,
    int offset = 0,
  }) async {
    return await _service.getDriverEvaluations(
      driverId: driverId,
      minRating: minRating,
      limit: limit,
      offset: offset,
    );
  }

  Future<EvaluationModel> updateEvaluation({
    required int id,
    int? rating,
    String? comment,
  }) async {
    return await _service.updateEvaluation(
      id: id,
      rating: rating,
      comment: comment,
    );
  }
}