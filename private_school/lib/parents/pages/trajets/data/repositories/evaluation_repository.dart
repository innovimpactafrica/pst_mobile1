import '../services/evaluation_service.dart';
import '../models/evaluation_model.dart';

class EvaluationRepository {
  final EvaluationService _service = EvaluationService();

  Future<EvaluationModel> createEvaluation({
    required int tripId,
    required int rating,
    String? badge,
    String? comment,
  }) async {
    return await _service.createEvaluation(
      tripId: tripId,
      rating: rating,
      badge: badge,
      comment: comment,
    );
  }

  Future<List<EvaluationModel>> getAllEvaluations() async {
    return await _service.getAllEvaluations();
  }

  Future<EvaluationModel> getEvaluationById(int id) async {
    return await _service.getEvaluationById(id);
  }

  Future<EvaluationModel> updateEvaluation({
    required int id,
    int? rating,
    String? badge,
    String? comment,
  }) async {
    return await _service.updateEvaluation(
      id: id,
      rating: rating,
      badge: badge,
      comment: comment,
    );
  }
}