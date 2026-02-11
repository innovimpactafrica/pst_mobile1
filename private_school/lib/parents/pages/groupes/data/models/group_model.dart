import 'package:flutter/foundation.dart';

class GroupModel {
  final String id;
  final String name;
  final String createdBy;       // creator_name de l'API
  final String creatorId;       // creator_id de l'API
  final DateTime createdAt;
  final int membersCount;
  final List<GroupMember> members;
  final List<Planning> plannings;
  final String? description;
  final String? avatar;
  final String? schoolName;     // school_name de l'API
  final String status;          // status de l'API
  final String? membershipStatus; // membership_status
  final bool isCreator;         // is_creator

  GroupModel({
    required this.id,
    required this.name,
    required this.createdBy,
    required this.creatorId,
    required this.createdAt,
    required this.membersCount,
    required this.members,
    required this.plannings,
    this.description,
    this.avatar,
    this.schoolName,
    this.status = 'active',
    this.membershipStatus,
    this.isCreator = false,
  });

  /// ✅ fromJson corrigé — mappe creator_name, members_count (String→int)
  factory GroupModel.fromJson(Map<String, dynamic> json) {
    debugPrint('🔍 [GroupModel.fromJson] Parsing group: ${json['id']}');
    debugPrint('   name: ${json['name']}');
    debugPrint('   creator_name: ${json['creator_name']}');
    debugPrint('   members_count: ${json['members_count']} (${json['members_count'].runtimeType})');

    return GroupModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      // ✅ FIX : utiliser creator_name (pas creator_id)
      createdBy: json['creator_name'] ?? json['created_by'] ?? 'Inconnu',
      creatorId: json['creator_id']?.toString() ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
      // ✅ FIX : members_count arrive comme String "0" → int
      membersCount: _parseInt(json['members_count']),
      members: (json['members'] as List<dynamic>?)
          ?.map((m) => GroupMember.fromJson(m as Map<String, dynamic>))
          .toList() ?? [],
      plannings: (json['plannings'] as List<dynamic>?)
          ?.map((p) => Planning.fromJson(p as Map<String, dynamic>))
          .toList() ?? [],
      description: json['description'],
      avatar: json['avatar'],
      schoolName: json['school_name'],
      status: json['status'] ?? 'active',
      membershipStatus: json['membership_status'],
      isCreator: json['is_creator'] == true,
    );
  }

  static int _parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'creator_name': createdBy,
    'creator_id': creatorId,
    'created_at': createdAt.toIso8601String(),
    'members_count': membersCount,
    'description': description,
    'school_name': schoolName,
    'status': status,
    'membership_status': membershipStatus,
    'is_creator': isCreator,
  };

  String get initial => avatar ?? name.substring(0, 1).toUpperCase();

  GroupModel copyWith({
    String? id, String? name, String? createdBy, String? creatorId,
    DateTime? createdAt, int? membersCount, List<GroupMember>? members,
    List<Planning>? plannings, String? description, String? avatar,
    String? schoolName, String? status, String? membershipStatus, bool? isCreator,
  }) {
    return GroupModel(
      id: id ?? this.id, name: name ?? this.name,
      createdBy: createdBy ?? this.createdBy, creatorId: creatorId ?? this.creatorId,
      createdAt: createdAt ?? this.createdAt, membersCount: membersCount ?? this.membersCount,
      members: members ?? this.members, plannings: plannings ?? this.plannings,
      description: description ?? this.description, avatar: avatar ?? this.avatar,
      schoolName: schoolName ?? this.schoolName, status: status ?? this.status,
      membershipStatus: membershipStatus ?? this.membershipStatus, isCreator: isCreator ?? this.isCreator,
    );
  }
}

// ─────────────────────────────────────────────
// INVITATION MODEL — pour GET /api/parents/carpool/invitations
// ─────────────────────────────────────────────
class GroupInvitation {
  final String id;
  final String groupId;
  final String groupName;
  final String invitedBy;
  final String? invitedAt;
  final String status; // 'pending', 'accepted', 'declined'

  GroupInvitation({
    required this.id,
    required this.groupId,
    required this.groupName,
    required this.invitedBy,
    this.invitedAt,
    required this.status,
  });

  factory GroupInvitation.fromJson(Map<String, dynamic> json) {
    return GroupInvitation(
      id: json['id']?.toString() ?? '',
      groupId: json['group_id']?.toString() ?? json['groupId']?.toString() ?? '',
      groupName: json['group_name'] ?? json['groupName'] ?? '',
      invitedBy: json['invited_by'] ?? json['inviter_name'] ?? 'Inconnu',
      invitedAt: json['invited_at'],
      status: json['status'] ?? 'pending',
    );
  }

  String get initial => groupName.isNotEmpty ? groupName[0].toUpperCase() : '?';
}

// ─────────────────────────────────────────────
// GROUPE MEMBRE
// ─────────────────────────────────────────────
class GroupMember {
  final String id;
  final String name;
  final String role;
  final String availability;
  final String? photo;
  final String? initials;

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
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? json['full_name'] ?? '',
      role: json['role'] ?? 'Membre',
      availability: json['availability'] ?? 'Disponible 0/5',
      photo: json['photo'],
      initials: json['initials'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'role': role,
    'availability': availability, 'photo': photo, 'initials': initials,
  };

  String get displayInitials =>
      initials ?? name.split(' ').map((n) => n.isNotEmpty ? n[0] : '').take(2).join().toUpperCase();
}

// ─────────────────────────────────────────────
// PLANNING
// ─────────────────────────────────────────────
class Planning {
  final String id;
  final DateTime date;
  final String assignedTo;
  final String status;
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
      id: json['id']?.toString() ?? '',
      date: json['date'] != null
          ? DateTime.tryParse(json['date']) ?? DateTime.now()
          : DateTime.now(),
      assignedTo: json['assigned_to'] ?? '',
      status: json['status'] ?? 'pending',
      replacementReason: json['replacement_reason'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'assigned_to': assignedTo,
    'status': status,
    'replacement_reason': replacementReason,
  };

  bool get isConfirmed => status == 'confirmed';
  bool get isPending => status == 'pending';
  bool get needsReplacement => status == 'replacement_requested';

  Planning copyWith({String? id, DateTime? date, String? assignedTo, String? status, String? replacementReason}) {
    return Planning(
      id: id ?? this.id, date: date ?? this.date,
      assignedTo: assignedTo ?? this.assignedTo, status: status ?? this.status,
      replacementReason: replacementReason ?? this.replacementReason,
    );
  }
}