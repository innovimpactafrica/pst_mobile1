import 'package:equatable/equatable.dart';

abstract class GroupEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// ✅ Charge mes groupes + groupes disponibles + invitations en UN seul event
class LoadAllGroupsEvent extends GroupEvent {}

class LoadMyGroupsEvent extends GroupEvent {}
class LoadAvailableGroupsEvent extends GroupEvent {}
class LoadInvitationsEvent extends GroupEvent {}

class LoadGroupDetailsEvent extends GroupEvent {
  final String groupId;
  LoadGroupDetailsEvent(this.groupId);
  @override
  List<Object?> get props => [groupId];
}

class CreateGroupEvent extends GroupEvent {
  final String name;
  final List<String> memberEmails;
  final String? description;
  final String? schoolId;
  CreateGroupEvent({required this.name, required this.memberEmails, this.description, this.schoolId});
  @override
  List<Object?> get props => [name, memberEmails, description, schoolId];
}

class InviteMemberEvent extends GroupEvent {
  final String groupId;
  final String? email;
  final String? phone;
  InviteMemberEvent({required this.groupId, this.email, this.phone});
  @override
  List<Object?> get props => [groupId, email, phone];
}

class CreatePlanningEvent extends GroupEvent {
  final String groupId;
  final DateTime startDate;
  final DateTime endDate;
  CreatePlanningEvent({required this.groupId, required this.startDate, required this.endDate});
  @override
  List<Object?> get props => [groupId, startDate, endDate];
}

class RequestReplacementEvent extends GroupEvent {
  final String planningId;
  final String reason;
  RequestReplacementEvent({required this.planningId, required this.reason});
  @override
  List<Object?> get props => [planningId, reason];
}

class RespondToReplacementEvent extends GroupEvent {
  final String planningId;
  final bool accept;
  RespondToReplacementEvent({required this.planningId, required this.accept});
  @override
  List<Object?> get props => [planningId, accept];
}

class JoinGroupEvent extends GroupEvent {
  final String groupId;
  JoinGroupEvent(this.groupId);
  @override
  List<Object?> get props => [groupId];
}

/// ✅ Répondre à une invitation (accepter=rejoindre / refuser)
/// PUT /api/parents/carpool/invitations
class RespondToInvitationEvent extends GroupEvent {
  final String invitationId;
  final bool accept;
  RespondToInvitationEvent({required this.invitationId, required this.accept});
  @override
  List<Object?> get props => [invitationId, accept];
}

class SelectGroupTabEvent extends GroupEvent {
  final int tabIndex;
  SelectGroupTabEvent(this.tabIndex);
  @override
  List<Object?> get props => [tabIndex];
}