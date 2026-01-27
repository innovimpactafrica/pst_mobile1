/// Unified user model for the entire application
/// Combines authentication and profile data
/// Location: lib/core/models/user_model.dart
class UserModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final String? address;
  final String? photo;
  final String? role;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    this.address,
    this.photo,
    this.role,
    this.createdAt,
    this.updatedAt,
  });

  /// Full name getter
  String get fullName => '$firstName $lastName';

  /// Initials getter (first letter of first and last name)
  String get initials {
    if (firstName.isEmpty || lastName.isEmpty) return '??';
    return '${firstName[0]}${lastName[0]}'.toUpperCase();
  }

  /// Create from JSON (API response)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Handle name parsing from different API formats
    final fullName = (json['name'] ?? '').toString().split(' ');
    
    // Parse ID - can be int or String
    final dynamic rawId = json['id'] ?? json['_id'];
    final String parsedId = rawId != null ? rawId.toString() : '';

    return UserModel(
      id: parsedId,
      firstName: json['firstName'] ??
          json['prenom'] ??
          (fullName.isNotEmpty ? fullName.first : ''),
      lastName: json['lastName'] ??
          json['nom'] ??
          (fullName.length > 1 ? fullName.sublist(1).join(' ') : ''),
      email: json['email'] ?? '',
      phone: json['phone'] ?? json['telephone'],
      address: json['address'] ?? json['adresse'],
      photo: json['photo'] ?? json['photoUrl'],
      role: json['role'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
    );
  }

  /// Convert to JSON (for sending to API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      if (phone != null) 'phone': phone,
      if (address != null) 'address': address,
      if (photo != null) 'photo': photo,
      if (role != null) 'role': role,
    };
  }

  /// Create a copy with modified fields
  UserModel copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? address,
    String? photo,
    String? role,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      photo: photo ?? this.photo,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}