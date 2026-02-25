import 'package:dio/dio.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/utils/api_constants.dart';
import '../models/driver_profile_model.dart';

class DriverProfileService {
  final ApiClient _apiClient = ApiClient();
  Future<DriverProfileModel> fetchProfile() async {
    return await getProfile();
  }

  Future<DriverProfileModel> getProfile() async {
    try {
      final response = await _apiClient.get(ApiConstants.driverProfile);

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
      throw Exception(_handleError(e));
    } catch (e) {
      throw Exception('Failed to load profile: $e');
    }
  }

  Future<DriverProfileModel> updateProfileWithPhoto(FormData formData) async {
    try {
      final response = await _apiClient.put(
        ApiConstants.driverProfile,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      if (response.data['success'] == true) {
        return await getProfile();
      } else {
        throw Exception(
          response.data['message'] ?? 'Erreur lors de la mise à jour',
        );
      }
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  Future<DriverProfileModel> updateDriverById({
    required String driverId,
    required FormData formData,
  }) async {
    try {
      final response = await _apiClient.put(
        ApiConstants.updateDriverById(driverId),
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      if (response.data != null && response.data['id'] != null) {
        return await getProfile();
      } else {
        throw Exception('Réponse invalide du serveur');
      }
    } on DioException catch (e) {
      if (e.response != null) {}
      throw Exception(_handleError(e));
    } catch (e) {
      throw Exception('Failed to update driver: $e');
    }
  }

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
