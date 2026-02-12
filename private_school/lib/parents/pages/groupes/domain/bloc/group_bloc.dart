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

  // ─────────────────────────────────────────────
  // ✅ CHARGER TOUT EN PARALLÈLE — résout la course condition
  // ─────────────────────────────────────────────
  Future<void> _onLoadAllGroups(
    LoadAllGroupsEvent event,
    Emitter<GroupState> emit,
  ) async {
    emit(GroupLoading());
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('🔵 [GroupBloc] LOAD ALL GROUPS (parallel)');

    try {
      // ✅ Appels parallèles — pas séquentiels
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

  // Garder compatibilité — délèguent vers LoadAllGroupsEvent
  Future<void> _onLoadMyGroups(LoadMyGroupsEvent event, Emitter<GroupState> emit) async {
    add(LoadAllGroupsEvent());
  }

  Future<void> _onLoadAvailableGroups(LoadAvailableGroupsEvent event, Emitter<GroupState> emit) async {
    if (state is GroupsLoaded) {
      // Rafraîchir seulement la liste disponible sans bloquer l'UI
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
    
    // ✅ Charger GROUPE + PLANNINGS en parallèle
    final results = await Future.wait([
      repository.getGroupById(event.groupId),
      repository.getGroupCalendar(event.groupId), // ✅ AJOUT : charge les plannings
    ]);

    final group = results[0] as GroupModel;
    final plannings = results[1] as List<Planning>;

    debugPrint('✅ Groupe chargé: ${group.name}');
    debugPrint('✅ ${plannings.length} plannings chargés');

    // ✅ Mettre à jour le groupe avec les plannings
    final groupWithPlannings = group.copyWith(plannings: plannings);

    emit(GroupDetailsLoaded(group: groupWithPlannings));
  } catch (e) {
    debugPrint('❌ Details error: $e');
    emit(GroupError(message: 'Erreur chargement groupe: $e'));
  }
}

  // ─────────────────────────────────────────────
  // ✅ CRÉER UN GROUPE — POST /api/parents/carpool/groups
  // ─────────────────────────────────────────────
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

  // ─────────────────────────────────────────────
  // ✅ INVITER — POST /api/parents/carpool/invitations
  // ─────────────────────────────────────────────
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
      emit(GroupError(message: 'Erreur invitation: $e'));
    }
  }


  // "Rejoindre" = accepter l'invitation du groupe
  // ─────────────────────────────────────────────
  Future<void> _onJoinGroup(JoinGroupEvent event, Emitter<GroupState> emit) async {
    try {
      debugPrint('🔵 [GroupBloc] JOIN GROUP: ${event.groupId}');
      await repository.joinGroup(event.groupId);
      debugPrint('✅ Groupe rejoint');
      emit(GroupJoined(groupId: event.groupId));
      add(LoadAllGroupsEvent());
    } 
 catch (e) {
  debugPrint('❌ Invite error: $e');
  // On essaie d'extraire le message d'erreur de l'API s'il existe
  String errorMessage = 'Erreur invitation';
  if (e.toString().contains('Aucun parent trouvé')) {
    errorMessage = 'Cet email ne correspond à aucun compte parent.';
  } else {
    errorMessage = e.toString();
  }
  emit(GroupError(message: errorMessage));
}
  }

  // ─────────────────────────────────────────────
  // ✅ RÉPONDRE À INVITATION — PUT /api/parents/carpool/invitations
  // ─────────────────────────────────────────────
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
    // On recharge les détails pour voir le nouveau planning
    add(LoadGroupDetailsEvent(event.groupId)); 
  } catch (e) {
    debugPrint('❌ Planning error: $e');
    emit(GroupError(message: 'Erreur planning: $e'));
  }
}

  Future<void> _onRequestReplacement(RequestReplacementEvent event, Emitter<GroupState> emit) async {
    try {
      await repository.requestReplacement(planningId: event.planningId, reason: event.reason);
      emit(ReplacementRequested());
    } catch (e) {
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