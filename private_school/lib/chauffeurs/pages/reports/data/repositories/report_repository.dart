import 'dart:io';
import '../models/report_model.dart';
import '../services/report_service.dart';

class ReportRepository {
  final ReportService _service = ReportService();

  /// Get all reports
  Future<List<ReportModel>> getReports() async {
    return await _service.fetchReports();
  }

  /// Create a new report
  Future<ReportModel> createReport({
    required String type,
    required String category,
    required String description,
    List<File>? files,
  }) async {
    return await _service.createReport(
      type: type,
      category: category,
      description: description,
      files: files,
    );
  }

  /// Update a report - MÉTHODE CORRIGÉE AVEC FICHIERS ✅
  Future<ReportModel> updateReport({
    required int id,
    required String type,
    required String category,
    required String description,
    List<File>? files,
  }) async {
    return await _service.updateReport(
      id: id,
      type: type,
      category: category,
      description: description,
      files: files,
    );
  }

  /// Update report status
  Future<ReportModel> updateReportStatus({
    required int id,
    required String status,
  }) async {
    return await _service.updateReportStatus(
      id: id,
      status: status,
    );
  }

  /// Delete a report - MÉTHODE CORRIGÉE ✅
  Future<void> deleteReport(int id, int userId) async {
    return await _service.deleteReport(id, userId);
  }
}