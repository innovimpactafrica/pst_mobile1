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
    on<SearchGroupsEvent>(_onSearchGroups);
    on<LoadMyGroupsEvent>(_onLoadMyGroups);
    on<LoadAvailableGroupsEvent>(_onLoadAvailableGroups);
    on<LoadInvitationsEvent>(_onLoadInvitations);
    on<LoadGroupDetailsEvent>(_onLoadGroupDetails);
    on<CreateGroupEvent>(_onCreateGroup);
    on<InviteMemberEvent>(_onInviteMember);
    on<CreatePlanningEvent>(_onCreatePlanning);
    on<ConfirmPlanningEvent>(_onConfirmPlanning);
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
    debugPrint(' [GroupBloc] LOAD ALL GROUPS (parallel)');

    try {
      final results = await Future.wait([
        repository.getMyGroups(),
        repository.getAvailableGroups(),
        repository.getInvitations(),
      ]);

      final myGroups = results[0] as List<GroupModel>;
      final allGroupsRaw = results[1] as List<GroupModel>;
      final invitationsRaw = results[2] as List<GroupInvitation>;

      debugPrint('');
      debugPrint(' DONNÉES BRUTES REÇUES:');
      debugPrint('   Mes groupes: ${myGroups.length}');
      for (var g in myGroups) {
        debugPrint('      - ID: ${g.id}, Nom: ${g.name}');
      }
      debugPrint('   Tous les groupes (brut): ${allGroupsRaw.length}');
      for (var g in allGroupsRaw) {
        debugPrint('      - ID: ${g.id}, Nom: ${g.name}');
      }
      debugPrint('   Invitations: ${invitationsRaw.length}');
      for (var inv in invitationsRaw) {
        debugPrint('      - ID: ${inv.id}, Groupe: ${inv.groupName}');
      }

      final myGroupIds = myGroups.map((g) => g.id).toSet();
      final invitationGroupIds = invitationsRaw
          .map((inv) => inv.groupId)
          .toSet();

      final filteredAvailableGroups = allGroupsRaw.where((group) {
        final isMyGroup = myGroupIds.contains(group.id);
        final hasInvitation = invitationGroupIds.contains(group.id);
        final isAvailable = !isMyGroup && !hasInvitation;

        debugPrint('   Groupe ${group.id} (${group.name}):');
        debugPrint('      - Est mon groupe? $isMyGroup');
        debugPrint('      - A une invitation? $hasInvitation');
        debugPrint('      - → Disponible? $isAvailable');

        return isAvailable;
      }).toList();

      debugPrint('');
      debugPrint(' RÉSULTAT FINAL:');
      debugPrint('   IDs de mes groupes: ${myGroupIds.toList()}');
      debugPrint('   IDs avec invitation: ${invitationGroupIds.toList()}');
      debugPrint('   Groupes disponibles: ${filteredAvailableGroups.length}');
      for (var g in filteredAvailableGroups) {
        debugPrint('       ID: ${g.id}, Nom: ${g.name}');
      }
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      emit(
        GroupsLoaded(
          myGroups: myGroups,
          availableGroups: filteredAvailableGroups,
          invitations: invitationsRaw,
        ),
      );
    } catch (e, stack) {
      debugPrint(' [GroupBloc] LoadAll error: $e');
      debugPrint('Stack: $stack\n');
      emit(GroupError(message: 'Erreur chargement groupes: $e'));
    }
  }

  Future<void> _onLoadMyGroups(
    LoadMyGroupsEvent event,
    Emitter<GroupState> emit,
  ) async {
    add(LoadAllGroupsEvent());
  }

  Future<void> _onLoadAvailableGroups(
    LoadAvailableGroupsEvent event,
    Emitter<GroupState> emit,
  ) async {
    if (state is GroupsLoaded) {
      try {
        final groups = await repository.getAvailableGroups();
        final current = state as GroupsLoaded;
        emit(current.copyWith(availableGroups: groups));
      } catch (e) {
        debugPrint(' LoadAvailable error: $e');
      }
    } else {
      add(LoadAllGroupsEvent());
    }
  }

  Future<void> _onLoadInvitations(
    LoadInvitationsEvent event,
    Emitter<GroupState> emit,
  ) async {
    if (state is GroupsLoaded) {
      try {
        final invitations = await repository.getInvitations();
        final current = state as GroupsLoaded;
        emit(current.copyWith(invitations: invitations));
      } catch (e) {
        debugPrint(' LoadInvitations error: $e');
      }
    }
  }

  Future<void> _onLoadGroupDetails(
    LoadGroupDetailsEvent event,
    Emitter<GroupState> emit,
  ) async {
    emit(GroupLoading());
    try {
      debugPrint(' [GroupBloc] LOAD GROUP DETAILS: ${event.groupId}');


      final results = await Future.wait([
        repository.getGroupById(event.groupId),
        repository.getGroupPlanning(event.groupId),
        repository.getGroupMembers(event.groupId),
        repository.getReplacementRequests(event.groupId),
        repository.getAllReplacementRequests(event.groupId),
      ]);

      final group = results[0] as GroupModel;
      final plannings = results[1] as List<Planning>;
      final members = results[2] as List<GroupMember>;
      final replacementRequests = results[3] as List<Map<String, dynamic>>;
      final allReplacementRequests = results[4] as List<Map<String, dynamic>>;
      

      debugPrint(' Groupe chargé: ${group.name}');
      debugPrint(' ${plannings.length} plannings chargés');
      debugPrint(' ${members.length} membre(s) chargé(s)');
      debugPrint(' ${replacementRequests.length} demande(s) de remplacement');

      debugPrint('');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint(' [LoadGroupDetails] Enrichissement des plannings');

      final enrichedPlannings = plannings.map((planning) {
        final matchingRequest = replacementRequests.firstWhere(
          (req) =>
              req['calendar_id']?.toString() == planning.id &&
              req['status'] == 'pending',
          orElse: () => {},
        );

        if (matchingRequest.isNotEmpty) {
          debugPrint('   Planning ${planning.id} a une demande PENDING:');
          debugPrint(
            '      Demandeur: ${matchingRequest['requested_by_name']}',
          );
          debugPrint('      Motif: ${matchingRequest['reason']}');
          debugPrint('      Statut: ${matchingRequest['status']}');

          return planning.copyWith(
            needsReplacement: true,
            replacementReason: matchingRequest['reason']?.toString(),
            replacementRequesterId: matchingRequest['requested_by']?.toString(),
            replacementRequesterName: matchingRequest['requested_by_name']
                ?.toString(),
            replacementRequestId: matchingRequest['id']?.toString(),
            replacementAcceptedByName: matchingRequest['responded_by_name']
                ?.toString(),
          );
        }

        return planning.copyWith(needsReplacement: false);
      }).toList();

      debugPrint(
        '   Plannings avec demande: ${enrichedPlannings.where((p) => p.needsReplacement).length}',
      );
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      final fullyEnrichedPlannings = enrichedPlannings.map((planning) {
        final acceptedRequest = allReplacementRequests.firstWhere(
          (req) =>
              req['calendar_id']?.toString() == planning.id &&
              req['status'] == 'accepted',
          orElse: () => {},
        );

        if (acceptedRequest.isNotEmpty) {
          return planning.copyWith(
            replacementRequesterName: acceptedRequest['requested_by_name']
                ?.toString(),
            replacementAcceptedByName: acceptedRequest['responded_by_name']
                ?.toString(),
            replacementReason: acceptedRequest['reason']?.toString(),
            replacementRequestCreatedAt: acceptedRequest['created_at']
                ?.toString(),
          );
        }
        return planning;
      }).toList();

      final groupWithData = group.copyWith(
        plannings: fullyEnrichedPlannings,
        members: members,
      );

      emit(GroupDetailsLoaded(
  group: groupWithData,
  replacementHistory: allReplacementRequests, 
));
    } catch (e) {
      debugPrint(' Details error: $e');
      emit(GroupError(message: 'Erreur chargement groupe: $e'));
    }
  }

  Future<void> _onCreateGroup(
    CreateGroupEvent event,
    Emitter<GroupState> emit,
  ) async {
    emit(GroupLoading());
    try {
      debugPrint(' [GroupBloc] CREATE GROUP: ${event.name}');
      final group = await repository.createGroup(
        name: event.name,
        memberEmails: event.memberEmails,
        description: event.description,
      );
      debugPrint(' Groupe créé: ${group.id}');
      emit(GroupCreated(group: group));
      add(LoadAllGroupsEvent());
    } catch (e) {
      debugPrint(' Create error: $e');
      emit(GroupError(message: 'Erreur création groupe: $e'));
    }
  }

  Future<void> _onInviteMember(
    InviteMemberEvent event,
    Emitter<GroupState> emit,
  ) async {
    try {
      debugPrint(' [GroupBloc] INVITE MEMBER to ${event.groupId}');
      await repository.inviteMember(
        groupId: event.groupId,
        email: event.email,
        phone: event.phone,
      );
      debugPrint(' Invitation envoyée');
      emit(MemberInvited());
      add(LoadGroupDetailsEvent(event.groupId));
    } catch (e) {
      debugPrint(' Invite error: $e');
      String errorMessage = 'Erreur invitation';
      if (e.toString().contains('Aucun parent trouvé')) {
        errorMessage = 'Cet email ne correspond à aucun compte parent.';
      } else {
        errorMessage = e.toString();
      }
      emit(GroupError(message: errorMessage));
    }
  }

  Future<void> _onJoinGroup(
    JoinGroupEvent event,
    Emitter<GroupState> emit,
  ) async {
    try {
      debugPrint(' [GroupBloc] JOIN GROUP: ${event.groupId}');
      await repository.joinGroup(event.groupId);
      debugPrint(' Groupe rejoint');
      emit(GroupJoined(groupId: event.groupId));
      add(LoadAllGroupsEvent());
    } catch (e) {
      debugPrint(' Join error: $e');
      emit(GroupError(message: 'Erreur rejoindre groupe: $e'));
    }
  }

  Future<void> _onRespondToInvitation(
    RespondToInvitationEvent event,
    Emitter<GroupState> emit,
  ) async {
    try {
      debugPrint(
        ' [GroupBloc] RESPOND INVITATION ${event.invitationId}: ${event.accept}',
      );
      await repository.respondToInvitation(
        invitationId: event.invitationId,
        accept: event.accept,
      );
      debugPrint(' Réponse envoyée');
      emit(InvitationResponded(accepted: event.accept));
      add(LoadAllGroupsEvent());
    } catch (e) {
      debugPrint(' Respond error: $e');
      emit(GroupError(message: 'Erreur réponse invitation: $e'));
    }
  }

  Future<void> _onCreatePlanning(
    CreatePlanningEvent event,
    Emitter<GroupState> emit,
  ) async {
    emit(GroupLoading());
    try {
      debugPrint('[GroupBloc] CREATE PLANNING for ${event.groupId}');
      await repository.createPlanning(
        groupId: event.groupId,
        startDate: event.startDate,
        endDate: event.endDate,
      );
      debugPrint(' Planning créé');
      emit(PlanningCreated());
      add(LoadGroupDetailsEvent(event.groupId));
    } catch (e) {
      debugPrint(' Planning error: $e');
      emit(GroupError(message: 'Erreur planning: $e'));
    }
  }

  Future<void> _onConfirmPlanning(
    ConfirmPlanningEvent event,
    Emitter<GroupState> emit,
  ) async {
    String? groupId;
    if (state is GroupDetailsLoaded) {
      groupId = (state as GroupDetailsLoaded).group.id;
    }

    try {
      debugPrint('[GroupBloc] CONFIRM PLANNING: ${event.planningId}');
      await repository.confirmPlanning(planningId: event.planningId);
      debugPrint(' Planning confirmé');
      emit(PlanningConfirmed());

      if (groupId != null) {
        add(LoadGroupDetailsEvent(groupId));
      }
    } catch (e) {
      debugPrint(' Confirm error: $e');
      emit(GroupError(message: 'Erreur confirmation: $e'));
    }
  }

  Future<void> _onRequestReplacement(
    RequestReplacementEvent event,
    Emitter<GroupState> emit,
  ) async {
    try {
      debugPrint('[GroupBloc] REQUEST REPLACEMENT');
      debugPrint('   Planning ID: ${event.planning.id}');
      debugPrint('   Group ID: ${event.planning.groupId}');
      debugPrint('   Date: ${event.planning.date}');
      debugPrint('   Reason: ${event.reason}');

      await repository.requestReplacement(
        planning: event.planning,
        reason: event.reason,
      );
      emit(ReplacementRequested());

      add(LoadGroupDetailsEvent(event.planning.groupId));
    } catch (e) {
      debugPrint(' [GroupBloc] RequestReplacement error: $e');
      emit(GroupError(message: 'Erreur remplacement: $e'));
    }
  }

  Future<void> _onRespondToReplacement(
    RespondToReplacementEvent event,
    Emitter<GroupState> emit,
  ) async {
    String? groupId;
    if (state is GroupDetailsLoaded) {
      groupId = (state as GroupDetailsLoaded).group.id;
    }

    try {
      debugPrint('[GroupBloc] RESPOND TO REPLACEMENT: ${event.planningId}');
      debugPrint('   accept: ${event.accept}');

      await repository.respondToReplacement(
        planningId: event.planningId,
        accept: event.accept,
      );

      debugPrint(' Réponse envoyée');
      emit(ReplacementResponseSent(accepted: event.accept));

      if (groupId != null) {
        debugPrint(' Rechargement du groupe: $groupId');
        add(LoadGroupDetailsEvent(groupId));
      }
    } catch (e) {
      debugPrint(' Respond error: $e');
      emit(GroupError(message: 'Erreur réponse: $e'));
    }
  }

  Future<void> _onSelectGroupTab(
    SelectGroupTabEvent event,
    Emitter<GroupState> emit,
  ) async {
    if (state is GroupDetailsLoaded) {
      final current = state as GroupDetailsLoaded;
      emit(current.copyWith(selectedTabIndex: event.tabIndex));
    }
  }

  void _onSearchGroups(SearchGroupsEvent event, Emitter<GroupState> emit) {
    final currentState = state;
    if (currentState is! GroupsLoaded) return;

    final query = event.query.toLowerCase().trim();

    if (query.isEmpty) {
      emit(
        currentState.copyWith(
          filteredMyGroups: currentState.myGroups,
          filteredAvailableGroups: currentState.availableGroups,
          searchQuery: '',
        ),
      );
      return;
    }

    final filteredMy = currentState.myGroups.where((group) {
      return group.name.toLowerCase().contains(query) ||
          group.description?.toLowerCase().contains(query) == true;
    }).toList();

    final filteredAvailable = currentState.availableGroups.where((group) {
      return group.name.toLowerCase().contains(query) ||
          group.description?.toLowerCase().contains(query) == true;
    }).toList();

    emit(
      currentState.copyWith(
        filteredMyGroups: filteredMy,
        filteredAvailableGroups: filteredAvailable,
        searchQuery: query,
      ),
    );
  }
}
