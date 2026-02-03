

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/utils/api_constants.dart';
import '../models/driver_profile_model.dart';

/// Service for driver profile API calls
class DriverProfileService {
  final ApiClient _apiClient = ApiClient();

  /// Fetch driver profile from API (alias for getProfile)
  Future<DriverProfileModel> fetchProfile() async {
    return await getProfile();
  }

  /// Get driver profile from API
  Future<DriverProfileModel> getProfile() async {
    try {
      debugPrint('🔍 [DriverProfileService] Fetching driver profile...');
      final response = await _apiClient.get(ApiConstants.driverProfile);
      debugPrint('✅ [DriverProfileService] Profile fetched successfully');
      debugPrint('📦 [DriverProfileService] Response: ${response.data}');

      if (response.data['success'] == true && response.data['data'] != null) {
        final data = response.data['data'];
        if (data is Map<String, dynamic>) {
          return DriverProfileModel.fromJson(data);
        } else {
          throw Exception('Invalid data format: expected Map<String, dynamic>');
        }
      } else {
        throw Exception('Invalid response format: ${response.data}');
      }
    } on DioException catch (e) {
      debugPrint('❌ [DriverProfileService] DioException: ${e.message}');
      throw Exception(_handleError(e));
    } catch (e) {
      debugPrint('❌ [DriverProfileService] Error: $e');
      throw Exception('Failed to load profile: $e');
    }
  }

  
  Future<DriverProfileModel> updateProfileWithPhoto(FormData formData) async {
    try {
      debugPrint(
        '📝 [DriverProfileService] Updating driver profile with photo...',
      );
      debugPrint('📦 [DriverProfileService] FormData fields: ${formData.fields}');
      
      final response = await _apiClient.put(
        ApiConstants.driverProfile,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      
      debugPrint('✅ [DriverProfileService] Profile updated successfully');
      debugPrint('📦 [DriverProfileService] Response: ${response.data}');

      if (response.data['success'] == true) {
        debugPrint('🔄 [DriverProfileService] Reloading complete profile...');
        return await getProfile();
      } else {
        throw Exception(
          response.data['message'] ?? 'Erreur lors de la mise à jour',
        );
      }
    } on DioException catch (e) {
      debugPrint(
        '❌ [DriverProfileService] Error updating profile: ${e.message}',
      );
      throw Exception(_handleError(e));
    } catch (e) {
      debugPrint('❌ [DriverProfileService] Error: $e');
      throw Exception('Failed to update profile: $e');
    }
  }


Future<DriverProfileModel> updateDriverById({
  required String driverId,
  required FormData formData,
}) async {
  try {
    debugPrint(
      '🔧 [DriverProfileService] Updating driver via ADMIN endpoint...',
    );
    debugPrint('👤 [DriverProfileService] Driver ID: $driverId');
    debugPrint('📦 [DriverProfileService] FormData fields: ${formData.fields}');
    debugPrint('📎 [DriverProfileService] FormData files: ${formData.files.length} file(s)');
    
    final response = await _apiClient.put(
      ApiConstants.updateDriverById(driverId),
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
    
    debugPrint('✅ [DriverProfileService] Driver updated successfully');
    debugPrint('📦 [DriverProfileService] Response: ${response.data}');

    // 🔧 CORRECTION: Le backend retourne directement l'objet, pas {success: true, data: {...}}
    // On vérifie juste que la réponse contient un ID
    if (response.data != null && response.data['id'] != null) {
      debugPrint('🔄 [DriverProfileService] Reloading complete profile...');
      return await getProfile();
    } else {
      throw Exception('Réponse invalide du serveur');
    }
  } on DioException catch (e) {
    debugPrint(
      '❌ [DriverProfileService] Error updating driver: ${e.message}',
    );
    if (e.response != null) {
      debugPrint('📦 [DriverProfileService] Error response: ${e.response!.data}');
    }
    throw Exception(_handleError(e));
  } catch (e) {
    debugPrint('❌ [DriverProfileService] Error: $e');
    throw Exception('Failed to update driver: $e');
  }
}

  /// Update driver profile (without file upload)
  Future<DriverProfileModel> updateProfile({
    required String firstName,
    required String lastName,
    required String phone,
    required String address,
  }) async {
    try {
      final formData = FormData.fromMap({
        'first_name': firstName,
        'last_name': lastName,
        'phone': phone,
        'address': address,
      });

      final response = await _apiClient.put(
        ApiConstants.driverProfile,
        data: formData,
      );

      if (response.data['success'] == true) {
        debugPrint('✅ Mise à jour réussie, rechargement du profil complet...');
        return await getProfile();
      } else {
        throw Exception(response.data['message'] ?? 'Erreur de mise à jour');
      }
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  String _handleError(DioException e) {
    if (e.response != null) {
      final data = e.response!.data;
      if (data is Map<String, dynamic>) {
        return data['message'] ?? data['error'] ?? 'Une erreur est survenue';
      }
      return 'Erreur serveur: ${e.response!.statusMessage}';
    }
    return 'Erreur de connexion';
  }
}