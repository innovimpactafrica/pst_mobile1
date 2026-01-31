import 'package:dio/dio.dart';
import '../models/driver_profile_model.dart';
import '../services/driver_profile_service.dart';

/// Repository for driver profile data
class DriverProfileRepository {
  final DriverProfileService _service = DriverProfileService();

  /// Get driver profile
  Future<DriverProfileModel> getProfile() async {
    return await _service.getProfile();
  }

  /// Update driver profile (without photo) - Infos personnelles uniquement
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

  /// Update driver profile with photo (FormData) - Infos personnelles + photo_profil
  /// ⚠️ Pour véhicule et documents, utiliser updateDriverById()
  Future<DriverProfileModel> updateProfileWithPhoto(FormData formData) async {
    return await _service.updateProfileWithPhoto(formData);
  }

  /// 🆕 Update driver by ID - Pour VÉHICULE et DOCUMENTS
  /// ✅ Utilisé pour: vehicle_brand, vehicle_color, vehicle_plate, capacity, vehicle_photo
  /// ✅ Utilisé pour: license_document, id_document
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