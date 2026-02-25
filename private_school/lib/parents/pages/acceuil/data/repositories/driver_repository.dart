import '../models/driver_model.dart';

class DriverRepository {
  Future<List<DriverModel>> getDrivers() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      DriverModel(
        name: 'Birima Diop',
        plate: 'AA-1234-AB',
        rating: '4.8',
        driverImg: '1.png',
        busImg: '3.jpg',
        departure: '123 Avenue des Champs-Élysées',
        departureTime: '06:30',
        arrival: 'Pikine',
        arrivalTime: '08:30',
        schools: '2',
        children: '3',
        total: '4',
      ),
      DriverModel(
        name: 'Alima Sow',
        plate: 'BB-5678-CD',
        rating: '4.9',
        driverImg: '1.png',
        busImg: '3.jpg',
        departure: 'Sacré Coeur',
        departureTime: '07:00',
        arrival: 'Notre Dame',
        arrivalTime: '10:30',
        schools: '2',
        children: '5',
        total: '6',
      ),
      DriverModel(
        name: 'Moussa Kane',
        plate: 'CC-9012-EF',
        rating: '4.7',
        driverImg: '1.png',
        busImg: '3.jpg',
        departure: 'Ouakam',
        departureTime: '06:45',
        arrival: 'Yoff',
        arrivalTime: '07:30',
        schools: '2',
        children: '4',
        total: '8',
      ),
    ];
  }
}
