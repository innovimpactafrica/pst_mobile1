import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/utils/api_constants.dart';
import '../models/driver_profile_model.dart';

/// Driver profile service
/// Handles API calls for driver profile operations
class DriverProfileService {
  final ApiClient _apiClient = ApiClient();

  /// Fetch driver profile from API
  /// GET /api/drivers/profile
  /// Returns: { success: true, data: { personal, driver, vehicle } }
  Future<DriverProfileModel> fetchProfile() async {
    try {
      debugPrint('🔍 [DriverProfileService] Fetching driver profile...');

      final response = await _apiClient.get(ApiConstants.driverProfile);

      debugPrint('✅ [DriverProfileService] Profile fetched successfully');
      debugPrint('📦 [DriverProfileService] Response: ${response.data}');

      // Extract data from response
      final responseData = response.data;

      // API returns: { success: true, data: { personal, driver, vehicle } }
      final profileData =
          responseData is Map && responseData.containsKey('data')
              ? responseData['data']
              : responseData;

      return DriverProfileModel.fromJson(profileData as Map<String, dynamic>);
    } catch (e) {
      debugPrint('❌ [DriverProfileService] Error fetching profile: $e');
      throw Exception('Unable to load driver profile: $e');
    }
  }

  /// Update driver profile
  /// PUT /api/drivers/profile
  Future<DriverProfileModel> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? email,
    String? address,
  }) async {
    try {
      debugPrint('📝 [DriverProfileService] Updating driver profile...');

      final response = await _apiClient.put(
        ApiConstants.driverProfile,
        data: {
          if (firstName != null) 'first_name': firstName,
          if (lastName != null) 'last_name': lastName,
          if (phone != null) 'phone': phone,
          if (email != null) 'email': email,
          if (address != null) 'address': address,
        },
      );

      debugPrint('✅ [DriverProfileService] Profile updated successfully');

      final responseData = response.data;
      final profileData =
          responseData is Map && responseData.containsKey('data')
              ? responseData['data']
              : responseData;

      return DriverProfileModel.fromJson(profileData as Map<String, dynamic>);
    } catch (e) {
      debugPrint('❌ [DriverProfileService] Error updating profile: $e');
      throw Exception('Unable to update driver profile: $e');
    }
  }

  /// Update profile photo
  /// PUT /api/drivers/profile/photo (endpoint to be confirmed)
  Future<DriverProfileModel> updateProfilePhoto(File photo) async {
    try {
      debugPrint('📸 [DriverProfileService] Uploading profile photo...');

      // This would need multipart/form-data upload
      // Implementation depends on your API requirements
      throw UnimplementedError('Photo upload not yet implemented');
    } catch (e) {
      debugPrint('❌ [DriverProfileService] Error uploading photo: $e');
      rethrow;
    }
  }

  /// Delete profile photo
  /// DELETE /api/drivers/profile/photo (endpoint to be confirmed)
  Future<void> deleteProfilePhoto() async {
    try {
      debugPrint('🗑️ [DriverProfileService] Deleting profile photo...');

      // Check if endpoint exists in your API
      // await _apiClient.delete(ApiConstants.driverProfilePhoto);

      throw UnimplementedError('Photo delete not yet implemented');
    } catch (e) {
      debugPrint('❌ [DriverProfileService] Error deleting photo: $e');
      rethrow;
    }
  }
}