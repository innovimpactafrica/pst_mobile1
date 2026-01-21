class SchoolModel {
  final String id;
  final String name;
  final String icon; // URL ou asset path de l'icône
  final String numberOfStudents; // "2 élèves" ou "1 élève"
  final String address; // Optionnel

  SchoolModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.numberOfStudents,
    this.address = '',
  });

  factory SchoolModel.fromJson(Map<String, dynamic> json) {
    return SchoolModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      icon: json['icon'] ?? '',
      numberOfStudents: json['numberOfStudents'] ?? '',
      address: json['address'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'numberOfStudents': numberOfStudents,
      'address': address,
    };
  }
}