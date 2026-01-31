// Driver model with bulletproof API response parsing
// Path: lib/chauffeurs/authentification/data/models/driver_model.dart

class DriverModel {
  final String id;
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

  DriverModel({
    required this.id,
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
  });

  String get fullName => '$firstName $lastName'.trim();

  String get initials {
    String firstInitial = firstName.isNotEmpty ? firstName[0] : '';
    String lastInitial = lastName.isNotEmpty ? lastName[0] : '';
    return (firstInitial + lastInitial).toUpperCase();
  }

 factory DriverModel.fromJson(Map<String, dynamic> json) {
    // 1. Logique pour le nom et le prénom (Déjà robuste)
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
    if (firstName.isEmpty && json.containsKey('email') && json['email'] != null) {
      final email = json['email'].toString();
      final emailParts = email.split('@');
      if (emailParts.isNotEmpty) {
        firstName = emailParts.first;
      }
    }

    // 2. Extraction des données du véhicule 
    // On récupère l'objet 'vehicle' s'il existe
    final vehicleData = json['vehicle'] as Map<String, dynamic>?;

    
    return DriverModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      firstName: firstName,
      lastName: lastName,
      phone: (json['phone'] ?? json['telephone'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      address: json['address']?.toString() ?? json['adresse']?.toString(),
      photo: json['photo']?.toString(),
      role: (json['role'] ?? 'driver').toString(),
      isActive: json['isActive'] ?? json['actif'] ?? true,
      
     
      licenseNumber: vehicleData?['plate']?.toString() ?? 
                     vehicleData?['licenseNumber']?.toString() ?? 
                     json['licenseNumber']?.toString() ?? 
                     json['numeroPermis']?.toString(),
      

      vehicleType: vehicleData?['brand']?.toString() ?? 
                   vehicleData?['model']?.toString() ?? 
                   json['vehicleType']?.toString() ?? 
                   json['typeVehicule']?.toString(),

      
      vehicleColor: vehicleData?['color']?.toString() ?? 
                    json['vehicleColor']?.toString() ??
                    json['couleur']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'email': email,
      'address': address,
      'photo': photo,
      'role': role,
      'licenseNumber': licenseNumber,
      'vehicleType': vehicleType,
      'isActive': isActive,
    };
  }

  DriverModel copyWith({
    String? id,
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
  }) {
    return DriverModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      photo: photo ?? this.photo,
      role: role ?? this.role,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      vehicleType: vehicleType ?? this.vehicleType,
      isActive: isActive ?? this.isActive,
    );
  }
}