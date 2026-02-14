import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:private_school/parents/pages/groupes/data/models/group_model.dart';
import '../../data/repositories/group_repository.dart';
import 'group_event.dart';
import 'group_state.dart';

class GroupBloc extends Bloc<GroupEvent, GroupState> {
  final GroupRepository repository;

  GroupBloc({required this.repository}) : super(GroupInitial()) {
    on<LoadAllGroupsEvent>(_onLoadAllGroups);
    on<LoadMyGroupsEvent>(_onLoadMyGroups);
    on<LoadAvailableGroupsEvent>(_onLoadAvailableGroups);
    on<LoadInvitationsEvent>(_onLoadInvitations);
    on<LoadGroupDetailsEvent>(_onLoadGroupDetails);
    on<CreateGroupEvent>(_onCreateGroup);
    on<InviteMemberEvent>(_onInviteMember);
    on<CreatePlanningEvent>(_onCreatePlanning);
    on<RequestReplacementEvent>(_onRequestReplacement);
    on<RespondToReplacementEvent>(_onRespondToReplacement);
    on<JoinGroupEvent>(_onJoinGroup);
    on<RespondToInvitationEvent>(_onRespondToInvitation);
    on<SelectGroupTabEvent>(_onSelectGroupTab);
  }

  Future<void> _onLoadAllGroups(
    LoadAllGroupsEvent event,
    Emitter<GroupState> emit,
  ) async {
    emit(GroupLoading());
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('🔵 [GroupBloc] LOAD ALL GROUPS (parallel)');

    try {
      final results = await Future.wait([
        repository.getMyGroups(),
        repository.getAvailableGroups(),
        repository.getInvitations(),
      ]);

      final myGroups = results[0] as dynamic;
      final availableGroups = results[1] as dynamic;
      final invitationsRaw = results[2] as dynamic;

      debugPrint('✅ Mes groupes: ${myGroups.length}');
      debugPrint('✅ Groupes disponibles: ${availableGroups.length}');
      debugPrint('✅ Invitations: ${invitationsRaw.length}');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      emit(GroupsLoaded(
        myGroups: List.from(myGroups),
        availableGroups: List.from(availableGroups),
        invitations: List.from(invitationsRaw),
      ));
    } catch (e) {
      debugPrint('❌ [GroupBloc] LoadAll error: $e\n');
      emit(GroupError(message: 'Erreur chargement groupes: $e'));
    }
  }

  Future<void> _onLoadMyGroups(LoadMyGroupsEvent event, Emitter<GroupState> emit) async {
    add(LoadAllGroupsEvent());
  }

  Future<void> _onLoadAvailableGroups(LoadAvailableGroupsEvent event, Emitter<GroupState> emit) async {
    if (state is GroupsLoaded) {
      try {
        final groups = await repository.getAvailableGroups();
        final current = state as GroupsLoaded;
        emit(current.copyWith(availableGroups: groups));
      } catch (e) {
        debugPrint('❌ LoadAvailable error: $e');
      }
    } else {
      add(LoadAllGroupsEvent());
    }
  }

  Future<void> _onLoadInvitations(LoadInvitationsEvent event, Emitter<GroupState> emit) async {
    if (state is GroupsLoaded) {
      try {
        final invitations = await repository.getInvitations();
        final current = state as GroupsLoaded;
        emit(current.copyWith(invitations: invitations));
      } catch (e) {
        debugPrint('❌ LoadInvitations error: $e');
      }
    }
  }

  Future<void> _onLoadGroupDetails(LoadGroupDetailsEvent event, Emitter<GroupState> emit) async {
    emit(GroupLoading());
    try {
      debugPrint('🔍 [GroupBloc] LOAD GROUP DETAILS: ${event.groupId}');
      
      final results = await Future.wait([
        repository.getGroupById(event.groupId),
        repository.getGroupCalendar(event.groupId),
      ]);

      final group = results[0] as GroupModel;
      final plannings = results[1] as List<Planning>;

      debugPrint('✅ Groupe chargé: ${group.name}');
      debugPrint('✅ ${plannings.length} plannings chargés');

      final groupWithPlannings = group.copyWith(plannings: plannings);

      emit(GroupDetailsLoaded(group: groupWithPlannings));
    } catch (e) {
      debugPrint('❌ Details error: $e');
      emit(GroupError(message: 'Erreur chargement groupe: $e'));
    }
  }

