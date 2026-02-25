class VehicleModel {
  final String? id;
  final String? brand;
  final String? color;
  final String? plate;
  final int? capacity;
  final String? photo;
  final String? type;

  VehicleModel({
    this.id,
    this.brand,
    this.color,
    this.plate,
    this.capacity,
    this.photo,
    this.type,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: _parseToStringOrNull(json['_id'] ?? json['id']),
      brand: _parseToStringOrNull(json['brand'] ?? json['marque']),
      color: _parseToStringOrNull(json['color'] ?? json['couleur']),
      plate: _parseToStringOrNull(
        json['plate'] ?? json['immatriculation'] ?? json['plateNumber'],
      ),
      capacity: _parseToIntOrNull(
        json['capacity'] ?? json['nombrePlaces'] ?? json['seats'],
      ),
      photo: _parseToStringOrNull(json['photo'] ?? json['image']),
      type: _parseToStringOrNull(
        json['type'] ?? json['vehicleType'] ?? json['typeVehicule'],
      ),
    );
  }

  static String? _parseToStringOrNull(dynamic value) {
    if (value == null) return null;
    if (value is String) return value.isEmpty ? null : value;
    return value.toString();
  }

  static int? _parseToIntOrNull(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is double) return value.toInt();
    return null;
  }

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
