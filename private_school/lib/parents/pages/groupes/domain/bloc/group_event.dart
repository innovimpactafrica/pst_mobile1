import 'package:equatable/equatable.dart';
import 'package:private_school/parents/pages/groupes/data/models/group_model.dart';

abstract class GroupEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadAllGroupsEvent extends GroupEvent {}

class SearchGroupsEvent extends GroupEvent {
  final String query;
  SearchGroupsEvent(this.query);
  @override
  List<Object?> get props => [query];
}

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
  CreateGroupEvent({
    required this.name,
    required this.memberEmails,
    this.description,
    this.schoolId,
  });
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
  CreatePlanningEvent({
    required this.groupId,
    required this.startDate,
    required this.endDate,
  });
  @override
  List<Object?> get props => [groupId, startDate, endDate];
}

class RequestReplacementEvent extends GroupEvent {
  final Planning planning;
  final String reason;
  RequestReplacementEvent({required this.planning, required this.reason});
  @override
  List<Object?> get props => [planning, reason];
}

class ConfirmPlanningEvent extends GroupEvent {
  final String planningId;
  ConfirmPlanningEvent(this.planningId);
  @override
  List<Object?> get props => [planningId];
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
