

import 'dart:io';
import '../../../../../core/storage/secure_storage.dart';
import '../models/driver_model.dart';
import '../services/driver_auth_service.dart';

class DriverAuthRepository {
  final DriverAuthService _authService = DriverAuthService();
  final SecureStorage _storage = SecureStorage();

 
  Future<DriverModel> login({
    required String phone,
    required String password,
  }) async {
    final result = await _authService.login(
      phone: phone,
      password: password,
    );
    return result['driver'] as DriverModel;
  }

  Future<DriverModel> register({
    required String firstName,
    required String lastName,
    required String phone,
    required String email,
    required String password,
    String? licenseNumber,
    String? vehicleType,
    String? vehicleColor,
    int? capacity,
    File? licenseFile,
    File? idCardFile,
    File? vehicleFile,
  }) async {
    final result = await _authService.register(
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      email: email,
      password: password,
      licenseNumber: licenseNumber,
      vehicleType: vehicleType,
      vehicleColor: vehicleColor,
      capacity: capacity,
      licenseFile: licenseFile,
      idCardFile: idCardFile,
      vehicleFile: vehicleFile,
    );
    return result['driver'] as DriverModel;
  }

  Future<void> verifyOTP({
    required String phone,
    required String otp,
  }) async {
    await _authService.verifyOTP(phone: phone, otp: otp);
  }

 
  Future<Map<String, dynamic>> forgotPassword({required String contact}) async {
    return await _authService.forgotPassword(contact: contact);
  }


  Future<void> resetPassword({
    required int userId,
    required String code,
    required String newPassword,
  }) async {
    await _authService.resetPassword(
      userId: userId,
      code: code,
      newPassword: newPassword,
    );
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
    } catch (e) {
      // 
    } finally {
      await _storage.clearAll();
    }
  }

  Future<bool> isLoggedIn() async {
    try {
      return await _storage.isLoggedIn();
    } catch (e) {
      return false;
    }
  }
}