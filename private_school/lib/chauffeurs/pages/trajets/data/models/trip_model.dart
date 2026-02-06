import 'package:private_school/parents/pages/school/data/models/school_model.dart';

class TripModel {
  final String id;
  final String? driverId;
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
    this.driverId,
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
    // Fonctions helper pour conversion sécurisée
    int safeInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      return int.tryParse(value.toString()) ?? 0;
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

    // ✅ NOUVEAU : Créer une école temporaire à partir du school_id
    List<SchoolModel> parseSchools(Map<String, dynamic> json) {
      // Si l'API retourne déjà une liste d'écoles complète
      if (json['schools'] != null && json['schools'] is List && (json['schools'] as List).isNotEmpty) {
        return (json['schools'] as List).map((s) => SchoolModel.fromJson(s)).toList();
      }
      
      // Sinon, créer une école temporaire à partir du school_id
      final schoolId = json['school_id'];
      if (schoolId != null) {
        // Créer une école "placeholder" avec juste l'ID
        // Le nom sera récupéré via l'API plus tard
        return [
          SchoolModel(
            id: schoolId is int ? schoolId : int.tryParse(schoolId.toString()),
            name: json['end_point'] ?? 'École ID: $schoolId',
            address: '',
          ),
        ];
      }
      
      return [];
    }

    return TripModel(
      // 🔥 CORRECTION : L'id peut être int ou String, on force la conversion
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      
      // driver_id peut être null ou int
      driverId: json['driver_id']?.toString() ?? json['driverId']?.toString(),
      
      // Champs texte
      destination: (json['end_point'] ?? json['destination'] ?? '').toString(),
      startLocation: (json['start_point'] ?? json['lieuDepart'] ?? '').toString(),
      
      // Date et heure
      date: parseDate(json['departure_time'] ?? json['date']),
      time: (json['time'] ?? '00:00').toString(),
      
      // Nombres
      totalSeats: safeInt(json['capacity_max'] ?? json['totalSeats'] ?? 0),
      availableSeats: safeInt(json['placesDisponibles'] ?? json['capacity_max'] ?? 0),
      
      // Prix optionnel
      price: json['price'] != null ? (json['price'] as num).toDouble() : null,
      
      // Status
      status: (json['status'] ?? 'pending').toString().toLowerCase(),
      
      // Listes
      passengers: json['passengers'] != null
          ? (json['passengers'] as List).map((p) => Passenger.fromJson(p)).toList()
          : [],
      
      // ✅ MODIFIÉ : Parser les écoles intelligemment
      schools: parseSchools(json),
      
      // Dates optionnelles
      startedAt: json['startedAt'] != null ? parseDate(json['startedAt']) : null,
      completedAt: json['completedAt'] != null ? parseDate(json['completedAt']) : null,
      cancelReason: json['cancelReason']?.toString(),
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
      name: (json['name'] ?? json['nom'] ?? '').toString(),
      phone: json['phone']?.toString() ?? json['telephone']?.toString(),
      isConfirmed: json['isConfirmed'] ?? json['confirme'] ?? false,
      photo: json['photo']?.toString() ?? json['image']?.toString(),
      school: json['school']?.toString() ?? json['ecole']?.toString(),
      avatarColor: json['avatarColor']?.toString() ?? json['couleur']?.toString(),
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