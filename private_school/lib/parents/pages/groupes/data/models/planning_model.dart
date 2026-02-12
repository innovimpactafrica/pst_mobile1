class Planning {
  final String id;
  final String groupId;
  final DateTime date;

  final String? assignedTo;
  final bool needsReplacement;
  final String? replacementReason;

  Planning({
    required this.id,
    required this.groupId,
    required this.date,
    this.assignedTo,
    this.needsReplacement = false,
    this.replacementReason,
  });

  factory Planning.fromJson(Map<String, dynamic> json) {
    return Planning(
      id: json['id'].toString(),
      groupId: json['group_id'].toString(), // ⭐ LA CLE DU BUG
      date: DateTime.parse(json['date']),
      assignedTo: json['driver_name'], // si dispo
      needsReplacement: json['needs_replacement'] ?? false,
      replacementReason: json['replacement_reason'],
    );
  }
}
