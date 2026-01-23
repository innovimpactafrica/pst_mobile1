import 'package:equatable/equatable.dart';

abstract class GroupEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// Charger mes groupes
class LoadMyGroupsEvent extends GroupEvent {}

// Charger les groupes disponibles à rejoindre
class LoadAvailableGroupsEvent extends GroupEvent {}

// Charger les détails d'un groupe
class LoadGroupDetailsEvent extends GroupEvent {
  final String groupId;

  LoadGroupDetailsEvent(this.groupId);

  @override
  List<Object?> get props => [groupId];
}

// Créer un groupe
class CreateGroupEvent extends GroupEvent {
  final String name;
  final List<String> memberEmails;

  CreateGroupEvent({
    required this.name,
    required this.memberEmails,
  });

  @override
  List<Object?> get props => [name, memberEmails];
}

// Inviter un membre
class InviteMemberEvent extends GroupEvent {
  final String groupId;
  final String? email;      // ✅ String? (nullable)
  final String? phone;

  InviteMemberEvent({
    required this.groupId,
    this.email,             // ✅ PAS required
    this.phone,
  });

  @override
  List<Object?> get props => [groupId, email, phone];
}

// Créer un planning
class CreatePlanningEvent extends GroupEvent {
  final String groupId;
  final DateTime startDate;
  final DateTime endDate;

  CreatePlanningEvent({
    required this.groupId,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [groupId, startDate, endDate];
}

// Demander un remplacement
class RequestReplacementEvent extends GroupEvent {
  final String planningId;
  final String reason;

  RequestReplacementEvent({
    required this.planningId,
    required this.reason,
  });

  @override
  List<Object?> get props => [planningId, reason];
}

// Répondre à une demande de remplacement
class RespondToReplacementEvent extends GroupEvent {
  final String planningId;
  final bool accept;

  RespondToReplacementEvent({
    required this.planningId,
    required this.accept,
  });

  @override
  List<Object?> get props => [planningId, accept];
}

// Rejoindre un groupe
class JoinGroupEvent extends GroupEvent {
  final String groupId;

  JoinGroupEvent(this.groupId);

  @override
  List<Object?> get props => [groupId];
}

// Changer d'onglet dans le détail du groupe
class SelectGroupTabEvent extends GroupEvent {
  final int tabIndex; // 0 = Planning, 1 = Membres, 2 = Historiques

  SelectGroupTabEvent(this.tabIndex);

  @override
  List<Object?> get props => [tabIndex];
}