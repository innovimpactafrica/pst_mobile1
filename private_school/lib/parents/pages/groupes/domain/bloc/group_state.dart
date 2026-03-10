import 'package:equatable/equatable.dart';
import '../../data/models/group_model.dart';

abstract class GroupState extends Equatable {
  @override
  List<Object?> get props => [];
}

class GroupInitial extends GroupState {}

class GroupLoading extends GroupState {}

class GroupsLoaded extends GroupState {
  final List<GroupModel> myGroups;
  final List<GroupModel> availableGroups;
  final List<GroupInvitation> invitations;
  final List<GroupModel> filteredMyGroups;
  final List<GroupModel> filteredAvailableGroups;
  final String searchQuery;
  final bool isLoadingMore;

  GroupsLoaded({
    this.myGroups = const [],
    this.availableGroups = const [],
    this.invitations = const [],
    List<GroupModel>? filteredMyGroups,
    List<GroupModel>? filteredAvailableGroups,
    this.searchQuery = '',
    this.isLoadingMore = false,
  }) : filteredMyGroups = filteredMyGroups ?? myGroups,
       filteredAvailableGroups = filteredAvailableGroups ?? availableGroups;

  @override
  List<Object?> get props => [
    myGroups,
    availableGroups,
    invitations,
    filteredMyGroups,
    filteredAvailableGroups,
    searchQuery,
    isLoadingMore,
  ];

  GroupsLoaded copyWith({
    List<GroupModel>? myGroups,
    List<GroupModel>? availableGroups,
    List<GroupInvitation>? invitations,
    List<GroupModel>? filteredMyGroups,
    List<GroupModel>? filteredAvailableGroups,
    String? searchQuery,
    bool? isLoadingMore,
  }) {
    return GroupsLoaded(
      myGroups: myGroups ?? this.myGroups,
      availableGroups: availableGroups ?? this.availableGroups,
      invitations: invitations ?? this.invitations,
      filteredMyGroups: filteredMyGroups ?? this.filteredMyGroups,
      filteredAvailableGroups:
          filteredAvailableGroups ?? this.filteredAvailableGroups,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

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

class GroupDetailsLoaded extends GroupState {
  final GroupModel group;
  final int selectedTabIndex;
  final List<Map<String, dynamic>> replacementHistory;
  GroupDetailsLoaded({required this.group, this.selectedTabIndex = 0,this.replacementHistory = const [],});
  @override
  List<Object?> get props => [group, selectedTabIndex,replacementHistory];
  GroupDetailsLoaded copyWith({GroupModel? group, int? selectedTabIndex, List<Map<String, dynamic>>? replacementHistory,}) {
    return GroupDetailsLoaded(
      group: group ?? this.group,
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
       replacementHistory: replacementHistory ?? this.replacementHistory,
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

class PlanningConfirmed extends GroupState {}

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
