import 'package:flutter/foundation.dart';

class GroupModel {
  final String id;
  final String name;
  final String createdBy;
  final String creatorId;
  final DateTime createdAt;
  final int membersCount;
  final List<GroupMember> members;
  final List<Planning> plannings;
  final String? description;
  final String? avatar;
  final String? schoolName;
  final String status;
  final String? membershipStatus;
  final bool isCreator;

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

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    debugPrint(' [GroupModel.fromJson] Parsing group: ${json['id']}');
    debugPrint('   name: ${json['name']}');
    debugPrint('   creator_name: ${json['creator_name']}');
    debugPrint(
      '   members_count: ${json['members_count']} (${json['members_count'].runtimeType})',
    );

    return GroupModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',

      createdBy: json['creator_name'] ?? json['created_by'] ?? 'Inconnu',
      creatorId: json['creator_id']?.toString() ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),

      membersCount: _parseInt(json['members_count']),
      members:
          (json['members'] as List<dynamic>?)
              ?.map((m) => GroupMember.fromJson(m as Map<String, dynamic>))
              .toList() ??
          [],
      plannings:
          (json['plannings'] as List<dynamic>?)
              ?.map((p) => Planning.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
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
    String? id,
    String? name,
    String? createdBy,
    String? creatorId,
    DateTime? createdAt,
    int? membersCount,
    List<GroupMember>? members,
    List<Planning>? plannings,
    String? description,
    String? avatar,
    String? schoolName,
    String? status,
    String? membershipStatus,
    bool? isCreator,
  }) {
    return GroupModel(
      id: id ?? this.id,
      name: name ?? this.name,
      createdBy: createdBy ?? this.createdBy,
      creatorId: creatorId ?? this.creatorId,
      createdAt: createdAt ?? this.createdAt,
      membersCount: membersCount ?? this.membersCount,
      members: members ?? this.members,
      plannings: plannings ?? this.plannings,
      description: description ?? this.description,
      avatar: avatar ?? this.avatar,
      schoolName: schoolName ?? this.schoolName,
      status: status ?? this.status,
      membershipStatus: membershipStatus ?? this.membershipStatus,
      isCreator: isCreator ?? this.isCreator,
    );
  }
}

class GroupInvitation {
  final String id;
  final String groupId;
  final String groupName;
  final String invitedBy;
  final String? invitedAt;
  final String status;

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
      groupId:
          json['group_id']?.toString() ?? json['groupId']?.toString() ?? '',
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
    final name = json['name'] ?? json['full_name'] ?? '';
    String calculatedInitials = '';
    if (name.isNotEmpty) {
      final parts = name.trim().split(' ');
      if (parts.length >= 2) {
        calculatedInitials = '${parts[0][0]}${parts[parts.length - 1][0]}'
            .toUpperCase();
      } else {
        calculatedInitials = name.length >= 2
            ? name.substring(0, 2).toUpperCase()
            : name[0].toUpperCase();
      }
    }

    return GroupMember(
      id: json['id']?.toString() ?? '',
      name: name,
      role: json['role'] ?? 'Membre',
      availability: json['availability'] ?? 'Disponible 0/5',
      photo: json['photo'],
      initials: calculatedInitials,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'role': role,
    'availability': availability,
    'photo': photo,
    'initials': initials,
  };

  String get displayInitials =>
      initials ??
      name
          .split(' ')
          .map((n) => n.isNotEmpty ? n[0] : '')
          .take(2)
          .join()
          .toUpperCase();
}

// ─────────────────────────────────────────────
// PLANNING
// ─────────────────────────────────────────────

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
  final String? replacementRequesterName;
  final String? replacementRequesterId;
  final String? replacementRequestId;
  final String? replacementRequestCreatedAt;
  final bool needsReplacementFlag;
  final String? confirmationStatus;

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
    this.replacementRequesterName,
    this.replacementRequesterId,
    this.replacementRequestId,
    this.replacementRequestCreatedAt,
    this.needsReplacementFlag = false,
    this.confirmationStatus,
  });

  factory Planning.fromJson(Map<String, dynamic> json) {
    final replacementRequest = json['replacement_request'];
    final bool hasPendingRequest =
        replacementRequest != null && replacementRequest['status'] == 'pending';

    return Planning(
      id: json['id']?.toString() ?? '',
      groupId: json['group_id']?.toString() ?? '',
      date: json['date'] != null
          ? DateTime.tryParse(json['date']) ?? DateTime.now()
          : DateTime.now(),

      driverId: json['driver_id']?.toString(),
      driverName: json['assigned_to_name'] ?? json['driver_name'],
      driverPhone: json['assigned_to_phone'] ?? json['driver_phone'],
      driverEmail: json['assigned_to_email'] ?? json['driver_email'],

      isMyTurn: json['is_my_turn'] as bool?,
      status: json['status'] ?? 'scheduled',
      replacementReason: replacementRequest != null
          ? replacementRequest['reason']?.toString()
          : json['replacement_reason'],

      startPoint: json['start_point'],
      endPoint: json['end_point'],
      departureTime: json['departure_time'],
      returnTime: json['return_time'],
      capacityMax: json['capacity_max'],
      notes: json['notes'],

      replacementAcceptedBy: json['replacement_accepted_by']?.toString(),
      replacementAcceptedByName: json['replacement_accepted_by_name'],
      replacementRequesterName: json['replacement_requester_name'],
      replacementRequesterId: json['replacement_requester_id']?.toString(),

      replacementRequestId: replacementRequest != null
          ? replacementRequest['id']?.toString()
          : json['replacement_request_id']?.toString(),
      replacementRequestCreatedAt: replacementRequest != null
          ? replacementRequest['created_at']?.toString()
          : null,
      needsReplacementFlag: hasPendingRequest,
      confirmationStatus: json['confirmation_status']?.toString(),
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
    'replacement_requester_name': replacementRequesterName,
    'replacement_requester_id': replacementRequesterId,
    'replacement_request_id': replacementRequestId,
    'needs_replacement': needsReplacementFlag,
  };

  bool get isConfirmed =>
      confirmationStatus == 'confirmed' || status == 'confirmed';
  bool get isPending => status == 'scheduled' || status == 'pending';
  bool get needsReplacement =>
      needsReplacementFlag || status == 'replacement_requested';
  bool get isReplacementAccepted =>
      status == 'replacement_accepted' ||
      (replacementAcceptedByName != null &&
          replacementAcceptedByName!.isNotEmpty);
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
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
    String? replacementRequesterName,
    String? replacementRequesterId,
    String? replacementRequestId,
    String? replacementRequestCreatedAt,
    bool? needsReplacement,
    String? confirmationStatus,
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
      replacementAcceptedBy:
          replacementAcceptedBy ?? this.replacementAcceptedBy,
      replacementAcceptedByName:
          replacementAcceptedByName ?? this.replacementAcceptedByName,
      replacementRequesterName:
          replacementRequesterName ?? this.replacementRequesterName,
      replacementRequesterId:
          replacementRequesterId ?? this.replacementRequesterId,
      replacementRequestId: replacementRequestId ?? this.replacementRequestId,
      replacementRequestCreatedAt:
          replacementRequestCreatedAt ?? this.replacementRequestCreatedAt,
      needsReplacementFlag: needsReplacement ?? needsReplacementFlag,
      confirmationStatus: confirmationStatus ?? this.confirmationStatus,
    );
  }
}
