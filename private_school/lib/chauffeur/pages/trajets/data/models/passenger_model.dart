class PassengerModel {
  final String id;
  final String name;
  final String initials; // "MN", "MF", "AD"
  final String school; // "École Primaire Saint-Michel"
  final String photo; // Optionnel
  final String avatarColor; // Couleur de l'avatar

  PassengerModel({
    required this.id,
    required this.name,
    required this.initials,
    required this.school,
    this.photo = '',
    this.avatarColor = '#4CAF50',
  });

  factory PassengerModel.fromJson(Map<String, dynamic> json) {
    return PassengerModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      initials: json['initials'] ?? '',
      school: json['school'] ?? '',
      photo: json['photo'] ?? '',
      avatarColor: json['avatarColor'] ?? '#4CAF50',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'initials': initials,
      'school': school,
      'photo': photo,
      'avatarColor': avatarColor,
    };
  }
}