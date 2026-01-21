class GroupModel {
  final String id;
  final String name;
  final String createdBy;
  final DateTime createdAt;
  final int membersCount;
  final List<GroupMember> members;
  final List<Planning> plannings;
  final String? description;
  final String? avatar; // Lettre du groupe (S, T, E, etc.)

  GroupModel({
    required this.id,
    required this.name,
    required this.createdBy,
    required this.createdAt,
    required this.membersCount,
    required this.members,
    required this.plannings,
    this.description,
    this.avatar,
  });

  // Factory pour créer depuis JSON (API)
  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      createdBy: json['created_by'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      membersCount: json['members_count'] ?? 0,
      members: (json['members'] as List<dynamic>?)
          ?.map((m) => GroupMember.fromJson(m))
          .toList() ??
          [],
      plannings: (json['plannings'] as List<dynamic>?)
          ?.map((p) => Planning.fromJson(p))
          .toList() ??
          [],
      description: json['description'],
      avatar: json['avatar'],
    );
  }

  // Conversion vers JSON (pour l'API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'members_count': membersCount,
      'members': members.map((m) => m.toJson()).toList(),
      'plannings': plannings.map((p) => p.toJson()).toList(),
      'description': description,
      'avatar': avatar,
    };
  }

  // Getter pour l'initiale du groupe
  String get initial => avatar ?? name.substring(0, 1).toUpperCase();

  // 🆕 AJOUT: Factory pour générer des données de test
  factory GroupModel.sample() {
    final now = DateTime.now();

    return GroupModel(
      id: 'group_1',
      name: "Sen' COV",
      createdBy: 'user_123',
      createdAt: now.subtract(const Duration(days: 30)),
      membersCount: 4,
      description: 'Groupe de covoiturage pour l\'école',
      avatar: 'S',
      members: [
        GroupMember(
          id: 'member_1',
          name: 'Moussa Fall',
          role: 'Administrateur',
          availability: '4 jours/sem',
          initials: 'MF',
        ),
        GroupMember(
          id: 'member_2',
          name: 'Fatou Ndiaye',
          role: 'Membre',
          availability: '3 jours/sem',
          initials: 'FN',
        ),
        GroupMember(
          id: 'member_3',
          name: 'Aisatou Diop',
          role: 'Membre',
          availability: '5 jours/sem',
          initials: 'AD',
        ),
        GroupMember(
          id: 'member_4',
          name: 'Mamadou Ndiaye',
          role: 'Membre',
          availability: '2 jours/sem',
          initials: 'MN',
        ),
      ],
      plannings: [
        Planning(
          id: 'planning_1',
          date: now.add(const Duration(days: 1)),
          assignedTo: 'Vous',
          status: 'pending',
        ),
        Planning(
          id: 'planning_2',
          date: now.add(const Duration(days: 2)),
          assignedTo: 'Moussa Fall',
          status: 'pending',
        ),
        Planning(
          id: 'planning_3',
          date: now.add(const Duration(days: 3)),
          assignedTo: 'Moussa Fall',
          status: 'confirmed',
        ),
        Planning(
          id: 'planning_4',
          date: now.add(const Duration(days: 4)),
          assignedTo: 'Aisatou Diop',
          status: 'confirmed',
        ),
        Planning(
          id: 'planning_5',
          date: now.add(const Duration(days: 5)),
          assignedTo: 'Moussa Fall',
          status: 'replacement_requested',
          replacementReason: 'Rendez-vous médical important',
        ),
      ],
    );
  }

  // 🆕 AJOUT: copyWith pour faciliter les mises à jour
  GroupModel copyWith({
    String? id,
    String? name,
    String? createdBy,
    DateTime? createdAt,
    int? membersCount,
    List<GroupMember>? members,
    List<Planning>? plannings,
    String? description,
    String? avatar,
  }) {
    return GroupModel(
      id: id ?? this.id,
      name: name ?? this.name,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      membersCount: membersCount ?? this.membersCount,
      members: members ?? this.members,
      plannings: plannings ?? this.plannings,
      description: description ?? this.description,
      avatar: avatar ?? this.avatar,
    );
  }
}

// MEMBRE DU GROUPE
class GroupMember {
  final String id;
  final String name;
  final String role; // "Administrateur" ou "Membre"
  final String availability; // "Disponible 2/5" par exemple
  final String? photo;
  final String? initials; // "MN", "MF", etc.

  GroupMember({
    required this.id,
    required this.name,
    required this.role,
    required this.availability,
    this.photo,
    this.initials,
  });

  factory GroupMember.fromJson(Map<String, dynamic> json) {
    return GroupMember(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] ?? 'Membre',
      availability: json['availability'] ?? 'Disponible 0/5',
      photo: json['photo'],
      initials: json['initials'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'availability': availability,
      'photo': photo,
      'initials': initials,
    };
  }

  String get displayInitials =>
      initials ?? name.split(' ').map((n) => n[0]).take(2).join().toUpperCase();
}

// PLANNING
class Planning {
  final String id;
  final DateTime date;
  final String assignedTo; // Nom de la personne assignée
  final String status; // "confirmed", "pending", "replacement_requested"
  final String? replacementReason;

  Planning({
    required this.id,
    required this.date,
    required this.assignedTo,
    required this.status,
    this.replacementReason,
  });

  factory Planning.fromJson(Map<String, dynamic> json) {
    return Planning(
      id: json['id'] ?? '',
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      assignedTo: json['assigned_to'] ?? '',
      status: json['status'] ?? 'pending',
      replacementReason: json['replacement_reason'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'assigned_to': assignedTo,
      'status': status,
      'replacement_reason': replacementReason,
    };
  }

  bool get isConfirmed => status == 'confirmed';
  bool get isPending => status == 'pending';
  bool get needsReplacement => status == 'replacement_requested';

  // 🆕 AJOUT: copyWith pour faciliter les mises à jour
  Planning copyWith({
    String? id,
    DateTime? date,
    String? assignedTo,
    String? status,
    String? replacementReason,
  }) {
    return Planning(
      id: id ?? this.id,
      date: date ?? this.date,
      assignedTo: assignedTo ?? this.assignedTo,
      status: status ?? this.status,
      replacementReason: replacementReason ?? this.replacementReason,
    );
  }
}