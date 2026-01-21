import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/group_repository.dart';
import 'group_event.dart';
import 'group_state.dart';

class GroupBloc extends Bloc<GroupEvent, GroupState> {
  final GroupRepository repository;

  GroupBloc({required this.repository}) : super(GroupInitial()) {
    on<LoadMyGroupsEvent>(_onLoadMyGroups);
    on<LoadAvailableGroupsEvent>(_onLoadAvailableGroups);
    on<LoadGroupDetailsEvent>(_onLoadGroupDetails);
    on<CreateGroupEvent>(_onCreateGroup);
    on<InviteMemberEvent>(_onInviteMember);
    on<CreatePlanningEvent>(_onCreatePlanning);
    on<RequestReplacementEvent>(_onRequestReplacement);
    on<RespondToReplacementEvent>(_onRespondToReplacement);
    on<JoinGroupEvent>(_onJoinGroup);
    on<SelectGroupTabEvent>(_onSelectGroupTab);
  }

  // Charger mes groupes
  Future<void> _onLoadMyGroups(
      LoadMyGroupsEvent event,
      Emitter<GroupState> emit,
      ) async {
    emit(GroupLoading());

    try {
      final groups = await repository.getMyGroups();
      emit(MyGroupsLoaded(groups: groups));
    } catch (e) {
      emit(GroupError(message: 'Erreur lors du chargement des groupes: ${e.toString()}'));
    }
  }

  // Charger les groupes disponibles
  Future<void> _onLoadAvailableGroups(
      LoadAvailableGroupsEvent event,
      Emitter<GroupState> emit,
      ) async {
    emit(GroupLoading());

    try {
      final groups = await repository.getAvailableGroups();
      emit(AvailableGroupsLoaded(groups: groups));
    } catch (e) {
      emit(GroupError(message: 'Erreur lors du chargement des groupes: ${e.toString()}'));
    }
  }

  // Charger les détails d'un groupe
  Future<void> _onLoadGroupDetails(
      LoadGroupDetailsEvent event,
      Emitter<GroupState> emit,
      ) async {
    emit(GroupLoading());

    try {
      final group = await repository.getGroupById(event.groupId);
      emit(GroupDetailsLoaded(group: group));
    } catch (e) {
      emit(GroupError(message: 'Erreur lors du chargement du groupe: ${e.toString()}'));
    }
  }

  // Créer un groupe
  Future<void> _onCreateGroup(
      CreateGroupEvent event,
      Emitter<GroupState> emit,
      ) async {
    emit(GroupLoading());

    try {
      final group = await repository.createGroup(
        name: event.name,
        memberEmails: event.memberEmails,
      );
      emit(GroupCreated(group: group));
      // Recharger la liste des groupes
      add(LoadMyGroupsEvent());
    } catch (e) {
      emit(GroupError(message: 'Erreur lors de la création du groupe: ${e.toString()}'));
    }
  }

  // Inviter un membre
  Future<void> _onInviteMember(
      InviteMemberEvent event,
      Emitter<GroupState> emit,
      ) async {
    try {
      await repository.inviteMember(
        groupId: event.groupId,
        email: event.email,
        phone: event.phone,
      );
      emit(MemberInvited());
      // Recharger les détails du groupe
      add(LoadGroupDetailsEvent(event.groupId));
    } catch (e) {
      emit(GroupError(message: 'Erreur lors de l\'invitation: ${e.toString()}'));
    }
  }

  // Créer un planning
  Future<void> _onCreatePlanning(
      CreatePlanningEvent event,
      Emitter<GroupState> emit,
      ) async {
    try {
      await repository.createPlanning(
        groupId: event.groupId,
        startDate: event.startDate,
        endDate: event.endDate,
      );
      emit(PlanningCreated());
      // Recharger les détails du groupe
      add(LoadGroupDetailsEvent(event.groupId));
    } catch (e) {
      emit(GroupError(message: 'Erreur lors de la création du planning: ${e.toString()}'));
    }
  }

  // Demander un remplacement
  Future<void> _onRequestReplacement(
      RequestReplacementEvent event,
      Emitter<GroupState> emit,
      ) async {
    try {
      await repository.requestReplacement(
        planningId: event.planningId,
        reason: event.reason,
      );
      emit(ReplacementRequested());
    } catch (e) {
      emit(GroupError(message: 'Erreur lors de la demande: ${e.toString()}'));
    }
  }

  // Répondre à un remplacement
  Future<void> _onRespondToReplacement(
      RespondToReplacementEvent event,
      Emitter<GroupState> emit,
      ) async {
    try {
      await repository.respondToReplacement(
        planningId: event.planningId,
        accept: event.accept,
      );
      emit(ReplacementResponseSent(accepted: event.accept));
    } catch (e) {
      emit(GroupError(message: 'Erreur lors de la réponse: ${e.toString()}'));
    }
  }

  // Rejoindre un groupe
  Future<void> _onJoinGroup(
      JoinGroupEvent event,
      Emitter<GroupState> emit,
      ) async {
    try {
      await repository.joinGroup(event.groupId);
      emit(GroupJoined(groupId: event.groupId));
      // Recharger mes groupes
      add(LoadMyGroupsEvent());
    } catch (e) {
      emit(GroupError(message: 'Erreur: ${e.toString()}'));
    }
  }

  // Changer d'onglet
  Future<void> _onSelectGroupTab(
      SelectGroupTabEvent event,
      Emitter<GroupState> emit,
      ) async {
    if (state is GroupDetailsLoaded) {
      final currentState = state as GroupDetailsLoaded;
      emit(currentState.copyWith(selectedTabIndex: event.tabIndex));
    }
  }
}