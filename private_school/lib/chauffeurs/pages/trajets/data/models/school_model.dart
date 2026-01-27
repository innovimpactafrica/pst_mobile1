// School model for trip destinations
// Location: lib/chauffeurs/pages/trajets/data/models/school_model.dart

class SchoolModel {
  final String id;
  final String name;
  final String numberOfStudents;
  final String address;
  final String icon;
  final double? latitude;
  final double? longitude;

  SchoolModel({
    required this.id,
    required this.name,
    required this.numberOfStudents,
    this.address = '',
    this.icon = '',
    this.latitude,
    this.longitude,
  });

  factory SchoolModel.fromJson(Map<String, dynamic> json) {
    return SchoolModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? json['nom'] ?? '',
      numberOfStudents: json['numberOfStudents'] ?? 
                       json['nombreEleves'] ?? 
                       '${json['studentsCount'] ?? 0} élèves',
      address: json['address'] ?? json['adresse'] ?? '',
      icon: json['icon'] ?? json['icone'] ?? '',
      latitude: json['latitude'] != null 
          ? (json['latitude'] as num).toDouble() 
          : null,
      longitude: json['longitude'] != null 
          ? (json['longitude'] as num).toDouble() 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'numberOfStudents': numberOfStudents,
      'address': address,
      'icon': icon,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}