import 'package:private_school/chauffeurs/pages/authentification/data/models/driver_model.dart';
import 'package:private_school/parents/pages/school/data/models/school_model.dart';
import 'passenger_model.dart';

class TripModel {
  final String id;
  final String departure;
  final String departureTime;
  final String arrival;
  final String arrivalTime;
  final String status;
  final String date;
  final String duration;

  // Relations
  final DriverModel? driver;
  final List<PassengerModel> passengers;
  final List<SchoolModel> schools;

  TripModel({
    required this.id,
    required this.departure,
    required this.departureTime,
    required this.arrival,
    required this.arrivalTime,
    required this.status,
    this.date = '',
    this.duration = '',
    this.driver,
    this.passengers = const [],
    this.schools = const [],
  });

  // 🔁 Compatibilité ancien code
  String get driverName => driver?.fullName ?? '';
  String get plate => driver?.licenseNumber ?? '';
  String get rating => '4.5'; // Rating non disponible dans le modèle actuel
  String get driverImg => driver?.photo ?? '';
  String get busImg => ''; // Photo du véhicule non disponible
  String get schoolsCount => schools.length.toString();
  String get children => passengers.length.toString();
  String get total => '0'; // Capacité non disponible dans le modèle actuel
  String get passengersText =>
      '${passengers.length.toString().padLeft(2, '0')} passagers';
  int get numberOfSchools => schools.length;
  List<String> get schoolNames => schools.map((s) => s.name).toList();

  factory TripModel.fromJson(Map<String, dynamic> json) {
    final departureDateTime =
        DateTime.tryParse(json['departure_time'] ?? '');

    return TripModel(
      // ⚠️ API = int → String
      id: json['id']?.toString() ?? '',

      // API keys réelles
      departure: json['start_point'] ?? '',
      arrival: json['end_point'] ?? '',

      departureTime: departureDateTime != null
          ? '${departureDateTime.hour.toString().padLeft(2, '0')}:${departureDateTime.minute.toString().padLeft(2, '0')}'
          : '',

      arrivalTime: '',

      status: 'Disponible',

      date: departureDateTime != null
          ? '${departureDateTime.day}/${departureDateTime.month}/${departureDateTime.year}'
          : '',

      duration: '',

      driver: json['driver'] != null
          ? DriverModel.fromJson(json['driver'])
          : null,

      passengers: json['passengers'] != null
          ? (json['passengers'] as List)
              .map((p) => PassengerModel.fromJson(p))
              .toList()
          : [],

      schools: json['school_name'] != null
          ? [
              SchoolModel(
                id: null,
                name: json['school_name'],
                address: '',
              )
            ]
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'departure': departure,
      'departureTime': departureTime,
      'arrival': arrival,
      'arrivalTime': arrivalTime,
      'status': status,
      'date': date,
      'duration': duration,
      'driver': driver?.toJson(),
      'passengers': passengers.map((p) => p.toJson()).toList(),
      'schools': schools.map((s) => s.toJson()).toList(),
    };
  }
}
