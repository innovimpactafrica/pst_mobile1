

import 'dart:io';
import '../models/report_model.dart';
import '../services/report_service.dart';

class ReportRepository {
  final ReportService _service = ReportService();

  Future<List<ReportModel>> getReports() async {
    try {
      return await _service.fetchReports();
    } catch (e) {
      throw Exception('Failed to load reports: $e');
    }
  }

  Future<ReportModel> createReport({
    required String type,
    required String category,
    required String description,
    List<File>? files,
  }) async {
    try {
      return await _service.createReport(
        type: type,
        category: category,
        description: description,
        files: files,
      );
    } catch (e) {
      throw Exception('Failed to create report: $e');
    }
  }

  Future<ReportModel> updateReport({
    required int id,
    required String type,
    required String description,
  }) async {
    try {
      return await _service.updateReport(
        id: id,
        type: type,
        description: description,
      );
    } catch (e) {
      throw Exception('Failed to update report: $e');
    }
  }

  Future<ReportModel> updateReportStatus({
    required int id,
    required String status,
  }) async {
    try {
      return await _service.updateReportStatus(id: id, status: status);
    } catch (e) {
      throw Exception('Failed to update report: $e');
    }
  }

  Future<void> deleteReport(int id, int userId) async {
    try {
      await _service.deleteReport(id, userId);
    } catch (e) {
      throw Exception('Failed to delete report: $e');
    }
  }
}