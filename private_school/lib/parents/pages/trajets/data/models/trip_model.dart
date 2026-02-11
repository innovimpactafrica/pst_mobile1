import 'package:flutter/foundation.dart';
import 'package:private_school/chauffeurs/pages/authentification/data/models/driver_model.dart';
import 'package:private_school/parents/pages/school/data/models/school_model.dart';
import 'passenger_model.dart';

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
  final List<PassengerModel> passengers;
  final List<SchoolModel> schools;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final String? cancelReason;
  final DriverModel? driver;
  
  // ===== Mobile enriched fields =====
  final String? driverPhone;
  final int? driverRating;
  final String? driverPhoto;
  final String? vehiclePlate;
  final String? vehiclePhoto;

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
    this.driver,
    this.driverPhone,
    this.driverRating,
    this.driverPhoto,
    this.vehiclePlate,
    this.vehiclePhoto,
  });

  // ========== GETTERS ==========
  
  bool get isActive => status == 'active' || status == 'started' || status == 'in_progress';
  bool get isCompleted => status == 'completed';
  bool get isCanceled => status == 'canceled';
  bool get isPending => status == 'pending';

  String get departure => startLocation ?? 'Point de départ';
  String get arrival => destination;
  
  String get departureTime => time;
  String get arrivalTime {
    try {
      final parts = time.split(':');
      if (parts.length >= 2) {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        final arrivalHour = (hour + 1) % 24;
        return '${arrivalHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
      }
    } catch (e) {
      // Ignore
    }
    return time;
  }
  
  String get duration => '1h 00min';
  String get driverName => driver?.fullName ?? 'Chauffeur non assigné';
  String get driverImg => driver?.photo ?? driverPhoto ?? '';
  
  String get formattedDate => '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  
  bool get hasDriverPhoto => (driver?.photo != null && driver!.photo!.isNotEmpty) || 
                             (driverPhoto != null && driverPhoto!.isNotEmpty);
  String get driverPhotoUrl => driver?.photo ?? driverPhoto ?? '';
  
  bool get hasVehiclePhoto => vehiclePhoto != null && vehiclePhoto!.isNotEmpty && 
                              !vehiclePhoto!.contains('drive.google.com'); // ⚠️ Exclure Google Drive
  String get vehiclePhotoUrl => vehiclePhoto ?? '';

  factory TripModel.fromJson(Map<String, dynamic> json) {
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('🔍 [TripModel] JSON REÇU DE L\'API:');
    debugPrint(json.toString());
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

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

    final departureDateTime = parseDate(json['departure_time'] ?? json['date']);
    final timeStr = '${departureDateTime.hour.toString().padLeft(2, '0')}:${departureDateTime.minute.toString().padLeft(2, '0')}';

    debugPrint('📊 [TripModel] CAPACITÉ:');
    debugPrint('   capacity_max brut: ${json['capacity_max']}');
    debugPrint('   totalSeats brut: ${json['totalSeats']}');
    debugPrint('   Type capacity_max: ${json['capacity_max'].runtimeType}');

    final capacityMax = safeInt(json['capacity_max'] ?? json['totalSeats'] ?? 0);
    debugPrint('   ✅ Capacité finale: $capacityMax');

    debugPrint('👥 [TripModel] PASSAGERS:');
    debugPrint('   passengers brut: ${json['passengers']}');
    debugPrint('   Type passengers: ${json['passengers'].runtimeType}');
    
    List<PassengerModel> parsedPassengers = [];
    if (json['passengers'] != null && json['passengers'] is List) {
      parsedPassengers = (json['passengers'] as List)
          .map((p) => PassengerModel.fromJson(p as Map<String, dynamic>))
          .toList();
      debugPrint('   ✅ Nombre de passagers parsés: ${parsedPassengers.length}');
    } else if (json['passengers'] != null && json['passengers'] is int) {
      debugPrint('   ⚠️ passengers est un nombre: ${json['passengers']}');
    } else {
      debugPrint('   ⚠️ passengers est null ou type inconnu');
    }

    DriverModel? parsedDriver;
    if (json['driver'] != null && json['driver'] is Map) {
      try {
        parsedDriver = DriverModel.fromJson(json['driver'] as Map<String, dynamic>);
      } catch (e) {
        debugPrint('❌ Erreur parsing driver: $e');
      }
    }

    // ===== MOBILE DRIVER FIELDS (avec URL complètes) =====
    const String baseUrl = "http://86.106.181.31:3000";
    
    final mobileDriverName = json['driver_name']?.toString();
    final mobileDriverPhone = json['driver_phone']?.toString();
    final mobileDriverRating = json['driver_rating'] is int
        ? json['driver_rating']
        : (json['driver_rating'] is String
            ? int.tryParse(json['driver_rating'])
            : null);
    
    // ✅ PHOTO CHAUFFEUR avec URL complète
    String? mobileDriverPhoto = json['driver_photo']?.toString();
    if (mobileDriverPhoto != null && mobileDriverPhoto.isNotEmpty) {
      if (!mobileDriverPhoto.startsWith('http')) {
        mobileDriverPhoto = '$baseUrl$mobileDriverPhoto';
      }
    }
    
    final mobileVehiclePlate = json['vehicle_plate']?.toString();
    
    // ✅ PHOTO VÉHICULE avec URL complète (sauf Google Drive)
    String? mobileVehiclePhoto = json['vehicle_photo']?.toString();
    if (mobileVehiclePhoto != null && mobileVehiclePhoto.isNotEmpty) {
      // Si ce n'est PAS Google Drive ET que c'est un chemin relatif
      if (!mobileVehiclePhoto.startsWith('http')) {
        mobileVehiclePhoto = '$baseUrl$mobileVehiclePhoto';
      }
      // Si c'est Google Drive, on le garde mais on sait qu'il ne s'affichera pas
      if (mobileVehiclePhoto.contains('drive.google.com')) {
        debugPrint('⚠️ Photo véhicule est un lien Google Drive (non affichable)');
      }
    }

    // Si pas d'objet driver mais infos mobiles disponibles → créer un driver
    if (parsedDriver == null && mobileDriverName != null) {
      final nameParts = mobileDriverName.split(RegExp(r'\s+'));
      parsedDriver = DriverModel(
        id: json['driver_id']?.toString() ?? '',
        firstName: nameParts.isNotEmpty ? nameParts.first : mobileDriverName,
        lastName: nameParts.length > 1 ? nameParts.skip(1).join(' ') : '',
        email: '',
        phone: mobileDriverPhone ?? '',
        photo: mobileDriverPhoto, // ✅ URL COMPLÈTE
      );
    }

    List<SchoolModel> parsedSchools = [];
    if (json['schools'] != null && json['schools'] is List) {
      parsedSchools = (json['schools'] as List)
          .map((s) => SchoolModel.fromJson(s as Map<String, dynamic>))
          .toList();
    } else if (json['school_name'] != null) {
      parsedSchools = [
        SchoolModel(
          id: null,
          name: json['school_name'].toString(),
          address: '',
        )
      ];
    }

    debugPrint('');
    debugPrint('✅ [TripModel] RÉSUMÉ PARSING:');
    debugPrint('   ID: ${json['id']?.toString() ?? json['_id']?.toString()}');
    debugPrint('   Destination: ${json['end_point'] ?? json['destination']}');
    debugPrint('   Total Seats: $capacityMax');
    debugPrint('   Passagers: ${parsedPassengers.length}');
    debugPrint('   Écoles: ${parsedSchools.length}');
    debugPrint('   Status: ${json['status']}');
    debugPrint('   Photo chauffeur: $mobileDriverPhoto');
    debugPrint('   Photo véhicule: $mobileVehiclePhoto');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    return TripModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      driverId: json['driver_id']?.toString() ?? json['driverId']?.toString(),
      destination: json['end_point']?.toString() ?? json['destination']?.toString() ?? '',
      startLocation: json['start_point']?.toString() ?? json['lieuDepart']?.toString(),
      date: departureDateTime,
      time: timeStr,
      totalSeats: capacityMax,
      availableSeats: safeInt(json['placesDisponibles'] ?? json['capacity_max'] ?? 0),
      price: json['price'] != null ? (json['price'] as num).toDouble() : null,
      status: json['status']?.toString().toLowerCase() ?? 'pending',
      passengers: parsedPassengers,
      schools: parsedSchools,
      startedAt: json['startedAt'] != null ? parseDate(json['startedAt']) : null,
      completedAt: json['completedAt'] != null ? parseDate(json['completedAt']) : null,
      cancelReason: json['cancelReason']?.toString(),
      driver: parsedDriver,
      driverPhone: mobileDriverPhone,
      driverRating: mobileDriverRating,
      driverPhoto: mobileDriverPhoto, // ✅ URL COMPLÈTE
      vehiclePlate: mobileVehiclePlate,
      vehiclePhoto: mobileVehiclePhoto, // ✅ URL COMPLÈTE
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
      'driver': driver?.toJson(),
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
    List<PassengerModel>? passengers,
    List<SchoolModel>? schools,
    DateTime? startedAt,
    DateTime? completedAt,
    String? cancelReason,
    DriverModel? driver,
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
      driver: driver ?? this.driver,
    );
  }
}