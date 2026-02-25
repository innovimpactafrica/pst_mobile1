class DriverModel {
  final String id;
  final String? userId;
  final String firstName;
  final String lastName;
  final String phone;
  final String email;
  final String? address;
  final String? photo;
  final String role;
  final String? licenseNumber;
  final String? vehicleType;
  final String? vehicleColor;
  final bool isActive;
  final int totalTrips;
  final double rating;
  final int totalReviews;
  final double successRate;
  final String memberSince;
  final VehicleModel? vehicle;
  final String? status;

  DriverModel({
    required this.id,
    this.userId,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
    this.address,
    this.photo,
    this.role = 'driver',
    this.licenseNumber,
    this.vehicleType,
    this.vehicleColor,
    this.isActive = true,
    this.totalTrips = 0,
    this.rating = 0.0,
    this.totalReviews = 0,
    this.successRate = 0.0,
    this.memberSince = '',
    this.vehicle,
    this.status,
  });

  String get fullName => '$firstName $lastName'.trim();

  String get initials {
    String firstInitial = firstName.isNotEmpty ? firstName[0] : '';
    String lastInitial = lastName.isNotEmpty ? lastName[0] : '';
    return (firstInitial + lastInitial).toUpperCase();
  }

  factory DriverModel.fromJson(Map<String, dynamic> json) {
    String firstName = '';
    String lastName = '';

    if (json.containsKey('name') && json['name'] != null) {
      final nameValue = json['name'].toString().trim();
      if (nameValue.isNotEmpty) {
        final nameParts = nameValue.split(RegExp(r'\s+'));
        if (nameParts.isNotEmpty) {
          firstName = nameParts.first;
          if (nameParts.length > 1) {
            lastName = nameParts.skip(1).join(' ');
          }
        }
      }
    } else if (json.containsKey('firstName') || json.containsKey('prenom')) {
      firstName = (json['firstName'] ?? json['prenom'] ?? '').toString().trim();
      lastName = (json['lastName'] ?? json['nom'] ?? '').toString().trim();
    }

    // Fallback email si le nom est vide
    if (firstName.isEmpty &&
        json.containsKey('email') &&
        json['email'] != null) {
      final email = json['email'].toString();
      final emailParts = email.split('@');
      if (emailParts.isNotEmpty) {
        firstName = emailParts.first;
      }
    }

    const String baseUrl = "http://86.106.181.31:3000";
    String? rawPhoto =
        json['photo'] ?? json['photoUrl'] ?? json['photo_profil'];
    String? fullPhotoUrl;

    if (rawPhoto != null && rawPhoto.isNotEmpty) {
      fullPhotoUrl = rawPhoto.startsWith('http')
          ? rawPhoto
          : '$baseUrl$rawPhoto';
    }

    final vehicleData = json['vehicle'] as Map<String, dynamic>?;

    final userId = json['user_id']?.toString();

    return DriverModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      firstName: firstName,
      userId: userId,
      lastName: lastName,
      phone: (json['phone'] ?? json['telephone'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      address: json['address']?.toString() ?? json['adresse']?.toString(),
      photo: fullPhotoUrl,
      role: (json['role'] ?? 'driver').toString(),
      isActive: json['isActive'] ?? json['actif'] ?? true,
      status: json['status']?.toString(),

      licenseNumber:
          vehicleData?['plate']?.toString() ??
          vehicleData?['licenseNumber']?.toString() ??
          json['licenseNumber']?.toString() ??
          json['numeroPermis']?.toString(),

      vehicleType:
          vehicleData?['brand']?.toString() ??
          vehicleData?['model']?.toString() ??
          json['vehicleType']?.toString() ??
          json['typeVehicule']?.toString(),

      vehicleColor:
          vehicleData?['color']?.toString() ??
          json['vehicleColor']?.toString() ??
          json['couleur']?.toString(),

      totalTrips: json['totalTrips'] ?? json['nombreTrajets'] ?? 0,
      rating: (json['rating'] ?? json['note'] ?? 0.0).toDouble(),
      totalReviews: json['totalReviews'] ?? json['nombreAvis'] ?? 0,
      successRate: (json['successRate'] ?? json['tauxReussite'] ?? 0.0)
          .toDouble(),
      memberSince:
          json['memberSince']?.toString() ??
          json['membreDepuis']?.toString() ??
          '',
      vehicle: vehicleData != null ? VehicleModel.fromJson(vehicleData) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'userId': userId,
      'phone': phone,
      'email': email,
      'address': address,
      'photo': photo,
      'role': role,
      'licenseNumber': licenseNumber,
      'vehicleType': vehicleType,
      'isActive': isActive,
      'totalTrips': totalTrips,
      'rating': rating,
      'totalReviews': totalReviews,
      'successRate': successRate,
      'memberSince': memberSince,
      'vehicle': vehicle?.toJson(),
      'status': status,
    };
  }

  DriverModel copyWith({
    String? id,
    String? userId,
    String? firstName,
    String? lastName,
    String? phone,
    String? email,
    String? address,
    String? photo,
    String? role,
    String? licenseNumber,
    String? vehicleType,
    bool? isActive,
    int? totalTrips,
    double? rating,
    int? totalReviews,
    double? successRate,
    String? memberSince,
    VehicleModel? vehicle,
    String? status,
  }) {
    return DriverModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      userId: userId ?? this.userId,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      photo: photo ?? this.photo,
      role: role ?? this.role,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      vehicleType: vehicleType ?? this.vehicleType,
      isActive: isActive ?? this.isActive,
      totalTrips: totalTrips ?? this.totalTrips,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      successRate: successRate ?? this.successRate,
      memberSince: memberSince ?? this.memberSince,
      vehicle: vehicle ?? this.vehicle,
      status: status ?? this.status,
    );
  }
}

class VehicleModel {
  final String model;
  final String plate;
  final String color;
  final String? photo;
  final int capacity;

  VehicleModel({
    required this.model,
    required this.plate,
    required this.color,
    this.photo,
    this.capacity = 0,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    const String baseUrl = "http://86.106.181.31:3000";
    String? rawPhoto = json['photo']?.toString();
    String? fullPhotoUrl;

    if (rawPhoto != null && rawPhoto.isNotEmpty) {
      if (rawPhoto.startsWith('http')) {
        fullPhotoUrl = rawPhoto;
      } else {
        fullPhotoUrl = '$baseUrl$rawPhoto';
      }
    }

    return VehicleModel(
      model: (json['model'] ?? json['brand'] ?? '').toString(),
      plate: (json['plate'] ?? json['licenseNumber'] ?? '').toString(),
      color: (json['color'] ?? '').toString(),
      photo: fullPhotoUrl,
      capacity: json['capacity'] ?? json['capacite'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'model': model,
      'plate': plate,
      'color': color,
      'photo': photo,
      'capacity': capacity,
    };
  }
}
