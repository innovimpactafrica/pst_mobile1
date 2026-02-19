class PassengerModel {
  final String id;
  final String name;
  final String? phone;
  final bool isConfirmed;
  final String? photo;
  final String? school;
  final int? schoolId; // ✅ AJOUTÉ
  final String? avatarColor;

  PassengerModel({
    required this.id,
    required this.name,
    this.phone,
    this.isConfirmed = false,
    this.photo,
    this.school,
    this.schoolId, // ✅ AJOUTÉ
    this.avatarColor,
  });

  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  factory PassengerModel.fromJson(Map<String, dynamic> json) {
    return PassengerModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: (json['name'] ?? json['nom'] ?? json['child_name'] ?? '').toString(),
      phone: json['phone']?.toString() ?? json['telephone']?.toString() ?? json['parent_phone']?.toString(),
      isConfirmed: json['isConfirmed'] ?? json['confirme'] ?? false,
      photo: json['photo']?.toString() ?? json['image']?.toString(),
      school: json['school_name']?.toString() ?? json['school']?.toString() ?? json['ecole']?.toString(),
      schoolId: json['school_id'] is int ? json['school_id'] : (json['school_id'] != null ? int.tryParse(json['school_id'].toString()) : null), // ✅ AJOUTÉ
      avatarColor: json['avatarColor']?.toString() ?? json['couleur']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'isConfirmed': isConfirmed,
      'photo': photo,
      'school': school,
      'schoolId': schoolId, // ✅ AJOUTÉ
      'avatarColor': avatarColor,
    };
  }
}