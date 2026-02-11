import 'package:equatable/equatable.dart';
import '../../data/models/group_model.dart';

abstract class GroupState extends Equatable {
  @override
  List<Object?> get props => [];
}

class GroupInitial extends GroupState {}
class GroupLoading extends GroupState {}

/// ✅ NOUVEAU : état composite qui garde les DEUX listes simultanément
/// Résout la course condition LoadMyGroups ↔ LoadAvailableGroups
class GroupsLoaded extends GroupState {
  final List<GroupModel> myGroups;
  final List<GroupModel> availableGroups;
  final List<GroupInvitation> invitations;
  final bool isLoadingMore; // pour un refresh partiel

  GroupsLoaded({
    this.myGroups = const [],
    this.availableGroups = const [],
    this.invitations = const [],
    this.isLoadingMore = false,
  });

  @override
  List<Object?> get props => [myGroups, availableGroups, invitations, isLoadingMore];

  GroupsLoaded copyWith({
    List<GroupModel>? myGroups,
    List<GroupModel>? availableGroups,
    List<GroupInvitation>? invitations,
    bool? isLoadingMore,
  }) {
    return GroupsLoaded(
      myGroups: myGroups ?? this.myGroups,
      availableGroups: availableGroups ?? this.availableGroups,
      invitations: invitations ?? this.invitations,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

// ─── Gardés pour compatibilité avec groupes_page.dart existant ───
class MyGroupsLoaded extends GroupState {
  final List<GroupModel> groups;
  MyGroupsLoaded({required this.groups});
  @override
  List<Object?> get props => [groups];
}

class AvailableGroupsLoaded extends GroupState {
  final List<GroupModel> groups;
  AvailableGroupsLoaded({required this.groups});
  @override
  List<Object?> get props => [groups];
}

// Détails d'un groupe
class GroupDetailsLoaded extends GroupState {
  final GroupModel group;
  final int selectedTabIndex;
  GroupDetailsLoaded({required this.group, this.selectedTabIndex = 0});
  @override
  List<Object?> get props => [group, selectedTabIndex];
  GroupDetailsLoaded copyWith({GroupModel? group, int? selectedTabIndex}) {
    return GroupDetailsLoaded(
      group: group ?? this.group,
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
    );
  }
}

class GroupCreated extends GroupState {
  final GroupModel group;
  GroupCreated({required this.group});
  @override
  List<Object?> get props => [group];
}

class MemberInvited extends GroupState {}
class PlanningCreated extends GroupState {}
class ReplacementRequested extends GroupState {}
class ReplacementResponseSent extends GroupState {
  final bool accepted;
  ReplacementResponseSent({required this.accepted});
  @override
  List<Object?> get props => [accepted];
}

class GroupJoined extends GroupState {
  final String groupId;
  GroupJoined({required this.groupId});
  @override
  List<Object?> get props => [groupId];
}

class InvitationResponded extends GroupState {
  final bool accepted;
  InvitationResponded({required this.accepted});
  @override
  List<Object?> get props => [accepted];
}

class GroupError extends GroupState {
  final String message;
  GroupError({required this.message});
  @override
  List<Object?> get props => [message];
}