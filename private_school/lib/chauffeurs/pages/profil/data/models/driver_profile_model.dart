import 'vehicle_model.dart';

/// Driver profile model matching EXACT API response from GET /api/drivers/profile
/// API returns: { success: true, data: { personal: {...}, driver: {...}, vehicle: {...} } }
/// Location: lib/chauffeurs/pages/profil/data/models/driver_profile_model.dart

class DriverProfileModel {
  final PersonalInfo personal;
  final DriverInfo driver;
  final VehicleModel? vehicle;

  DriverProfileModel({
    required this.personal,
    required this.driver,
    this.vehicle,
  });

  // Convenience getters for backward compatibility
  String get id => personal.id.toString();
  String get firstName => personal.firstName;
  String get lastName => personal.lastName;
  String get fullName => personal.fullName;
  String get phone => personal.phone;
  String get email => personal.email;
  String? get address => personal.address;
  String? get photo => personal.photoProfile;
  String? get licenseNumber => null; // Not in API
  bool get isActive => true; // Not in API

  // Vehicle getters for vehicle_info_page.dart compatibility
  String get vehicleModel => vehicle?.brand ?? 'Non renseigné';
  String get vehicleColor => vehicle?.color ?? 'Non renseigné';
  String get vehiclePlate => vehicle?.plate ?? 'Non renseigné';
  int get vehicleSeats => vehicle?.capacity ?? 0;

  // Initials getter
  String get initials {
    String firstInitial = firstName.isNotEmpty ? firstName[0] : '';
    String lastInitial = lastName.isNotEmpty ? lastName[0] : '';
    return (firstInitial + lastInitial).toUpperCase();
  }

  /// Create from JSON - matches API structure exactly
  factory DriverProfileModel.fromJson(Map<String, dynamic> json) {
    return DriverProfileModel(
      personal: PersonalInfo.fromJson(json['personal'] ?? {}),
      driver: DriverInfo.fromJson(json['driver'] ?? {}),
      vehicle: json['vehicle'] != null
          ? VehicleModel.fromJson(json['vehicle'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'personal': personal.toJson(),
      'driver': driver.toJson(),
      if (vehicle != null) 'vehicle': vehicle!.toJson(),
    };
  }

  /// Create a copy with modified fields
  DriverProfileModel copyWith({
    PersonalInfo? personal,
    DriverInfo? driver,
    VehicleModel? vehicle,
  }) {
    return DriverProfileModel(
      personal: personal ?? this.personal,
      driver: driver ?? this.driver,
      vehicle: vehicle ?? this.vehicle,
    );
  }
}

/// Personal information section from API
class PersonalInfo {
  final int id;
  final String firstName;
  final String lastName;
  final String fullName;
  final String email;
  final String phone;
  final String? address;
  final String? photoProfile;

  PersonalInfo({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.email,
    required this.phone,
    this.address,
    this.photoProfile,
  });

  factory PersonalInfo.fromJson(Map<String, dynamic> json) {
    return PersonalInfo(
      id: json['id'] ?? 0,
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'],
      photoProfile: json['photo_profil'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      if (address != null) 'address': address,
      if (photoProfile != null) 'photo_profil': photoProfile,
    };
  }

  PersonalInfo copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? fullName,
    String? email,
    String? phone,
    String? address,
    String? photoProfile,
  }) {
    return PersonalInfo(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      photoProfile: photoProfile ?? this.photoProfile,
    );
  }
}

/// Driver information section from API
/// Driver information section from API
/// UPDATED: Added document fields (license_document, id_document, vehicle_photo)
class DriverInfo {
  final int id;
  final String status;
  final String? photoProfile;
  final String? licenseDocument;  // NEW: Permis de conduire
  final String? idDocument;       // NEW: CNI/Passeport
  final String? vehiclePhoto;     // NEW: Photo du véhicule

  DriverInfo({
    required this.id,
    required this.status,
    this.photoProfile,
    this.licenseDocument,
    this.idDocument,
    this.vehiclePhoto,
  });

  factory DriverInfo.fromJson(Map<String, dynamic> json) {
    return DriverInfo(
      id: json['id'] ?? 0,
      status: json['status'] ?? '',
      photoProfile: json['photo_profil'],
      licenseDocument: json['license_document'],
      idDocument: json['id_document'],
      vehiclePhoto: json['vehicle_photo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      if (photoProfile != null) 'photo_profil': photoProfile,
      if (licenseDocument != null) 'license_document': licenseDocument,
      if (idDocument != null) 'id_document': idDocument,
      if (vehiclePhoto != null) 'vehicle_photo': vehiclePhoto,
    };
  }

  DriverInfo copyWith({
    int? id,
    String? status,
    String? photoProfile,
    String? licenseDocument,
    String? idDocument,
    String? vehiclePhoto,
  }) {
    return DriverInfo(
      id: id ?? this.id,
      status: status ?? this.status,
      photoProfile: photoProfile ?? this.photoProfile,
      licenseDocument: licenseDocument ?? this.licenseDocument,
      idDocument: idDocument ?? this.idDocument,
      vehiclePhoto: vehiclePhoto ?? this.vehiclePhoto,
    );
  }
}