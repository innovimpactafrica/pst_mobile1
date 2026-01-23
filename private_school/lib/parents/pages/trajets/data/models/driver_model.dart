class DriverModel {
  final String id;
  final String name;
  final String photo;
  final String memberSince; // "Membre depuis 2022"
  final String phone;
  final double rating; // 4.8
  final int totalReviews; // 129
  final int totalTrips; // 245
  final double successRate; // 98%

  // Informations véhicule
  final VehicleModel? vehicle;

  DriverModel({
    required this.id,
    required this.name,
    required this.photo,
    required this.memberSince,
    required this.phone,
    required this.rating,
    required this.totalReviews,
    required this.totalTrips,
    required this.successRate,
    this.vehicle,
  });

  factory DriverModel.fromJson(Map<String, dynamic> json) {
    return DriverModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      photo: json['photo'] ?? '',
      memberSince: json['memberSince'] ?? '',
      phone: json['phone'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      totalReviews: json['totalReviews'] ?? 0,
      totalTrips: json['totalTrips'] ?? 0,
      successRate: (json['successRate'] ?? 0).toDouble(),
      vehicle: json['vehicle'] != null
          ? VehicleModel.fromJson(json['vehicle'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'photo': photo,
      'memberSince': memberSince,
      'phone': phone,
      'rating': rating,
      'totalReviews': totalReviews,
      'totalTrips': totalTrips,
      'successRate': successRate,
      'vehicle': vehicle?.toJson(),
    };
  }
}

class VehicleModel {
  final String id;
  final String model; // "SELOV SERIE SA"
  final String plate; // "AA-1234-56"
  final String color; // "Blanche"
  final String photo;
  final int capacity; // Nombre de places

  VehicleModel({
    required this.id,
    required this.model,
    required this.plate,
    required this.color,
    required this.photo,
    required this.capacity,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id'] ?? '',
      model: json['model'] ?? '',
      plate: json['plate'] ?? '',
      color: json['color'] ?? '',
      photo: json['photo'] ?? '',
      capacity: json['capacity'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'model': model,
      'plate': plate,
      'color': color,
      'photo': photo,
      'capacity': capacity,
    };
  }
}