  Future<void> _onCreateGroup(CreateGroupEvent event, Emitter<GroupState> emit) async {
    emit(GroupLoading());
    try {
      debugPrint('🟢 [GroupBloc] CREATE GROUP: ${event.name}');
      final group = await repository.createGroup(
        name: event.name,
        memberEmails: event.memberEmails,
        description: event.description,
      );
      debugPrint('✅ Groupe créé: ${group.id}');
      emit(GroupCreated(group: group));
      add(LoadAllGroupsEvent());
    } catch (e) {
      debugPrint('❌ Create error: $e');
      emit(GroupError(message: 'Erreur création groupe: $e'));
    }
  }

  Future<void> _onInviteMember(InviteMemberEvent event, Emitter<GroupState> emit) async {
    try {
      debugPrint('📨 [GroupBloc] INVITE MEMBER to ${event.groupId}');
      await repository.inviteMember(
        groupId: event.groupId,
        email: event.email,
        phone: event.phone,
      );
      debugPrint('✅ Invitation envoyée');
      emit(MemberInvited());
      add(LoadGroupDetailsEvent(event.groupId));
    } catch (e) {
      debugPrint('❌ Invite error: $e');
      String errorMessage = 'Erreur invitation';
      if (e.toString().contains('Aucun parent trouvé')) {
        errorMessage = 'Cet email ne correspond à aucun compte parent.';
      } else {
        errorMessage = e.toString();
      }
      emit(GroupError(message: errorMessage));
    }
  }

  Future<void> _onJoinGroup(JoinGroupEvent event, Emitter<GroupState> emit) async {
    try {
      debugPrint('🔵 [GroupBloc] JOIN GROUP: ${event.groupId}');
      await repository.joinGroup(event.groupId);
      debugPrint('✅ Groupe rejoint');
      emit(GroupJoined(groupId: event.groupId));
      add(LoadAllGroupsEvent());
    } catch (e) {
      debugPrint('❌ Join error: $e');
      emit(GroupError(message: 'Erreur rejoindre groupe: $e'));
    }
  }

  Future<void> _onRespondToInvitation(
    RespondToInvitationEvent event,
    Emitter<GroupState> emit,
  ) async {
    try {
      debugPrint('📝 [GroupBloc] RESPOND INVITATION ${event.invitationId}: ${event.accept}');
      await repository.respondToInvitation(
        invitationId: event.invitationId,
        accept: event.accept,
      );
      debugPrint('✅ Réponse envoyée');
      emit(InvitationResponded(accepted: event.accept));
      add(LoadAllGroupsEvent());
    } catch (e) {
      debugPrint('❌ Respond error: $e');
      emit(GroupError(message: 'Erreur réponse invitation: $e'));
    }
  }

  Future<void> _onCreatePlanning(CreatePlanningEvent event, Emitter<GroupState> emit) async {
    emit(GroupLoading()); 
    try {
      debugPrint('[GroupBloc] CREATE PLANNING for ${event.groupId}');
      await repository.createPlanning(
        groupId: event.groupId,
        startDate: event.startDate,
        endDate: event.endDate,
      );
      debugPrint('✅ Planning créé');
      emit(PlanningCreated());
      add(LoadGroupDetailsEvent(event.groupId)); 
    } catch (e) {
      debugPrint('❌ Planning error: $e');
      emit(GroupError(message: 'Erreur planning: $e'));
    }
  }

// ✅ Remplacez la méthode _onRequestReplacement dans group_bloc.dart

Future<void> _onRequestReplacement(RequestReplacementEvent event, Emitter<GroupState> emit) async {
  try {
    debugPrint('[GroupBloc] REQUEST REPLACEMENT');
    debugPrint('   Planning ID: ${event.planning.id}');
    debugPrint('   Group ID: ${event.planning.groupId}');
    debugPrint('   Date: ${event.planning.date}');
    debugPrint('   Reason: ${event.reason}');
    
    await repository.requestReplacement(
      planning: event.planning,  // ✅ Passer l'objet Planning complet
      reason: event.reason,
    );
    emit(ReplacementRequested());
  } catch (e) {
    debugPrint('❌ [GroupBloc] RequestReplacement error: $e');
    emit(GroupError(message: 'Erreur remplacement: $e'));
  }
}

  Future<void> _onRespondToReplacement(RespondToReplacementEvent event, Emitter<GroupState> emit) async {
    try {
      await repository.respondToReplacement(planningId: event.planningId, accept: event.accept);
      emit(ReplacementResponseSent(accepted: event.accept));
    } catch (e) {
      emit(GroupError(message: 'Erreur réponse: $e'));
    }
  }

  Future<void> _onSelectGroupTab(SelectGroupTabEvent event, Emitter<GroupState> emit) async {
    if (state is GroupDetailsLoaded) {
      final current = state as GroupDetailsLoaded;
      emit(current.copyWith(selectedTabIndex: event.tabIndex));
    }
  }
}