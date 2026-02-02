import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/utils/api_constants.dart';
import '../models/report_model.dart';

class ReportService {
  final ApiClient _apiClient = ApiClient();

  /// Fetch all reports/incidents for the current driver
  Future<List<ReportModel>> fetchReports() async {
    try {
      final response = await _apiClient.get(ApiConstants.incidents);
      
      if (response.data != null && response.data['incidents'] != null) {
        final List<dynamic> incidentsList = response.data['incidents'];
        return incidentsList.map((json) => ReportModel.fromJson(json)).toList();
      }
      
      throw Exception('Format de réponse inconnu (clé "incidents" manquante)');
    } catch (e) {
      debugPrint('❌ Erreur Service fetchReports: $e');
      throw Exception('Erreur lors de la récupération des rapports: $e');
    }
  }

  /// Create a new report/incident with file uploads
  /// The files are uploaded directly to the backend as multipart/form-data
  Future<ReportModel> createReport({
    required String type,
    required String description,
    required String category,
    List<File>? files,
  }) async {
    try {
      // Prepare FormData for multipart upload
      FormData formData = FormData.fromMap({
        'type_de_problem': type,
        'category': category,
        'description': description,
      });

      // Add files if provided
      if (files != null && files.isNotEmpty) {
        for (int i = 0; i < files.length; i++) {
          String fileName = files[i].path.split('/').last;
          formData.files.add(
            MapEntry(
              'documents[$i]', // Backend expects documents[] array
              await MultipartFile.fromFile(
                files[i].path,
                filename: fileName,
              ),
            ),
          );
        }
      }

      debugPrint('📤 Envoi du signalement vers: ${ApiConstants.incidents}');
      debugPrint('📝 Type: $type');
      debugPrint('📝 Description: $description');
      debugPrint('📎 Nombre de fichiers: ${files?.length ?? 0}');

      final response = await _apiClient.post(
        ApiConstants.incidents,
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      debugPrint('✅ Réponse API: ${response.data}');

      if (response.data != null) {
        // Handle different response structures from backend
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
      debugPrint('❌ Erreur création signalement: $e');
      throw Exception('Erreur lors de la création du signalement: $e');
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
      debugPrint('❌ Erreur mise à jour statut: $e');
      throw Exception('Error updating report: $e');
    }
  }


  // Pour la modification (Update)
Future<ReportModel> updateReport({
  required int id,
  required String type,
  required String description,
}) async {
  try {
    final response = await _apiClient.put(
      '${ApiConstants.incidents}/$id',
      data: {
        'type_de_problem': type,
        'description': description,
      },
    );
    return ReportModel.fromJson(response.data);
  } catch (e) {
    throw Exception('Erreur lors de la modification: $e');
  }
}


Future<void> deleteReport(int id, int userId) async {
  try {
    await _apiClient.delete(
      '${ApiConstants.incidents}/$id',
      data: {
        'user_id': userId,
      },
    );
  } catch (e) {
    throw Exception('Erreur suppression: $e');
  }
}

}