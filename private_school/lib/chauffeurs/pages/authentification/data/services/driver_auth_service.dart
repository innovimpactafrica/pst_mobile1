// Driver authentication service
// Path: lib/chauffeurs/authentification/data/services/driver_auth_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';

import '../../../../../core/network/api_client.dart';
import '../../../../../core/storage/secure_storage.dart';
import '../models/driver_model.dart';

class DriverAuthService {
  final ApiClient _apiClient = ApiClient();
  final SecureStorage _storage = SecureStorage();

  // Let errors from ApiClient propagate directly without wrapping
  Future<Map<String, dynamic>> login({
    required String phone,
    required String password,
  }) async {
    final response = await _apiClient.post(
      '/api/auth/login/driver',
      data: {
        'email': phone, // API expects "email" field
        'password': password,
      },
    );

    final responseData = response.data is Map
        ? response.data
        : {'data': response.data};

    // Handle different API response formats
    final accessToken = responseData['accessToken'] ?? responseData['token'];
    final refreshToken = responseData['refreshToken'];
    final userData =
        responseData['driver'] ?? responseData['user'] ?? responseData['data'];

    // Save tokens
    if (accessToken != null) {
      await _storage.saveAccessToken(accessToken);
    }

    if (refreshToken != null) {
      await _storage.saveRefreshToken(refreshToken);
    }

    // Save user data
    if (userData != null) {
      await _storage.saveUserData(jsonEncode(userData));
    }

    // Create DriverModel from JSON
    final driver = DriverModel.fromJson(userData as Map<String, dynamic>);

    return {'token': accessToken, 'driver': driver};
  }

  Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String phone,
    required String email,
    required String password,
    String? licenseNumber,
    String? vehicleType,
    String? vehicleColor,
    File? licenseFile,
    File? idCardFile,
    File? vehicleFile,
  }) async {
    try {
      final Map<String, dynamic> dataMap = {
        'firstName': firstName,
        'lastName': lastName,
        'phone': phone,
        'email': email,
        'password': password,
        'licenseNumber': licenseNumber,
        'vehicleType': vehicleType,
        'vehicleColor': vehicleColor,
      };

      if (licenseFile != null) {
        dataMap['licensePhoto'] = await MultipartFile.fromFile(
          licenseFile.path,
          filename: 'license.jpg',
        );
      }
      if (idCardFile != null) {
        dataMap['idCardPhoto'] = await MultipartFile.fromFile(
          idCardFile.path,
          filename: 'idcard.jpg',
        );
      }
      if (vehicleFile != null) {
        dataMap['vehiclePhoto'] = await MultipartFile.fromFile(
          vehicleFile.path,
          filename: 'vehicle.jpg',
        );
      }

      final formData = FormData.fromMap(dataMap);
      final response = await _apiClient.post(
        '/api/auth/register-driver',
        data: formData,
      );

      final responseData = response.data is Map
          ? response.data
          : {'data': response.data};
      final accessToken = responseData['accessToken'] ?? responseData['token'];
      final userData =
          responseData['driver'] ??
          responseData['user'] ??
          responseData['data'];

      if (accessToken != null) await _storage.saveAccessToken(accessToken);
      if (userData != null) await _storage.saveUserData(jsonEncode(userData));

      final driver = DriverModel.fromJson(userData as Map<String, dynamic>);
      return {'token': accessToken, 'driver': driver};
    } catch (e) {
      rethrow;
    }
  }

  Future<void> verifyOTP({required String phone, required String otp}) async {
    await _apiClient.post(
      '/api/auth/verify-otp',
      data: {'phone': phone, 'otp': otp},
    );
  }

  Future<void> forgotPassword({required String phone}) async {
    await _apiClient.post('/api/auth/forgot-password', data: {'phone': phone});
  }

  Future<void> resetPassword({
    required String phone,
    required String otp,
    required String newPassword,
  }) async {
    await _apiClient.post(
      '/api/auth/reset-password',
      data: {'phone': phone, 'otp': otp, 'newPassword': newPassword},
    );
  }

  Future<void> logout() async {
    try {
      await _apiClient.post('/api/auth/logout');
    } catch (_) {
      // Continue with local logout even if API call fails
    } finally {
      await _storage.clearAll();
    }
  }
}
