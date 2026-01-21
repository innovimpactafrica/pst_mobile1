import '../models/trip_model.dart';
import '../models/driver_model.dart';
import '../models/passenger_model.dart';
import '../models/school_model.dart';

class TripRepository {
  // Récupère tous les trajets (disponibles + réservations)
  Future<List<TripModel>> getAllTrips() async {
    await Future.delayed(const Duration(milliseconds: 500));

    return [
      TripModel(
        id: '1',
        departure: '123 Avenue des Champs-Élysées',
        departureTime: '06:30',
        arrival: 'Ouakam',
        arrivalTime: '07:30',
        status: 'En attente',
        date: 'Lun. 12 oct. 2025',
        duration: '20min',
        driver: DriverModel(
          id: 'driver1',
          name: 'Birima Diop',
          photo: '1.png',
          memberSince: 'Membre depuis 2022',
          phone: '+221 77 123 45 67',
          rating: 4.8,
          totalReviews: 129,
          totalTrips: 245,
          successRate: 98.0,
          vehicle: VehicleModel(
            id: 'vehicle1',
            model: 'SELOV SERIE SA',
            plate: 'AA-1234-56',
            color: 'Blanche',
            photo: '3.jpg',
            capacity: 32,
          ),
        ),
        passengers: [
          PassengerModel(
            id: 'pass1',
            name: 'Maman Ndiaye',
            initials: 'MN',
            school: 'École Primaire Saint-Michel',
            avatarColor: '#4CAF50',
          ),
          PassengerModel(
            id: 'pass2',
            name: 'Moussa Fall',
            initials: 'MF',
            school: 'École Primaire Saint-Michel',
            avatarColor: '#4CAF50',
          ),
          PassengerModel(
            id: 'pass3',
            name: 'Aïssatou Diop',
            initials: 'AD',
            school: 'École Maternelle Les Petits Loups',
            avatarColor: '#2196F3',
          ),
        ],
        schools: [
          SchoolModel(
            id: 'school1',
            name: 'École Maternelle Les Petits Loups',
            icon: 'school1.png',
            numberOfStudents: '2 élèves',
            address: 'Rue de la Paix, Ouakam',
          ),
          SchoolModel(
            id: 'school2',
            name: 'École Primaire Saint-Michel',
            icon: 'school2.png',
            numberOfStudents: '1 élève',
            address: 'Avenue Bourguiba, Dakar',
          ),
        ],
      ),
      TripModel(
        id: '2',
        departure: 'Pikine',
        departureTime: '06:30',
        arrival: 'Notre Dame',
        arrivalTime: '07:30',
        status: 'Accepté',
        date: 'Mar. 13 oct. 2025',
        duration: '25min',
        driver: DriverModel(
          id: 'driver2',
          name: 'Alima Fall',
          photo: '2.png',
          memberSince: 'Membre depuis 2021',
          phone: '+221 77 987 65 43',
          rating: 4.7,
          totalReviews: 98,
          totalTrips: 189,
          successRate: 96.5,
          vehicle: VehicleModel(
            id: 'vehicle2',
            model: 'MERCEDES SPRINTER',
            plate: 'BB-5678-AA',
            color: 'Grise',
            photo: '4.jpg',
            capacity: 28,
          ),
        ),
        passengers: [
          PassengerModel(
            id: 'pass4',
            name: 'Fatou Sarr',
            initials: 'FS',
            school: 'Institution Notre Dame',
            avatarColor: '#FF9800',
          ),
          PassengerModel(
            id: 'pass5',
            name: 'Ibrahima Ndiaye',
            initials: 'IN',
            school: 'École Sainte Marie',
            avatarColor: '#9C27B0',
          ),
        ],
        schools: [
          SchoolModel(
            id: 'school3',
            name: 'Institution Notre Dame',
            icon: 'school3.png',
            numberOfStudents: '1 élève',
            address: 'Boulevard du Général de Gaulle',
          ),
          SchoolModel(
            id: 'school4',
            name: 'École Sainte Marie',
            icon: 'school4.png',
            numberOfStudents: '1 élève',
            address: 'Rue Carnot, Dakar',
          ),
        ],
      ),

    TripModel(
    id: '3',
    departure: 'Sacré Coeur',
    departureTime: '07:00',
    arrival: 'Yoff',
    arrivalTime: '08:00',
    status: 'En attente',
    date: 'Mer. 14 oct. 2025',
    duration: '18min',
    driver: DriverModel(
    id: 'driver3',
    name: 'Moussa Kane',
    photo: 'imchauff1.png',  // ← Changez selon vos images
    memberSince: 'Membre depuis 2023',
    phone: '+221 77 555 44 33',
    rating: 4.9,
    totalReviews: 156,
    totalTrips: 312,
    successRate: 99.0,
    vehicle: VehicleModel(
    id: 'vehicle3',
    model: 'FORD TRANSIT',
    plate: 'CC-9012-EF',
    color: 'Blanche',
    photo: 'bus.jpg',  // ← Changez selon vos images
    capacity: 24,
    ),
    ),
    passengers: [
    PassengerModel(
    id: 'pass6',
    name: 'Aminata Diallo',
    initials: 'AD',
    school: 'École Franco-Sénégalaise',
    avatarColor: '#E91E63',
    ),
    PassengerModel(
    id: 'pass7',
    name: 'Cheikh Sy',
    initials: 'CS',
    school: 'École Franco-Sénégalaise',
    avatarColor: '#E91E63',
    ),
    PassengerModel(
    id: 'pass8',
    name: 'Coumba Gueye',
    initials: 'CG',
    school: 'Lycée Moderne',
    avatarColor: '#00BCD4',
    ),
    ],
    schools: [
    SchoolModel(
    id: 'school5',
    name: 'École Franco-Sénégalaise',
    icon: 'school1.png',
    numberOfStudents: '2 élèves',
    address: 'Route de Yoff, Dakar',
    ),
    SchoolModel(
    id: 'school6',
    name: 'Lycée Moderne',
    icon: 'school2.png',
    numberOfStudents: '1 élève',
    address: 'Rue de Thiès, Yoff',
    ),
    ],
    ),

    ];
  }

  // Récupère uniquement les trajets disponibles
  Future<List<TripModel>> getAvailableTrips() async {
    final allTrips = await getAllTrips();
    return allTrips.where((trip) => trip.status == 'En attente').toList();
  }

  // Récupère uniquement les réservations
  Future<List<TripModel>> getMyReservations() async {
    final allTrips = await getAllTrips();
    return allTrips.where((trip) => trip.status == 'Accepté').toList();
  }

  // Récupère un trajet par son ID
  Future<TripModel?> getTripById(String id) async {
    final allTrips = await getAllTrips();
    try {
      return allTrips.firstWhere((trip) => trip.id == id);
    } catch (e) {
      return null;
    }
  }
}