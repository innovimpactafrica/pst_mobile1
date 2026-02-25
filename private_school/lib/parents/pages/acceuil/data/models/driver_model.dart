class DriverModel {
  final String name;
  final String plate;
  final String rating;
  final String driverImg;
  final String busImg;
  final String departure;
  final String departureTime;
  final String arrival;
  final String arrivalTime;
  final String schools;
  final String children;
  final String total;

  DriverModel({
    required this.name,
    required this.plate,
    required this.rating,
    required this.driverImg,
    required this.busImg,
    required this.departure,
    required this.departureTime,
    required this.arrival,
    required this.arrivalTime,
    required this.schools,
    required this.children,
    required this.total,
  });

  factory DriverModel.fromJson(Map<String, dynamic> json) {
    return DriverModel(
      name: json['name'] ?? '',
      plate: json['plate'] ?? '',
      rating: json['rating'] ?? '',
      driverImg: json['driverImg'] ?? '',
      busImg: json['busImg'] ?? '',
      departure: json['departure'] ?? '',
      departureTime: json['departureTime'] ?? '',
      arrival: json['arrival'] ?? '',
      arrivalTime: json['arrivalTime'] ?? '',
      schools: json['schools'] ?? '',
      children: json['children'] ?? '',
      total: json['total'] ?? '',
    );
  }
}
