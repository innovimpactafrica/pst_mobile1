class ChildModel {
  final String id;
  final String firstName;
  final String lastName;
  final String fullAddress;
  final String school;
  final String initials;
  final Map<String, DaySchedule>? schedule;

  ChildModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.fullAddress,
    required this.school,
    required this.initials,
    this.schedule,
  });

  String get fullName => '$firstName $lastName';
  String get displayAddress => fullAddress;
  Map<String, DaySchedule> get safeSchedule {
    return schedule ?? {};
  }


  factory ChildModel.fromJson(Map<String, dynamic> json) {
    return ChildModel(
      id: json['id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      fullAddress: json['fullAddress'] ?? '',
      school: json['school'] ?? '',
      initials: json['initials'] ?? '',
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'fullAddress': fullAddress,
      'school': school,
      'initials': initials,
      'schedule': schedule?.map((key, value) => MapEntry(key, value.toJson())),
    };
  }

  ChildModel copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? fullAddress,
    String? school,
    String? initials,
    Map<String, DaySchedule>? schedule,
  }) {
    return ChildModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      fullAddress: fullAddress ?? this.fullAddress,
      school: school ?? this.school,
      initials: initials ?? this.initials,
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
      'startTime': startTime,
      'endTime': endTime,
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