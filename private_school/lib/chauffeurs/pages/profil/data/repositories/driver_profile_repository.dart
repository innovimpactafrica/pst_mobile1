import 'package:dio/dio.dart';
import '../models/driver_profile_model.dart';
import '../services/driver_profile_service.dart';

class DriverProfileRepository {
  final DriverProfileService _service = DriverProfileService();
  Future<DriverProfileModel> getProfile() async {
    return await _service.getProfile();
  }

  Future<DriverProfileModel> updateProfile({
    required String firstName,
    required String lastName,
    required String phone,
    required String address,
  }) async {
    return await _service.updateProfile(
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      address: address,
    );
  }

  Future<DriverProfileModel> updateProfileWithPhoto(FormData formData) async {
    return await _service.updateProfileWithPhoto(formData);
  }

  Future<DriverProfileModel> updateDriverById({
    required String driverId,
    required FormData formData,
  }) async {
    return await _service.updateDriverById(
      driverId: driverId,
      formData: formData,
    );
  }
}
