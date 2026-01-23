import 'driver_model.dart';
import 'passenger_model.dart';
import 'school_model.dart';

class TripModel {
  final String id;
  final String departure;
  final String departureTime;
  final String arrival;
  final String arrivalTime;
  final String status; // "En attente", "Accepté", "En cours", etc.
  final String date; // "Lun. 12 oct. 2025"
  final String duration; // "20min"

  // Relations avec d'autres entités
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

  // Propriétés dérivées pour compatibilité avec l'ancien code
  String get driverName => driver?.name ?? '';
  String get plate => driver?.vehicle?.plate ?? '';
  String get rating => driver?.rating.toString() ?? '0.0';
  String get driverImg => driver?.photo ?? '';
  String get busImg => driver?.vehicle?.photo ?? '';
  String get schoolsCount => schools.length.toString();
  String get children => passengers.length.toString();
  String get total => driver?.vehicle?.capacity.toString() ?? '0';
  String get passengersText => '${passengers.length.toString().padLeft(2, '0')} passagers';
  int get numberOfSchools => schools.length;
  List<String> get schoolNames => schools.map((s) => s.name).toList();

  factory TripModel.fromJson(Map<String, dynamic> json) {
    return TripModel(
      id: json['id'] ?? '',
      departure: json['departure'] ?? '',
      departureTime: json['departureTime'] ?? '',
      arrival: json['arrival'] ?? '',
      arrivalTime: json['arrivalTime'] ?? '',
      status: json['status'] ?? 'En attente',
      date: json['date'] ?? '',
      duration: json['duration'] ?? '',
      driver: json['driver'] != null
          ? DriverModel.fromJson(json['driver'])
          : null,
      passengers: json['passengers'] != null
          ? (json['passengers'] as List)
          .map((p) => PassengerModel.fromJson(p))
          .toList()
          : [],
      schools: json['schools'] != null
          ? (json['schools'] as List)
          .map((s) => SchoolModel.fromJson(s))
          .toList()
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