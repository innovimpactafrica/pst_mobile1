class Planning {
  final String id;
  final DateTime date;
  final String assignedTo;
  final bool isConfirmed;
  final bool isPending;
  final bool needsReplacement;
  final String? replacementReason;

  Planning({
    required this.id,
    required this.date,
    required this.assignedTo,
    this.isConfirmed = false,
    this.isPending = false,
    this.needsReplacement = false,
    this.replacementReason,
  });

  factory Planning.fromJson(Map<String, dynamic> json) {
    return Planning(
      id: json['id'] ?? '',
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      assignedTo: json['assignedTo'] ?? '',
      isConfirmed: json['isConfirmed'] ?? false,
      isPending: json['isPending'] ?? false,
      needsReplacement: json['needsReplacement'] ?? false,
      replacementReason: json['replacementReason'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'assignedTo': assignedTo,
      'isConfirmed': isConfirmed,
      'isPending': isPending,
      'needsReplacement': needsReplacement,
      'replacementReason': replacementReason,
    };
  }

  Planning copyWith({
    String? id,
    DateTime? date,
    String? assignedTo,
    bool? isConfirmed,
    bool? isPending,
    bool? needsReplacement,
    String? replacementReason,
  }) {
    return Planning(
      id: id ?? this.id,
      date: date ?? this.date,
      assignedTo: assignedTo ?? this.assignedTo,
      isConfirmed: isConfirmed ?? this.isConfirmed,
      isPending: isPending ?? this.isPending,
      needsReplacement: needsReplacement ?? this.needsReplacement,
      replacementReason: replacementReason ?? this.replacementReason,
    );
  }
}