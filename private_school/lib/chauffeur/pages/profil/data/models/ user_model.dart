class UserModel {
  final String id;
  final String firstName;
  final String lastName;
  final String phone;
  final String email;
  final String address;
  final String photo;
  final String role; // 'Parent', 'Chauffeur', etc.

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
    required this.address,
    required this.photo,
    this.role = 'Parent',
  });

  String get fullName => '$firstName $lastName';
  String get initials => '${firstName[0]}${lastName[0]}'.toUpperCase();

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      address: json['address'] ?? '',
      photo: json['photo'] ?? '',
      role: json['role'] ?? 'Parent',
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
    };
  }

  UserModel copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? phone,
    String? email,
    String? address,
    String? photo,
    String? role,
  }) {
    return UserModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      photo: photo ?? this.photo,
      role: role ?? this.role,
    );
  }
}