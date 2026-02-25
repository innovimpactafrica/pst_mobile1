import 'package:flutter/material.dart';
import '../../../../../core/network/api_client.dart';

class DriverInfoService {
  final ApiClient _apiClient = ApiClient();

  /// Récupère les informations d'un chauffeur par son ID

  Future<Map<String, dynamic>?> getDriverInfo(String driverId) async {
    try {
      debugPrint(' [DriverInfoService] Fetching driver info for ID: $driverId');

      final response = await _apiClient.get('/api/drivers/$driverId/public');

      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true && data['data'] != null) {
          debugPrint(' [DriverInfoService] Driver info fetched successfully');
          return data['data'] as Map<String, dynamic>;
        }
      }

      return null;
    } catch (e) {
      debugPrint(' [DriverInfoService] Error fetching driver info: $e');
      return null;
    }
  }
}
