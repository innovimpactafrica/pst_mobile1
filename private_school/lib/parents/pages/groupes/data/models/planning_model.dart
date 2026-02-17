// ✅ AJOUTEZ ce champ dans votre modèle Planning (group_model.dart)

class Planning {
  final String id;
  final String groupId;
  final DateTime date;
  final String? driverId;
  final String? driverName;
  final String? driverPhone;
  final String? driverEmail;
  final bool? isMyTurn;
  final String status;
  final String? replacementReason;
  final String? startPoint;
  final String? endPoint;
  final String? departureTime;
  final String? returnTime;
  final int? capacityMax;
  final String? notes;
  final String? replacementAcceptedBy;
  final String? replacementAcceptedByName;

  Planning({
    required this.id,
    required this.groupId,
    required this.date,
    this.driverId,
    this.driverName,
    this.driverPhone,
    this.driverEmail,
    this.isMyTurn,
    required this.status,
    this.replacementReason,
    this.startPoint,
    this.endPoint,
    this.departureTime,
    this.returnTime,
    this.capacityMax,
    this.notes,
    this.replacementAcceptedBy,
    this.replacementAcceptedByName,
  });

  factory Planning.fromJson(Map<String, dynamic> json) {
    return Planning(
      id: json['id']?.toString() ?? '',
      groupId: json['group_id']?.toString() ?? '',
      date: json['date'] != null
          ? DateTime.tryParse(json['date']) ?? DateTime.now()
          : DateTime.now(),
      driverId: json['driver_id']?.toString(),
      driverName: json['driver_name'],
      driverPhone: json['driver_phone'],
      driverEmail: json['driver_email'],
      isMyTurn: json['is_my_turn'],
      status: json['status'] ?? 'scheduled',
      replacementReason: json['replacement_reason'],
      startPoint: json['start_point'],
      endPoint: json['end_point'],
      departureTime: json['departure_time'],
      returnTime: json['return_time'],
      capacityMax: json['capacity_max'],
      notes: json['notes'],
      replacementAcceptedBy: json['replacement_accepted_by']?.toString(),
      replacementAcceptedByName: json['replacement_accepted_by_name'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'group_id': groupId,
    'date': date.toIso8601String(),
    'driver_id': driverId,
    'driver_name': driverName,
    'driver_phone': driverPhone,
    'driver_email': driverEmail,
    'is_my_turn': isMyTurn,
    'status': status,
    'replacement_reason': replacementReason,
    'start_point': startPoint,
    'end_point': endPoint,
    'departure_time': departureTime,
    'return_time': returnTime,
    'capacity_max': capacityMax,
    'notes': notes,
    'replacement_accepted_by': replacementAcceptedBy,
    'replacement_accepted_by_name': replacementAcceptedByName,
  };

  bool get isConfirmed => status == 'confirmed';
  bool get isPending => status == 'scheduled' || status == 'pending';
  bool get needsReplacement => status == 'replacement_requested';
  bool get isReplacementAccepted => status == 'replacement_accepted';
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }
  
  String get assignedTo {
    if (isMyTurn == true) return 'Vous';
    if (driverName != null && driverName!.isNotEmpty) return driverName!;
    return 'Non assigné';
  }

  Planning copyWith({
    String? id,
    String? groupId,
    DateTime? date,
    String? driverId,
    String? driverName,
    String? driverPhone,
    String? driverEmail,
    bool? isMyTurn,
    String? status,
    String? replacementReason,
    String? startPoint,
    String? endPoint,
    String? departureTime,
    String? returnTime,
    int? capacityMax,
    String? notes,
    String? replacementAcceptedBy,
    String? replacementAcceptedByName,
  }) {
    return Planning(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      date: date ?? this.date,
      driverId: driverId ?? this.driverId,
      driverName: driverName ?? this.driverName,
      driverPhone: driverPhone ?? this.driverPhone,
      driverEmail: driverEmail ?? this.driverEmail,
      isMyTurn: isMyTurn ?? this.isMyTurn,
      status: status ?? this.status,
      replacementReason: replacementReason ?? this.replacementReason,
      startPoint: startPoint ?? this.startPoint,
      endPoint: endPoint ?? this.endPoint,
      departureTime: departureTime ?? this.departureTime,
      returnTime: returnTime ?? this.returnTime,
      capacityMax: capacityMax ?? this.capacityMax,
      notes: notes ?? this.notes,
      replacementAcceptedBy: replacementAcceptedBy ?? this.replacementAcceptedBy,
      replacementAcceptedByName: replacementAcceptedByName ?? this.replacementAcceptedByName,
    );
  }
}