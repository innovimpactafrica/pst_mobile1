// Driver profile repository
// Path: lib/chauffeurs/pages/profil/data/repositories/driver_profile_repository.dart

import '../models/driver_profile_model.dart';
import '../services/driver_profile_service.dart';

class DriverProfileRepository {
  final DriverProfileService _service = DriverProfileService();

  /// Get driver profile
  Future<DriverProfileModel> getProfile() async {
    return await _service.fetchProfile();
  }

  /// Update driver profile
  Future<DriverProfileModel> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? email,
    String? address,
  }) async {
    return await _service.updateProfile(
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      email: email,
      address: address,
    );
  }

  // Note: Vehicle info is read-only from the profile endpoint
  // Vehicle updates would need a separate endpoint if available in your API
}