import 'school_model.dart';

class TripModel {
  final String id;
  final String driverId;
  final String destination;
  final String? startLocation;
  final DateTime date;
  final String time;
  final int totalSeats;
  final int availableSeats;
  final double? price;
  final String status;
  final List<Passenger> passengers;
  final List<SchoolModel> schools;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final String? cancelReason;

  TripModel({
    required this.id,
    required this.driverId,
    required this.destination,
    this.startLocation,
    required this.date,
    required this.time,
    required this.totalSeats,
    required this.availableSeats,
    this.price,
    this.status = 'pending',
    this.passengers = const [],
    this.schools = const [],
    this.startedAt,
    this.completedAt,
    this.cancelReason,
  });

  bool get isActive => status == 'active' || status == 'started' || status == 'in_progress';
  bool get isCompleted => status == 'completed';
  bool get isCanceled => status == 'canceled';
  bool get isPending => status == 'pending';

  factory TripModel.fromJson(Map<String, dynamic> json) {
    // Helper pour convertir n'importe quel type en String
    String toString(dynamic value, [String defaultValue = '']) {
      if (value == null) return defaultValue;
      return value.toString();
    }

    // Helper pour convertir en int
    int toInt(dynamic value, [int defaultValue = 0]) {
      if (value == null) return defaultValue;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? defaultValue;
      if (value is num) return value.toInt();
      return defaultValue;
    }

    // Helper pour parser DateTime
    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is DateTime) return value;
      if (value is String) {
        try {
          return DateTime.parse(value);
        } catch (e) {
          return DateTime.now();
        }
      }
      return DateTime.now();
    }

    // Parser le temps depuis departure_time ou time
    String parseTime(Map<String, dynamic> json) {
      if (json['time'] != null) return json['time'] as String;
      if (json['heure'] != null) return json['heure'] as String;
      
      // Si departure_time existe, extraire l'heure
      if (json['departure_time'] != null) {
        final departureTime = parseDate(json['departure_time']);
        return '${departureTime.hour.toString().padLeft(2, '0')}:${departureTime.minute.toString().padLeft(2, '0')}';
      }
      
      return '00:00';
    }

    return TripModel(
      // Convertir id (int ou String) en String
      id: toString(json['id'] ?? json['_id']),
      
      // Convertir driver_id (int) en String
      driverId: toString(json['driver_id'] ?? json['driverId'] ?? json['chauffeurId']),
      
      // Destination (end_point ou destination)
      destination: json['end_point'] ?? json['destination'] ?? '',
      
      // Start location (start_point ou startLocation)
      startLocation: json['start_point'] ?? json['startLocation'] ?? json['lieuDepart'],
      
      // Date (departure_time ou date)
      date: parseDate(json['departure_time'] ?? json['date'] ?? json['created_at']),
      
      // Time
      time: parseTime(json),
      
      // Total seats (capacity_max ou totalSeats)
      totalSeats: toInt(json['capacity_max'] ?? json['totalSeats'] ?? json['placesTotal']),
      
      // Available seats (calculé ou fourni)
      availableSeats: toInt(
        json['availableSeats'] ?? 
        json['placesDisponibles'] ?? 
        json['capacity_max'] ?? 
        json['totalSeats'] ?? 
        0,
      ),
      
      // Price
      price: json['price'] != null ? (json['price'] as num).toDouble() : null,
      
      // Status (normaliser in_progress → active)
      status: (json['status'] ?? json['statut'] ?? 'pending').toString().toLowerCase(),
      
      // Passengers
      passengers: json['passengers'] != null
          ? (json['passengers'] as List)
              .map((p) => Passenger.fromJson(p))
              .toList()
          : [],
      
      // Schools
      schools: json['schools'] != null
          ? (json['schools'] as List)
              .map((s) => SchoolModel.fromJson(s))
              .toList()
          : [],
      
      // Dates de suivi
      startedAt: json['startedAt'] != null
          ? parseDate(json['startedAt'])
          : null,
      completedAt: json['completedAt'] != null
          ? parseDate(json['completedAt'])
          : null,
      cancelReason: json['cancelReason'] ?? json['raisonAnnulation'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'driverId': driverId,
      'destination': destination,
      'startLocation': startLocation,
      'date': date.toIso8601String(),
      'time': time,
      'totalSeats': totalSeats,
      'availableSeats': availableSeats,
      'price': price,
      'status': status,
      'passengers': passengers.map((p) => p.toJson()).toList(),
      'schools': schools.map((s) => s.toJson()).toList(),
      'startedAt': startedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'cancelReason': cancelReason,
    };
  }

  TripModel copyWith({
    String? id,
    String? driverId,
    String? destination,
    String? startLocation,
    DateTime? date,
    String? time,
    int? totalSeats,
    int? availableSeats,
    double? price,
    String? status,
    List<Passenger>? passengers,
    List<SchoolModel>? schools,
    DateTime? startedAt,
    DateTime? completedAt,
    String? cancelReason,
  }) {
    return TripModel(
      id: id ?? this.id,
      driverId: driverId ?? this.driverId,
      destination: destination ?? this.destination,
      startLocation: startLocation ?? this.startLocation,
      date: date ?? this.date,
      time: time ?? this.time,
      totalSeats: totalSeats ?? this.totalSeats,
      availableSeats: availableSeats ?? this.availableSeats,
      price: price ?? this.price,
      status: status ?? this.status,
      passengers: passengers ?? this.passengers,
      schools: schools ?? this.schools,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      cancelReason: cancelReason ?? this.cancelReason,
    );
  }
}

class Passenger {
  final String id;
  final String name;
  final String? phone;
  final bool isConfirmed;
  final String? photo;
  final String? school;
  final String? avatarColor;

  Passenger({
    required this.id,
    required this.name,
    this.phone,
    this.isConfirmed = false,
    this.photo,
    this.school,
    this.avatarColor,
  });

  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  factory Passenger.fromJson(Map<String, dynamic> json) {
    return Passenger(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: json['name'] ?? json['nom'] ?? '',
      phone: json['phone'] ?? json['telephone'],
      isConfirmed: json['isConfirmed'] ?? json['confirme'] ?? false,
      photo: json['photo'] ?? json['image'],
      school: json['school'] ?? json['ecole'],
      avatarColor: json['avatarColor'] ?? json['couleur'],
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
      'avatarColor': avatarColor,
    };
  }
}