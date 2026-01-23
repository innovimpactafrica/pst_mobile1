import 'package:equatable/equatable.dart';
import '../../data/models/group_model.dart';


abstract class GroupState extends Equatable {
  @override
  List<Object?> get props => [];
}

// État initial
class GroupInitial extends GroupState {}

// Chargement
class GroupLoading extends GroupState {}

// Mes groupes chargés
class MyGroupsLoaded extends GroupState {
  final List<GroupModel> groups;

  MyGroupsLoaded({required this.groups});

  @override
  List<Object?> get props => [groups];
}

// Groupes disponibles chargés
class AvailableGroupsLoaded extends GroupState {
  final List<GroupModel> groups;

  AvailableGroupsLoaded({required this.groups});

  @override
  List<Object?> get props => [groups];
}

// Détails d'un groupe chargés
class GroupDetailsLoaded extends GroupState {
  final GroupModel group;
  final int selectedTabIndex; // 0 = Planning, 1 = Membres, 2 = Historiques

  GroupDetailsLoaded({
    required this.group,
    this.selectedTabIndex = 0,
  });

  @override
  List<Object?> get props => [group, selectedTabIndex];

  // Copie avec modification
  GroupDetailsLoaded copyWith({
    GroupModel? group,
    int? selectedTabIndex,
  }) {
    return GroupDetailsLoaded(
      group: group ?? this.group,
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
    );
  }
}

// Groupe créé avec succès
class GroupCreated extends GroupState {
  final GroupModel group;

  GroupCreated({required this.group});

  @override
  List<Object?> get props => [group];
}

// Membre invité avec succès
class MemberInvited extends GroupState {}

// Planning créé avec succès
class PlanningCreated extends GroupState {}

// Remplacement demandé avec succès
class ReplacementRequested extends GroupState {}

// Réponse au remplacement envoyée
class ReplacementResponseSent extends GroupState {
  final bool accepted;

  ReplacementResponseSent({required this.accepted});

  @override
  List<Object?> get props => [accepted];
}

// Groupe rejoint avec succès
class GroupJoined extends GroupState {
  final String groupId;

  GroupJoined({required this.groupId});

  @override
  List<Object?> get props => [groupId];
}

// Erreur
class GroupError extends GroupState {
  final String message;

  GroupError({required this.message});

  @override
  List<Object?> get props => [message];
}