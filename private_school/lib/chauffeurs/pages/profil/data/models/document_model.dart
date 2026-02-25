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
