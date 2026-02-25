import 'vehicle_model.dart';
class DriverProfileModel {
  final PersonalInfo personal;
  final DriverInfo driver;
  final VehicleModel? vehicle;

  DriverProfileModel({
    required this.personal,
    required this.driver,
    this.vehicle,
  });

  String get id => personal.id.toString();
  String get firstName => personal.firstName;
  String get lastName => personal.lastName;
  String get fullName => personal.fullName;
  String get phone => personal.phone;
  String get email => personal.email;
  String? get address => personal.address;
  String? get photo => personal.photoProfile;
  String? get licenseNumber => null; 
  bool get isActive => true; 

 
  String get vehicleModel => vehicle?.brand ?? 'Non renseigné';
  String get vehicleColor => vehicle?.color ?? 'Non renseigné';
  String get vehiclePlate => vehicle?.plate ?? 'Non renseigné';
  int get vehicleSeats => vehicle?.capacity ?? 0;


  String get initials {
    String firstInitial = firstName.isNotEmpty ? firstName[0] : '';
    String lastInitial = lastName.isNotEmpty ? lastName[0] : '';
    return (firstInitial + lastInitial).toUpperCase();
  }


  factory DriverProfileModel.fromJson(Map<String, dynamic> json) {
    return DriverProfileModel(
      personal: PersonalInfo.fromJson(json['personal'] ?? {}),
      driver: DriverInfo.fromJson(json['driver'] ?? {}),
      vehicle: json['vehicle'] != null
          ? VehicleModel.fromJson(json['vehicle'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'personal': personal.toJson(),
      'driver': driver.toJson(),
      if (vehicle != null) 'vehicle': vehicle!.toJson(),
    };
  }

  
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
      id: _parseToInt(json['id']),
      firstName: _parseToString(json['first_name']),
      lastName: _parseToString(json['last_name']),
      fullName: _parseToString(json['full_name']),
      email: _parseToString(json['email']),
      phone: _parseToString(json['phone']),
      address: _parseToStringOrNull(json['address']),
      photoProfile: _parseToStringOrNull(json['photo_profil']),
    );
  }

  // Helper methods for safe type conversion
  static int _parseToInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static String _parseToString(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    return value.toString();
  }

  static String? _parseToStringOrNull(dynamic value) {
    if (value == null) return null;
    if (value is String) return value.isEmpty ? null : value;
    return value.toString();
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

class DriverInfo {
  final int id;
  final String status;
  final String? photoProfile;
  final String? licenseDocument;  
  final String? idDocument;      
  final String? vehiclePhoto;     

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
      id: PersonalInfo._parseToInt(json['id']),
      status: PersonalInfo._parseToString(json['status']),
      photoProfile: PersonalInfo._parseToStringOrNull(json['photo_profil']),
      licenseDocument: PersonalInfo._parseToStringOrNull(json['license_document']),
      idDocument: PersonalInfo._parseToStringOrNull(json['id_document']),
      vehiclePhoto: PersonalInfo._parseToStringOrNull(json['vehicle_photo']),
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