

class ChildModel {
  // Champs API
  final String? id;
  final String name;
  final String address;
  final int schoolId;
  final String? schoolName; 
  final String? schoolAddress; 
  final String? birthDate;
  final String? grade;
  final int? parentId;
  final String? createdAt;
  

  final Map<String, DaySchedule>? schedule;

  ChildModel({
    this.id,
    required this.name,
    required this.address,
    required this.schoolId,
    this.schoolName, 
    this.schoolAddress, 
    this.birthDate,
    this.grade,
    this.parentId,
    this.createdAt,
    this.schedule,
  });

  // ========== GETTERS POUR COMPATIBILITÉ ==========
  
  String get firstName => name.split(' ').first;
  String get lastName => name.split(' ').length > 1 
      ? name.split(' ').sublist(1).join(' ') 
      : '';
  String get fullName => name;
  String get initials {
    final parts = name.split(' ');
    if (parts.isEmpty) return '';
    if (parts.length == 1) {
      return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '';
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
  String get displayAddress => address.isNotEmpty 
      ? address 
      : 'Adresse non renseignée';
  String get fullAddress => address;
  String? get homeAddress => address;
  
  // ✅ CORRIGÉ : Affiche le nom de l'école si disponible
  String get school => schoolName ?? 'École ID: $schoolId';
  
  Map<String, DaySchedule> get safeSchedule => schedule ?? {};

  // ========== CONVERSION JSON ==========
  
  factory ChildModel.fromJson(Map<String, dynamic> json) {
    // Parse schedule et gérer les doublons
    Map<String, DaySchedule>? parsedSchedule;
    
    if (json['schedule'] != null) {
      if (json['schedule'] is List) {
        // Format API: Liste de jours
        final List<dynamic> scheduleList = json['schedule'];
        parsedSchedule = {};
        
        // Mapping des jours complets vers abrégés (pour l'affichage)
        final Map<String, String> dayMapping = {
          'Lundi': 'Lun.',
          'Mardi': 'Mar',
          'Mercredi': 'Mer.',
          'Jeudi': 'Jeu',
          'Vendredi': 'Ven.',
          'Samedi': 'Sam.',
          'Dimanche': 'Dim.',
          'monday': 'Lun.',
          'tuesday': 'Mar',
          'wednesday': 'Mer.',
          'thursday': 'Jeu',
          'friday': 'Ven.',
          'saturday': 'Sam.',
          'sunday': 'Dim.',
        };
        
        // Parcourir la liste et ne garder que le DERNIER horaire de chaque jour
        for (var dayData in scheduleList) {
          final day = dayData['day'] as String;
          final normalizedDay = dayMapping[day] ?? day;
          
          parsedSchedule[normalizedDay] = DaySchedule(
            isOpen: dayData['open'] ?? false,
            startTime: dayData['openTime'],
            endTime: dayData['closeTime'],
          );
        }
      } else if (json['schedule'] is Map) {
        // Format local: Map de jours
        parsedSchedule = (json['schedule'] as Map<String, dynamic>).map(
          (key, value) => MapEntry(
            key,
            DaySchedule.fromJson(value as Map<String, dynamic>),
          ),
        );
      }
    }

    return ChildModel(
      id: json['_id']?.toString() ?? json['id']?.toString(),
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      schoolId: json['school_id'] is int 
          ? json['school_id'] 
          : int.tryParse(json['school_id']?.toString() ?? '0') ?? 0,
      schoolName: json['school_name'], // ✅ AJOUTÉ : Récupère le nom de l'école
      schoolAddress: json['school_address'], // ✅ AJOUTÉ : Récupère l'adresse de l'école
      birthDate: json['birth_date'],
      grade: json['grade'],
      parentId: json['parent_id'],
      createdAt: json['created_at'],
      schedule: parsedSchedule,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'name': name,
      'address': address,
      'school_id': schoolId,
    };

    if (birthDate != null && birthDate!.isNotEmpty) {
      data['birth_date'] = birthDate;
    }
    if (grade != null && grade!.isNotEmpty) {
      data['grade'] = grade;
    }
    
    // Ne pas inclure l'ID lors de la création
    if (id != null && id!.isNotEmpty) {
      data['id'] = id;
    }
    
    return data;
  }

  ChildModel copyWith({
    String? id,
    String? name,
    String? address,
    int? schoolId,
    String? schoolName, // ✅ AJOUTÉ
    String? schoolAddress, // ✅ AJOUTÉ
    String? birthDate,
    String? grade,
    int? parentId,
    String? createdAt,
    Map<String, DaySchedule>? schedule,
  }) {
    return ChildModel(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      schoolId: schoolId ?? this.schoolId,
      schoolName: schoolName ?? this.schoolName, // ✅ AJOUTÉ
      schoolAddress: schoolAddress ?? this.schoolAddress, // ✅ AJOUTÉ
      birthDate: birthDate ?? this.birthDate,
      grade: grade ?? this.grade,
      parentId: parentId ?? this.parentId,
      createdAt: createdAt ?? this.createdAt,
      schedule: schedule ?? this.schedule,
    );
  }

  factory ChildModel.fromLegacyFields({
    String? id,
    required String firstName,
    required String lastName,
    required String homeAddress,
    required int schoolId,
    String? schoolName, // ✅ AJOUTÉ
    String? schoolAddress, // ✅ AJOUTÉ
    String? birthDate,
    String? grade,
    Map<String, DaySchedule>? schedule,
  }) {
    return ChildModel(
      id: id,
      name: '$firstName $lastName',
      address: homeAddress,
      schoolId: schoolId,
      schoolName: schoolName, // ✅ AJOUTÉ
      schoolAddress: schoolAddress, // ✅ AJOUTÉ
      birthDate: birthDate,
      grade: grade,
      schedule: schedule,
    );
  }

  bool isValid() {
    return name.isNotEmpty &&
           address.isNotEmpty &&
           schoolId > 0;
  }

  @override
  String toString() {
    return 'ChildModel(id: $id, name: $name, address: $address, '
           'schoolId: $schoolId, schoolName: $schoolName, birthDate: $birthDate, grade: $grade)';
  }
}

class DaySchedule {
  final bool isOpen;
  final String? startTime;
  final String? endTime;

  DaySchedule({
    required this.isOpen,
    this.startTime,
    this.endTime,
  });

  factory DaySchedule.fromJson(Map<String, dynamic> json) {
    return DaySchedule(
      isOpen: json['isOpen'] ?? json['open'] ?? false,
      startTime: json['startTime'] ?? json['openTime'],
      endTime: json['endTime'] ?? json['closeTime'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isOpen': isOpen,
      if (startTime != null) 'startTime': startTime,
      if (endTime != null) 'endTime': endTime,
    };
  }

  DaySchedule copyWith({
    bool? isOpen,
    String? startTime,
    String? endTime,
  }) {
    return DaySchedule(
      isOpen: isOpen ?? this.isOpen,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }

  @override
  String toString() {
    return 'DaySchedule(isOpen: $isOpen, startTime: $startTime, endTime: $endTime)';
  }
}