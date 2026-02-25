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

  String get fullName => '$firstName $lastName';

  String get initials {
    if (firstName.isEmpty || lastName.isEmpty) return '??';
    return '${firstName[0]}${lastName[0]}'.toUpperCase();
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final fullName = (json['name'] ?? '').toString().split(' ');
    final dynamic rawId = json['id'] ?? json['_id'];
    final String parsedId = rawId != null ? rawId.toString() : '';

    // l'adresse serveur
    const String baseUrl = "http://86.106.181.31:3000";

    String? rawPhoto =
        json['photo_profil'] ?? json['photo'] ?? json['photoUrl'];

    String? fullPhotoUrl;
    if (rawPhoto != null && rawPhoto.isNotEmpty) {
      fullPhotoUrl = rawPhoto.startsWith('http')
          ? rawPhoto
          : '$baseUrl$rawPhoto';
    }

    return UserModel(
      id: parsedId,
      firstName:
          json['firstName'] ??
          json['prenom'] ??
          (fullName.isNotEmpty ? fullName.first : ''),
      lastName:
          json['lastName'] ??
          json['nom'] ??
          (fullName.length > 1 ? fullName.sublist(1).join(' ') : ''),
      email: json['email'] ?? '',
      phone: json['phone'] ?? json['telephone'],
      address:
          json['home_address'] ??
          json['address'] ??
          json['adresse'] ??
          json['homeAddress'],
      photo: fullPhotoUrl,
      role: json['role'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
    );
  }

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
