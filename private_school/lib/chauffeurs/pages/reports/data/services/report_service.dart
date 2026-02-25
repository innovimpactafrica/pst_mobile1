import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/utils/api_constants.dart';
import '../models/report_model.dart';

class ReportService {
  final ApiClient _apiClient = ApiClient();

  /// Fetch reports with pagination
  Future<Map<String, dynamic>> fetchReports({
    int page = 1,
    int limit = 10,
    String? type,
  }) async {
    try {
      final queryParams = {
        'page': page,
        'limit': limit,
        if (type != null && type != 'Tous') 'type': type,
      };

      final response = await _apiClient.get(
        ApiConstants.incidents,
        queryParameters: queryParams,
      );

      if (response.data != null) {
        final List<dynamic> incidentsList = response.data['incidents'] ?? [];
        final int total = response.data['total'] ?? incidentsList.length;
        final int currentPage = response.data['page'] ?? page;
        final int totalPages = response.data['totalPages'] ?? 1;

        return {
          'incidents': incidentsList
              .map((json) => ReportModel.fromJson(json))
              .toList(),
          'total': total,
          'page': currentPage,
          'totalPages': totalPages,
          'hasMore': currentPage < totalPages,
        };
      }

      throw Exception('Format de réponse inconnu');
    } catch (e) {
      throw Exception('Erreur lors de la récupération des rapports: $e');
    }
  }

  /// Create a new report/incident with file uploads
  Future<ReportModel> createReport({
    required String type,
    required String description,
    required String category,
    List<File>? files,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        'type_de_problem': type,
        'category': category,
        'description': description,
      });

      if (files != null && files.isNotEmpty) {
        for (int i = 0; i < files.length; i++) {
          String fileName = files[i].path.split('/').last;
          formData.files.add(
            MapEntry(
              'documents[$i]',
              await MultipartFile.fromFile(files[i].path, filename: fileName),
            ),
          );
        }
      }

      final response = await _apiClient.post(
        ApiConstants.incidents,
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      if (response.data != null) {
        if (response.data['success'] == true && response.data['data'] != null) {
          return ReportModel.fromJson(response.data['data']);
        } else if (response.data['incident'] != null) {
          return ReportModel.fromJson(response.data['incident']);
        } else {
          return ReportModel.fromJson(response.data);
        }
      }

      throw Exception('Réponse invalide du serveur');
    } catch (e) {
      throw Exception('Erreur lors de la création du signalement: $e');
    }
  }

  /// Update report
  Future<ReportModel> updateReport({
    required int id,
    required String type,
    required String category,
    required String description,
    List<File>? files,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        'type_de_problem': type,
        'category': category,
        'description': description,
      });

      if (files != null && files.isNotEmpty) {
        formData.fields.add(const MapEntry('replace_documents', 'true'));

        for (int i = 0; i < files.length; i++) {
          String fileName = files[i].path.split('/').last;
          formData.files.add(
            MapEntry(
              'documents[$i]',
              await MultipartFile.fromFile(files[i].path, filename: fileName),
            ),
          );
        }
      }

      final response = await _apiClient.put(
        '${ApiConstants.incidents}/$id',
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      if (response.data != null) {
        if (response.data['success'] == true && response.data['data'] != null) {
          return ReportModel.fromJson(response.data['data']);
        } else if (response.data['incident'] != null) {
          return ReportModel.fromJson(response.data['incident']);
        } else {
          return ReportModel.fromJson(response.data);
        }
      }

      throw Exception('Réponse invalide du serveur');
    } catch (e) {
      throw Exception('Erreur lors de la modification: $e');
    }
  }

  /// Update report status
  Future<ReportModel> updateReportStatus({
    required int id,
    required String status,
  }) async {
    try {
      final response = await _apiClient.patch(
        '${ApiConstants.incidents}/$id',
        data: {'status': status},
      );

      if (response.data['success'] == true) {
        return ReportModel.fromJson(response.data['data']);
      }

      throw Exception('Failed to update report');
    } catch (e) {
      throw Exception('Error updating report: $e');
    }
  }

  /// Delete report
  Future<void> deleteReport(int id, int userId) async {
    try {
      await _apiClient.delete(
        '${ApiConstants.incidents}/$id',
        data: {'user_id': userId},
      );
    } catch (e) {
      if (e is DioException) {}

      if (e is DioException) {
        if (e.response?.statusCode == 400) {
          final errorMessage = e.response?.data['error'] ?? 'Requête invalide';
          throw Exception('Requête invalide: $errorMessage');
        } else if (e.response?.statusCode == 404) {
          throw Exception('Signalement non trouvé');
        } else if (e.response?.statusCode == 403) {
          throw Exception(
            'Vous n\'êtes pas autorisé à supprimer ce signalement',
          );
        }
      }

      throw Exception('Erreur suppression: $e');
    }
  }
}
