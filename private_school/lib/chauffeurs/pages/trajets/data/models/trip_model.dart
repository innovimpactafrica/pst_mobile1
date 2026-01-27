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
  final List<SchoolModel> schools; // ✅ AJOUTÉ
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
    this.schools = const [], // ✅ AJOUTÉ
    this.startedAt,
    this.completedAt,
    this.cancelReason,
  });

  bool get isActive => status == 'active' || status == 'started';
  bool get isCompleted => status == 'completed';
  bool get isCanceled => status == 'canceled';
  bool get isPending => status == 'pending';

  factory TripModel.fromJson(Map<String, dynamic> json) {
    return TripModel(
      id: json['_id'] ?? json['id'] ?? '',
      driverId: json['driverId'] ?? json['chauffeurId'] ?? '',
      destination: json['destination'] ?? '',
      startLocation: json['startLocation'] ?? json['lieuDepart'],
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      time: json['time'] ?? json['heure'] ?? '',
      totalSeats: json['totalSeats'] ?? json['placesTotal'] ?? 0,
      availableSeats: json['availableSeats'] ?? json['placesDisponibles'] ?? 0,
      price: json['price'] != null ? (json['price'] as num).toDouble() : null,
      status: json['status'] ?? json['statut'] ?? 'pending',
      passengers: json['passengers'] != null
          ? (json['passengers'] as List)
              .map((p) => Passenger.fromJson(p))
              .toList()
          : [],
      schools: json['schools'] != null // ✅ AJOUTÉ
          ? (json['schools'] as List)
              .map((s) => SchoolModel.fromJson(s))
              .toList()
          : [],
      startedAt: json['startedAt'] != null
          ? DateTime.parse(json['startedAt'])
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
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
      'schools': schools.map((s) => s.toJson()).toList(), // ✅ AJOUTÉ
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
    List<SchoolModel>? schools, // ✅ AJOUTÉ
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
      schools: schools ?? this.schools, // ✅ AJOUTÉ
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
  final String? photo;           // ✅ AJOUTÉ
  final String? school;          // ✅ AJOUTÉ
  final String? avatarColor;     // ✅ AJOUTÉ

  Passenger({
    required this.id,
    required this.name,
    this.phone,
    this.isConfirmed = false,
    this.photo,              // ✅ AJOUTÉ
    this.school,             // ✅ AJOUTÉ
    this.avatarColor,        // ✅ AJOUTÉ
  });

  // ✅ GETTER pour les initiales
  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  factory Passenger.fromJson(Map<String, dynamic> json) {
    return Passenger(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? json['nom'] ?? '',
      phone: json['phone'] ?? json['telephone'],
      isConfirmed: json['isConfirmed'] ?? json['confirme'] ?? false,
      photo: json['photo'] ?? json['image'],                    // ✅ AJOUTÉ
      school: json['school'] ?? json['ecole'],                  // ✅ AJOUTÉ
      avatarColor: json['avatarColor'] ?? json['couleur'],      // ✅ AJOUTÉ
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'isConfirmed': isConfirmed,
      'photo': photo,           // ✅ AJOUTÉ
      'school': school,         // ✅ AJOUTÉ
      'avatarColor': avatarColor, // ✅ AJOUTÉ
    };
  }
}