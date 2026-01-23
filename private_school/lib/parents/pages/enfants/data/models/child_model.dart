class ChildModel {
  final String? id;
  final String firstName;
  final String lastName;
  final String? schoolName;
  final String? schoolAddress;
  final String? homeAddress;
  final Map<String, DaySchedule>? schedule;

  ChildModel({
    this.id,
    required this.firstName,
    required this.lastName,
    this.schoolName,
    this.schoolAddress,
    this.homeAddress,
    this.schedule,
  });

  // Getters utiles pour l'affichage
  String get fullName => '$firstName $lastName';

  String get initials {
    return '${firstName.isNotEmpty ? firstName[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}'.toUpperCase();
  }

  String get displayAddress => homeAddress ?? 'Adresse non renseignée';

  String get school => schoolName ?? 'École non renseignée';

  String get fullAddress => homeAddress ?? '';

  Map<String, DaySchedule> get safeSchedule {
    return schedule ?? {};
  }

  /// Conversion depuis JSON (réponse API)
  factory ChildModel.fromJson(Map<String, dynamic> json) {
    return ChildModel(
      id: json['_id'] ?? json['id'],
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      schoolName: json['schoolName'],
      schoolAddress: json['schoolAddress'],
      homeAddress: json['homeAddress'],
      schedule: json['schedule'] != null
          ? (json['schedule'] as Map<String, dynamic>).map(
            (key, value) => MapEntry(
          key,
          DaySchedule.fromJson(value as Map<String, dynamic>),
        ),
      )
          : null,
    );
  }

  /// Conversion vers JSON (envoi API)
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'firstName': firstName,
      'lastName': lastName,
    };

    if (id != null) data['_id'] = id;
    if (schoolName != null) data['schoolName'] = schoolName;
    if (schoolAddress != null) data['schoolAddress'] = schoolAddress;
    if (homeAddress != null) data['homeAddress'] = homeAddress;
    if (schedule != null) {
      data['schedule'] = schedule!.map((key, value) => MapEntry(key, value.toJson()));
    }

    return data;
  }

  /// Méthode copyWith pour créer une copie modifiée
  ChildModel copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? schoolName,
    String? schoolAddress,
    String? homeAddress,
    Map<String, DaySchedule>? schedule,
  }) {
    return ChildModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      schoolName: schoolName ?? this.schoolName,
      schoolAddress: schoolAddress ?? this.schoolAddress,
      homeAddress: homeAddress ?? this.homeAddress,
      schedule: schedule ?? this.schedule,
    );
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
      isOpen: json['isOpen'] ?? false,
      startTime: json['startTime'],
      endTime: json['endTime'],
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
}