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

  final String? driverName;
  final String? driverPhone;
  final int? driverRating;
  final String? driverPhoto;
  final String? vehiclePlate;
  final String? vehiclePhoto;
  final int? schoolCount;

  // GPS coordinates
  final double? currentLatitude;
  final double? currentLongitude;

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
    this.driverName,
    this.driverPhone,
    this.driverRating,
    this.driverPhoto,
    this.vehiclePlate,
    this.vehiclePhoto,
    this.schoolCount,
    this.currentLatitude,
    this.currentLongitude,
  });

  // ========== GETTERS ==========

  bool get isActive =>
      status == 'active' || status == 'started' || status == 'in_progress';
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
      //
    }
    return time;
  }

  String get duration => '1h 00min';
  String get driverNameDisplay =>
      driver?.fullName ?? driverName ?? 'Chauffeur non assigné';
  String get driverImg => driver?.photo ?? driverPhoto ?? '';

  //  Rating réel du chauffeur
  double get driverRatingValue =>
      driver?.rating ?? driverRating?.toDouble() ?? 0.0;
  String get driverRatingDisplay =>
      driverRatingValue > 0 ? driverRatingValue.toStringAsFixed(1) : 'N/A';

  String get formattedDate =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  bool get hasDriverPhoto =>
      (driver?.photo != null && driver!.photo!.isNotEmpty) ||
      (driverPhoto != null && driverPhoto!.isNotEmpty);
  String get driverPhotoUrl => driver?.photo ?? driverPhoto ?? '';

  bool get hasVehiclePhoto =>
      (driver?.vehicle?.photo != null && driver!.vehicle!.photo!.isNotEmpty) ||
      (vehiclePhoto != null && vehiclePhoto!.isNotEmpty);
  String get vehiclePhotoUrl => driver?.vehicle?.photo ?? vehiclePhoto ?? '';

  factory TripModel.fromJson(Map<String, dynamic> json) {
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint(' [TripModel] JSON REÇU DE L\'API:');
    debugPrint(json.toString());
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    debugPrint('[TripModel] CHAMPS ÉCOLES DANS LE JSON:');
    debugPrint('   stops: ${json['stops']}');
    debugPrint('   stops type: ${json['stops'].runtimeType}');
    if (json['stops'] is List) {
      debugPrint('   stops length: ${(json['stops'] as List).length}');
      for (var i = 0; i < (json['stops'] as List).length; i++) {
        final stop = (json['stops'] as List)[i];
        debugPrint('   stops[$i]: $stop');
      }
    }
    debugPrint('   schools: ${json['schools']}');
    debugPrint('   school_id: ${json['school_id']}');
    debugPrint('   school_name: ${json['school_name']}');
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
    final timeStr =
        '${departureDateTime.hour.toString().padLeft(2, '0')}:${departureDateTime.minute.toString().padLeft(2, '0')}';

    debugPrint(' [TripModel] CAPACITÉ:');
    debugPrint('   capacity_max brut: ${json['capacity_max']}');
    debugPrint('   totalSeats brut: ${json['totalSeats']}');
    debugPrint('   Type capacity_max: ${json['capacity_max'].runtimeType}');

    final capacityMax = safeInt(
      json['capacity_max'] ?? json['totalSeats'] ?? 0,
    );
    debugPrint('    Capacité finale: $capacityMax');

    debugPrint(' [TripModel] PASSAGERS:');
    debugPrint('   passengers brut: ${json['passengers']}');
    debugPrint('   Type passengers: ${json['passengers'].runtimeType}');

    List<PassengerModel> parsedPassengers = [];
    if (json['passengers'] != null && json['passengers'] is List) {
      parsedPassengers = (json['passengers'] as List)
          .map((p) => PassengerModel.fromJson(p as Map<String, dynamic>))
          .toList();
      debugPrint('    Nombre de passagers parsés: ${parsedPassengers.length}');
    } else if (json['passengers'] != null && json['passengers'] is int) {
      debugPrint('    passengers est un nombre: ${json['passengers']}');
    } else {
      debugPrint('    passengers est null ou type inconnu');
    }

    DriverModel? parsedDriver;
    String? extractedUserId;
    if (json['driver'] != null && json['driver'] is Map) {
      try {
        parsedDriver = DriverModel.fromJson(
          json['driver'] as Map<String, dynamic>,
        );

        extractedUserId = json['driver']['user_id']?.toString();
        debugPrint(' user_id extrait du driver: $extractedUserId');
      } catch (e) {
        debugPrint(' Erreur parsing driver: $e');
      }
    }

    const String baseUrl = "http://86.106.181.31:3000";

    String? mobileDriverName;
    String? mobileDriverPhone;
    int? mobileDriverRating;
    String? mobileDriverPhoto;
    String? mobileVehiclePlate;
    String? mobileVehiclePhoto;

    if (parsedDriver != null) {
      mobileDriverName = parsedDriver.fullName;
      mobileDriverPhone = parsedDriver.phone;
      mobileDriverRating = parsedDriver.rating.toInt();
      mobileDriverPhoto = parsedDriver.photo;
      mobileVehiclePlate = parsedDriver.vehicle?.plate;
      mobileVehiclePhoto = parsedDriver.vehicle?.photo;

      if (json['driver']['documents'] != null &&
          json['driver']['documents']['vehicle_photo'] != null) {
        String? docVehiclePhoto = json['driver']['documents']['vehicle_photo']
            ?.toString();
        if (docVehiclePhoto != null && docVehiclePhoto.isNotEmpty) {
          if (!docVehiclePhoto.startsWith('http')) {
            mobileVehiclePhoto = '$baseUrl$docVehiclePhoto';
          } else {
            mobileVehiclePhoto = docVehiclePhoto;
          }
        }
      }
    } else {
      mobileDriverName = json['driver_name']?.toString();
      mobileDriverPhone = json['driver_phone']?.toString();
      mobileDriverRating = json['driver_rating'] is int
          ? json['driver_rating']
          : (json['driver_rating'] is String
                ? int.tryParse(json['driver_rating'])
                : null);

      mobileDriverPhoto = json['driver_photo']?.toString();
      if (mobileDriverPhoto != null && mobileDriverPhoto.isNotEmpty) {
        if (!mobileDriverPhoto.startsWith('http')) {
          mobileDriverPhoto = '$baseUrl$mobileDriverPhoto';
        }
      }

      mobileVehiclePlate = json['vehicle_plate']?.toString();

      mobileVehiclePhoto = json['vehicle_photo']?.toString();
      if (mobileVehiclePhoto != null && mobileVehiclePhoto.isNotEmpty) {
        if (!mobileVehiclePhoto.startsWith('http')) {
          mobileVehiclePhoto = '$baseUrl$mobileVehiclePhoto';
        }
      }
    }

    if (parsedDriver == null && mobileDriverName != null) {
      final nameParts = mobileDriverName.split(RegExp(r'\s+'));
      parsedDriver = DriverModel(
        id: json['driver_id']?.toString() ?? '',
        firstName: nameParts.isNotEmpty ? nameParts.first : mobileDriverName,
        lastName: nameParts.length > 1 ? nameParts.skip(1).join(' ') : '',
        email: '',
        phone: mobileDriverPhone ?? '',
        photo: mobileDriverPhoto,
      );
    }

    List<SchoolModel> parsedSchools = [];
    int schoolCountValue = 0;

    if (json['stops'] != null &&
        json['stops'] is List &&
        (json['stops'] as List).isNotEmpty) {
      parsedSchools = (json['stops'] as List).map((stop) {
        final s = stop as Map<String, dynamic>;
        return SchoolModel(
          id: s['school_id'] is int
              ? s['school_id']
              : int.tryParse(s['school_id'].toString()),
          name: (s['school_name'] ?? 'École').toString(),
          address: (s['school_address'] ?? '').toString(),
        );
      }).toList();
      schoolCountValue = parsedSchools.length;
      debugPrint('✅ ${parsedSchools.length} école(s) parsée(s) depuis stops');
      for (var school in parsedSchools) {
        debugPrint('   🏫 ${school.name} (ID: ${school.id})');
      }
    } else if (json['schools'] != null &&
        json['schools'] is List &&
        (json['schools'] as List).isNotEmpty) {
      parsedSchools = (json['schools'] as List)
          .map((s) => SchoolModel.fromJson(s as Map<String, dynamic>))
          .toList();
      schoolCountValue = parsedSchools.length;
      debugPrint(' ${parsedSchools.length} école(s) parsée(s) depuis schools');
    } else if (json['school_id'] != null) {
      final schoolId = json['school_id'];
      parsedSchools = [
        SchoolModel(
          id: schoolId is int ? schoolId : int.tryParse(schoolId.toString()),
          name: (json['school_name'] ?? json['end_point'] ?? 'École')
              .toString(),
          address: (json['school_address'] ?? '').toString(),
        ),
      ];
      schoolCountValue = 1;
      debugPrint('✅ 1 école parsée depuis school_id unique');
    } else if (parsedPassengers.isNotEmpty) {
      final schoolIds = <int>{};
      for (var passenger in parsedPassengers) {
        if (passenger.schoolId != null) {
          schoolIds.add(passenger.schoolId!);
        }
      }
      if (schoolIds.isNotEmpty) {
        schoolCountValue = schoolIds.length;
        debugPrint(
          ' ${schoolIds.length} école(s) extraite(s) des passagers (noms non disponibles): $schoolIds',
        );
        for (var schoolId in schoolIds) {
          parsedSchools.add(
            SchoolModel(id: schoolId, name: 'École #$schoolId', address: ''),
          );
        }
      }
    }

    debugPrint('');
    debugPrint(' [TripModel] RÉSUMÉ PARSING:');
    debugPrint('   ID: ${json['id']?.toString() ?? json['_id']?.toString()}');
    debugPrint('   Destination: ${json['end_point'] ?? json['destination']}');
    debugPrint('   Total Seats: $capacityMax');
    debugPrint('   Passagers: ${parsedPassengers.length}');
    debugPrint('    Écoles parsées: ${parsedSchools.length}');
    for (var i = 0; i < parsedSchools.length; i++) {
      debugPrint(
        '      [$i] ${parsedSchools[i].name} (ID: ${parsedSchools[i].id})',
      );
    }
    debugPrint('   School Count: $schoolCountValue');
    debugPrint('   Status: ${json['status']}');
    debugPrint('   Photo chauffeur: $mobileDriverPhoto');
    debugPrint('   Photo véhicule: $mobileVehiclePhoto');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    return TripModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      driverId: json['driver_id']?.toString() ?? json['driverId']?.toString(),
      destination:
          json['end_point']?.toString() ??
          json['destination']?.toString() ??
          '',
      startLocation:
          json['start_point']?.toString() ?? json['lieuDepart']?.toString(),
      date: departureDateTime,
      time: timeStr,
      totalSeats: capacityMax,
      availableSeats: safeInt(
        json['placesDisponibles'] ?? json['capacity_max'] ?? 0,
      ),
      price: json['price'] != null ? (json['price'] as num).toDouble() : null,
      status: json['status']?.toString().toLowerCase() ?? 'pending',
      passengers: parsedPassengers,
      schools: parsedSchools,
      startedAt: json['startedAt'] != null
          ? parseDate(json['startedAt'])
          : null,
      completedAt: json['completedAt'] != null
          ? parseDate(json['completedAt'])
          : null,
      cancelReason: json['cancelReason']?.toString(),
      driver: parsedDriver,
      driverName: mobileDriverName,
      driverPhone: mobileDriverPhone,
      driverRating: mobileDriverRating,
      driverPhoto: mobileDriverPhoto,
      vehiclePlate: mobileVehiclePlate,
      vehiclePhoto: mobileVehiclePhoto,
      schoolCount: schoolCountValue,
      currentLatitude: json['current_latitude'] != null
          ? (json['current_latitude'] as num).toDouble()
          : null,
      currentLongitude: json['current_longitude'] != null
          ? (json['current_longitude'] as num).toDouble()
          : null,
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
