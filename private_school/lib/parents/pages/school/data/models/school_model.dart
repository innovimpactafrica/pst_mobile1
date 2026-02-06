class SchoolModel {
  final int? id;
  final String name;
  final String address;
  final String? openingTime;
  final String? closingTime;
  final String? status;
  final String? logoUrl;
  final String? createdAt;
  
  // ✅ CORRECTION: schedule est une liste, pas une string
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
    this.schedule,
  });

  factory SchoolModel.fromJson(Map<String, dynamic> json) {
    // ✅ Parse schedule comme une Liste
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
      schedule: schedule ?? this.schedule,
    );
  }

  @override
  String toString() {
    return 'SchoolModel(id: $id, name: $name, address: $address)';
  }
}