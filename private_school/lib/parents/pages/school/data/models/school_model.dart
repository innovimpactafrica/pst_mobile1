class SchoolModel {
  final int? id;
  final String name;
  final String address;
  final String? openingTime;
  final String? closingTime;
  final String? status;
  final String? logoUrl;
  final String? createdAt;
  final double? latitude;
  final double? longitude;

  final List<Map<String, dynamic>>? schedule;

  SchoolModel({
    this.id,
    required this.name,
    required this.address,
    this.openingTime,
    this.closingTime,
    this.status,
    this.logoUrl,
    this.createdAt,
    this.latitude,
    this.longitude,
    this.schedule,
  });

  factory SchoolModel.fromJson(Map<String, dynamic> json) {
    List<Map<String, dynamic>>? parsedSchedule;
    if (json['schedule'] != null && json['schedule'] is List) {
      parsedSchedule = (json['schedule'] as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    }

    return SchoolModel(
      id: json['id'],
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      openingTime: json['opening_time'],
      closingTime: json['closing_time'],
      status: json['status'],
      logoUrl: json['logo_url'],
      createdAt: json['created_at'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      schedule: parsedSchedule,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'address': address,
      if (openingTime != null) 'opening_time': openingTime,
      if (closingTime != null) 'closing_time': closingTime,
      if (status != null) 'status': status,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (schedule != null) 'schedule': schedule,
    };
  }

  SchoolModel copyWith({
    int? id,
    String? name,
    String? address,
    String? openingTime,
    String? closingTime,
    String? status,
    String? logoUrl,
    String? createdAt,
    double? latitude,
    double? longitude,
    List<Map<String, dynamic>>? schedule,
  }) {
    return SchoolModel(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      openingTime: openingTime ?? this.openingTime,
      closingTime: closingTime ?? this.closingTime,
      status: status ?? this.status,
      logoUrl: logoUrl ?? this.logoUrl,
      createdAt: createdAt ?? this.createdAt,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      schedule: schedule ?? this.schedule,
    );
  }

  @override
  String toString() {
    return 'SchoolModel(id: $id, name: $name, address: $address)';
  }
}
