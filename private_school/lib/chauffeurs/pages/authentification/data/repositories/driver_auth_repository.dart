// Driver authentication repository
// Path: lib/chauffeurs/authentification/data/repositories/driver_auth_repository.dart

import 'dart:io';

import '../../../../../core/storage/secure_storage.dart';
import '../models/driver_model.dart';
import '../services/driver_auth_service.dart';

class DriverAuthRepository {
  final DriverAuthService _authService = DriverAuthService();
  final SecureStorage _storage = SecureStorage();

  // Let errors from service propagate directly
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

  Future<void> forgotPassword({required String phone}) async {
    await _authService.forgotPassword(phone: phone);
  }

  Future<void> resetPassword({
    required String phone,
    required String otp,
    required String newPassword,
  }) async {
    await _authService.resetPassword(
      phone: phone,
      otp: otp,
      newPassword: newPassword,
    );
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
    } catch (e) {
      // Continue with local logout
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