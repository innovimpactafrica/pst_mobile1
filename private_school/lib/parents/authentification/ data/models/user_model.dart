/// Modèle utilisateur (Parent)
/// Chemin: lib/parents/authentification/data/models/user_model.dart

class UserModel {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final String? role;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    this.role,
    this.createdAt,
    this.updatedAt,
  });

  String get fullName => '$firstName $lastName';

  /// Créer depuis JSON (réponse API)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    final fullName = (json['name'] ?? '').toString().split(' ');

    return UserModel(
      id: json['id'],
      firstName: json['firstName']
          ?? json['prenom']
          ?? (fullName.isNotEmpty ? fullName.first : ''),
      lastName: json['lastName']
          ?? json['nom']
          ?? (fullName.length > 1 ? fullName.sublist(1).join(' ') : ''),
      email: json['email'] ?? '',
      phone: json['phone'] ?? json['telephone'],
      role: json['role'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
    );
  }


  /// Convertir en JSON (pour envoyer à l'API)
  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'role': role,
    };
  }

  UserModel copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
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
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}