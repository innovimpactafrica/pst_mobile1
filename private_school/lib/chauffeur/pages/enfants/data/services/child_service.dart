import '../models/child_model.dart';

class ChildService {
  // TODO: Remplacer par de vrais appels API plus tard

  Future<List<ChildModel>> fetchChildren() async {
    // Simuler un délai réseau
    await Future.delayed(const Duration(milliseconds: 500));

    // Données mockées pour l'instant
    return [
      ChildModel(
        id: '1',
        firstName: 'Mama',
        lastName: 'Ndiaye',
        fullAddress: 'École Primaire Saint Michel',
        school: 'Lycée jean mermoz',
        initials: 'MN',
        schedule: {
          'Lun': DaySchedule(isOpen: true, startTime: '08:00', endTime: '18:00'),
          'Mar': DaySchedule(isOpen: true, startTime: '08:00', endTime: '18:00'),
          'Mer': DaySchedule(isOpen: true, startTime: '08:00', endTime: '18:00'),
          'Jeu': DaySchedule(isOpen: true, startTime: '08:00', endTime: '18:00'),
          'Ven': DaySchedule(isOpen: true, startTime: '08:00', endTime: '17:30'),
          'Sam': DaySchedule(isOpen: false),
          'Dim': DaySchedule(isOpen: false),
        },
      ),
      ChildModel(
        id: '2',
        firstName: 'Moussa',
        lastName: 'Fall',
        fullAddress: 'École Primaire Saint Michel',
        school: 'Lycée jean mermoz',
        initials: 'MF',
      ),
      ChildModel(
        id: '3',
        firstName: 'Alissatou',
        lastName: 'Diop',
        fullAddress: 'École Primaire Saint Michel',
        school: 'Lycée jean mermoz',
        initials: 'AD',
      ),
    ];
  }

  Future<ChildModel> createChild(ChildModel child) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // TODO: Appel API pour créer l'enfant
    return child;
  }

  Future<ChildModel> updateChild(ChildModel child) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // TODO: Appel API pour modifier l'enfant
    return child;
  }

  Future<void> deleteChild(String childId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // TODO: Appel API pour supprimer l'enfant
  }
}