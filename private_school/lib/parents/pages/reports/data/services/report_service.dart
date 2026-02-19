import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/utils/api_constants.dart';
import '../models/report_model.dart';

class ReportService {
  final ApiClient _apiClient = ApiClient();

  /// Fetch all reports/incidents with pagination
  Future<Map<String, dynamic>> fetchReports({
    int page = 1,
    int limit = 5,
    String? type,
  }) async {
    try {
      debugPrint('═══════════════════════════════════════════════════════');
      debugPrint('📥 [FETCH] Récupération des signalements');
      debugPrint('═══════════════════════════════════════════════════════');
      
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (type != null && type != 'Tous') 'type': type,
      };
      
      final response = await _apiClient.get(
        ApiConstants.incidents,
        queryParameters: queryParams,
      );
      
      if (response.data != null && response.data['incidents'] != null) {
        final List<dynamic> incidentsList = response.data['incidents'];
        final reports = incidentsList.map((json) => ReportModel.fromJson(json)).toList();
        
        final total = response.data['total'] ?? reports.length;
        final currentPage = response.data['page'] ?? page;
        final totalPages = response.data['totalPages'] ?? ((total / limit).ceil());
        
        debugPrint('✅ [FETCH] ${reports.length} signalements récupérés (page $currentPage/$totalPages)');
        
        return {
          'incidents': reports,
          'total': total,
          'page': currentPage,
          'totalPages': totalPages,
          'hasMore': currentPage < totalPages,
        };
      }
      
      throw Exception('Format de réponse inconnu (clé "incidents" manquante)');
    } catch (e) {
      debugPrint('❌ [FETCH] Erreur: $e');
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
      debugPrint('═══════════════════════════════════════════════════════');
      debugPrint('📤 [CREATE] Création d\'un signalement');
      debugPrint('📝 Type: $type');
      debugPrint('📝 Catégorie: $category');
      debugPrint('📝 Description: $description');
      debugPrint('📎 Fichiers: ${files?.length ?? 0}');
      debugPrint('═══════════════════════════════════════════════════════');
      
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
              await MultipartFile.fromFile(
                files[i].path,
                filename: fileName,
              ),
            ),
          );
        }
      }

      final response = await _apiClient.post(
        ApiConstants.incidents,
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      debugPrint('✅ [CREATE] Signalement créé avec succès');

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
      debugPrint('❌ [CREATE] Erreur: $e');
      throw Exception('Erreur lors de la création du signalement: $e');
    }
  }

  /// Update report - MÉTHODE CORRIGÉE AVEC MULTIPART ✅
  Future<ReportModel> updateReport({
    required int id,
    required String type,
    required String category,
    required String description,
    List<File>? files,
  }) async {
    try {
      debugPrint('═══════════════════════════════════════════════════════');
      debugPrint('📝 [UPDATE] Modification du signalement #$id');
      debugPrint('📝 Type: $type');
      debugPrint('📝 Catégorie: $category');
      debugPrint('📝 Description: $description');
      debugPrint('📎 Nouveaux fichiers: ${files?.length ?? 0}');
      debugPrint('═══════════════════════════════════════════════════════');

      // Préparer FormData pour multipart upload
      FormData formData = FormData.fromMap({
        'type_de_problem': type,
        'category': category,
        'description': description,
      });

      // ✅ Si des fichiers sont fournis, indiquer au backend de remplacer
      if (files != null && files.isNotEmpty) {
        // Ajouter un flag pour indiquer qu'on veut REMPLACER les documents
        formData.fields.add(const MapEntry('replace_documents', 'true'));
        
        for (int i = 0; i < files.length; i++) {
          String fileName = files[i].path.split('/').last;
          formData.files.add(
            MapEntry(
              'documents[$i]',
              await MultipartFile.fromFile(
                files[i].path,
                filename: fileName,
              ),
            ),
          );
        }
        debugPrint('📎 ${files.length} fichier(s) ajouté(s) - Mode REMPLACEMENT');
      }

      final response = await _apiClient.put(
        '${ApiConstants.incidents}/$id',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      debugPrint('✅ [UPDATE] Modification réussie');

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
      debugPrint('❌ [UPDATE] Erreur: $e');
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
      debugPrint('❌ Erreur mise à jour statut: $e');
      throw Exception('Error updating report: $e');
    }
  }

  /// Delete report - MÉTHODE CORRIGÉE AVEC LOGS DÉTAILLÉS ✅
  Future<void> deleteReport(int id, int userId) async {
    try {
      debugPrint('═══════════════════════════════════════════════════════');
      debugPrint('🗑️ [DELETE] Début de la suppression');
      debugPrint('📝 ID du signalement: $id');
      debugPrint('👤 ID de l\'utilisateur: $userId');
      debugPrint('🌐 URL: ${ApiConstants.incidents}/$id');
      debugPrint('📦 Data envoyée: {user_id: $userId}');
      debugPrint('═══════════════════════════════════════════════════════');

      final response = await _apiClient.delete(
        '${ApiConstants.incidents}/$id',
        data: {
          'user_id': userId,
        },
      );

      debugPrint('═══════════════════════════════════════════════════════');
      debugPrint('✅ [DELETE] Suppression réussie!');
      debugPrint('📊 Status Code: ${response.statusCode}');
      debugPrint('📦 Response Data: ${response.data}');
      debugPrint('═══════════════════════════════════════════════════════');
    } catch (e) {
      debugPrint('═══════════════════════════════════════════════════════');
      debugPrint('❌ [DELETE] ERREUR lors de la suppression');
      debugPrint('🔥 Erreur: $e');
      
      if (e is DioException) {
        debugPrint('📊 Status Code: ${e.response?.statusCode}');
        debugPrint('📦 Response Data: ${e.response?.data}');
      }
      
      debugPrint('═══════════════════════════════════════════════════════');
      
      // Gestion des erreurs spécifiques
      if (e is DioException) {
        if (e.response?.statusCode == 400) {
          final errorMessage = e.response?.data['error'] ?? 'Requête invalide';
          throw Exception('Requête invalide: $errorMessage');
        } else if (e.response?.statusCode == 404) {
          throw Exception('Signalement non trouvé');
        } else if (e.response?.statusCode == 403) {
          throw Exception('Vous n\'êtes pas autorisé à supprimer ce signalement');
        }
      }
      
      throw Exception('Erreur suppression: $e');
    }
  }
}