import 'package:private_school/parents/pages/school/data/models/school_model.dart';

class TripModel {
  final String id;
  final String? driverId;
  final String destination;
  final String? startLocation;
  final DateTime date;
  final String time;
  final String? returnTime;
  final String tripType;
  final int totalSeats;
  final int availableSeats;
  final double? price;
  final String status;
  final String? returnStatus;
  final List<Passenger> passengers;
  final List<SchoolModel> schools;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final String? cancelReason;

  // Coordonnées GPS pour afficher l'itinéraire sur la carte
  final double? startLatitude;
  final double? startLongitude;
  final double? endLatitude;
  final double? endLongitude;
  final int? estimatedDuration; // Durée estimée en minutes

  TripModel({
    required this.id,
    this.driverId,
    required this.destination,
    this.startLocation,
    required this.date,
    required this.time,
    this.returnTime,
    this.tripType = 'aller',
    required this.totalSeats,
    required this.availableSeats,
    this.price,
    this.status = 'pending',
    this.returnStatus,
    this.passengers = const [],
    this.schools = const [],
    this.startedAt,
    this.completedAt,
    this.cancelReason,
    this.startLatitude,
    this.startLongitude,
    this.endLatitude,
    this.endLongitude,
    this.estimatedDuration,
  });

  bool get isActive =>
      status == 'active' || status == 'started' || status == 'in_progress';
  bool get isCompleted => status == 'completed';
  bool get isCanceled => status == 'canceled';
  bool get isPending => status == 'pending';

  factory TripModel.fromJson(Map<String, dynamic> json) {
    // Fonctions helper pour conversion sécurisée
    int safeInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      return int.tryParse(value.toString()) ?? 0;
    }

    double? safeDouble(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      return double.tryParse(value.toString());
    }

    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is DateTime) return value;
      try {
        return DateTime.parse(value.toString());
      } catch (e) {
        return DateTime.now();
      }
    }

    List<SchoolModel> parseSchools(Map<String, dynamic> json) {
      if (json['stops'] != null &&
          json['stops'] is List &&
          (json['stops'] as List).isNotEmpty) {
        return (json['stops'] as List).map((stop) {
          final s = stop as Map<String, dynamic>;
          return SchoolModel(
            id: s['school_id'] is int
                ? s['school_id']
                : int.tryParse(s['school_id'].toString()),
            name: (s['school_name'] ?? 'École').toString(),
            address: (s['school_address'] ?? '').toString(),
          );
        }).toList();
      }

      if (json['schools'] != null &&
          json['schools'] is List &&
          (json['schools'] as List).isNotEmpty) {
        return (json['schools'] as List)
            .map((s) => SchoolModel.fromJson(s))
            .toList();
      }

      final schoolId = json['school_id'];
      if (schoolId != null) {
        return [
          SchoolModel(
            id: schoolId is int ? schoolId : int.tryParse(schoolId.toString()),
            name: (json['school_name'] ?? json['end_point'] ?? 'École')
                .toString(),
            address: (json['school_address'] ?? '').toString(),
          ),
        ];
      }

      return [];
    }

    String? extractTime(dynamic departureTime) {
      if (departureTime == null) return null;
      try {
        final dt = DateTime.parse(departureTime.toString());
        return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      } catch (e) {
        return null;
      }
    }

    return TripModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),

      driverId: json['driver_id']?.toString() ?? json['driverId']?.toString(),

      destination: (json['end_point'] ?? json['destination'] ?? '').toString(),
      startLocation: (json['start_point'] ?? json['lieuDepart'] ?? '')
          .toString(),

      date: parseDate(json['departure_time'] ?? json['date']),
      time:
          extractTime(json['departure_time']) ??
          (json['time'] ?? '00:00').toString(),
      returnTime: extractTime(json['return_departure_time']),
      tripType: (json['trip_type'] ?? 'aller').toString(),

      totalSeats: safeInt(json['capacity_max'] ?? json['totalSeats'] ?? 0),
      availableSeats: safeInt(
        json['placesDisponibles'] ?? json['capacity_max'] ?? 0,
      ),

      price: safeDouble(json['price']),

      status: (json['status'] ?? 'pending').toString().toLowerCase(),
      returnStatus: json['return_status']?.toString().toLowerCase(),

      passengers: json['passengers'] != null
          ? (json['passengers'] as List)
                .map((p) => Passenger.fromJson(p))
                .toList()
          : [],

      schools: parseSchools(json),

      startedAt: json['startedAt'] != null
          ? parseDate(json['startedAt'])
          : null,
      completedAt: json['completedAt'] != null
          ? parseDate(json['completedAt'])
          : null,
      cancelReason: json['cancelReason']?.toString(),

      // Coordonnées GPS
      startLatitude: safeDouble(json['start_latitude']),
      startLongitude: safeDouble(json['start_longitude']),
      endLatitude: safeDouble(json['end_latitude']),
      endLongitude: safeDouble(json['end_longitude']),
      estimatedDuration: safeInt(json['estimated_duration']),
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
      'returnTime': returnTime,
      'tripType': tripType,
      'totalSeats': totalSeats,
      'availableSeats': availableSeats,
      'price': price,
      'status': status,
      'returnStatus': returnStatus,
      'passengers': passengers.map((p) => p.toJson()).toList(),
      'schools': schools.map((s) => s.toJson()).toList(),
      'startedAt': startedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'cancelReason': cancelReason,
      'start_latitude': startLatitude,
      'start_longitude': startLongitude,
      'end_latitude': endLatitude,
      'end_longitude': endLongitude,
      'estimated_duration': estimatedDuration,
    };
  }

  TripModel copyWith({
    String? id,
    String? driverId,
    String? destination,
    String? startLocation,
    DateTime? date,
    String? time,
    String? returnTime,
    String? tripType,
    int? totalSeats,
    int? availableSeats,
    double? price,
    String? status,
    String? returnStatus,
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
      returnTime: returnTime ?? this.returnTime,
      tripType: tripType ?? this.tripType,
      totalSeats: totalSeats ?? this.totalSeats,
      availableSeats: availableSeats ?? this.availableSeats,
      price: price ?? this.price,
      status: status ?? this.status,
      returnStatus: returnStatus ?? this.returnStatus,
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
    if (name.isEmpty) return '?';

    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();

    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }

    if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }

    return '?';
  }

  factory Passenger.fromJson(Map<String, dynamic> json) {
    String rawName = (json['child_name'] ?? json['name'] ?? json['nom'] ?? '')
        .toString()
        .trim();

    return Passenger(
      id: (json['child_id'] ?? json['_id'] ?? json['id'] ?? '').toString(),
      name: rawName.isEmpty ? 'Enfant' : rawName,
      phone:
          json['parent_phone']?.toString() ??
          json['phone']?.toString() ??
          json['telephone']?.toString(),
      isConfirmed: json['isConfirmed'] ?? json['confirme'] ?? false,
      photo: json['photo']?.toString() ?? json['image']?.toString(),
      school:
          json['school_name']?.toString() ??
          json['school']?.toString() ??
          json['ecole']?.toString(),
      avatarColor:
          json['avatarColor']?.toString() ?? json['couleur']?.toString(),
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
