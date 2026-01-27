
class VehicleModel {
  final String? id;
  final String? brand;       // Marque du véhicule (Ex: Ford)
  final String? color;       // Couleur du véhicule (Ex: Jaune)
  final String? plate;       // Immatriculation (Ex: AA-2535-01)
  final int? capacity;       // Nombre de places (Ex: 12)
  final String? photo;       // Photo du véhicule
  final String? type;        // Type de véhicule (Ex: Bus scolaire)

  VehicleModel({
    this.id,
    this.brand,
    this.color,
    this.plate,
    this.capacity,
    this.photo,
    this.type,
  });

  /// Create from JSON (API response)
  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['_id']?.toString() ?? json['id']?.toString(),
      brand: json['brand']?.toString() ?? json['marque']?.toString(),
      color: json['color']?.toString() ?? json['couleur']?.toString(),
      plate: json['plate']?.toString() ?? 
             json['immatriculation']?.toString() ?? 
             json['plateNumber']?.toString(),
      capacity: json['capacity'] ?? json['nombrePlaces'] ?? json['seats'],
      photo: json['photo']?.toString() ?? json['image']?.toString(),
      type: json['type']?.toString() ?? 
            json['vehicleType']?.toString() ?? 
            json['typeVehicule']?.toString(),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (brand != null) 'brand': brand,
      if (color != null) 'color': color,
      if (plate != null) 'plate': plate,
      if (capacity != null) 'capacity': capacity,
      if (photo != null) 'photo': photo,
      if (type != null) 'type': type,
    };
  }

  /// Create a copy with modified fields
  VehicleModel copyWith({
    String? id,
    String? brand,
    String? color,
    String? plate,
    int? capacity,
    String? photo,
    String? type,
  }) {
    return VehicleModel(
      id: id ?? this.id,
      brand: brand ?? this.brand,
      color: color ?? this.color,
      plate: plate ?? this.plate,
      capacity: capacity ?? this.capacity,
      photo: photo ?? this.photo,
      type: type ?? this.type,
    );
  }
}