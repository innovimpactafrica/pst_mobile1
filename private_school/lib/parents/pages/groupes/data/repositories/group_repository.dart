import '../models/group_model.dart';
import '../services/group_service.dart';
import 'package:flutter/foundation.dart';

class GroupRepository {
  final GroupService _groupService = GroupService();

  Future<List<GroupModel>> getMyGroups() async {
    try {
      return await _groupService.fetchMyGroups();
    } catch (e) {
      debugPrint(' Repository: getMyGroups - $e');
      throw Exception('Impossible de charger les groupes: $e');
    }
  }

  Future<List<GroupModel>> getAvailableGroups() async {
    try {
      return await _groupService.fetchAvailableGroups();
    } catch (e) {
      debugPrint(' Repository: getAvailableGroups - $e');
      throw Exception('Impossible de charger les groupes disponibles: $e');
    }
  }

  Future<GroupModel> getGroupById(String groupId) async {
    try {
      return await _groupService.fetchGroupById(groupId);
    } catch (e) {
      debugPrint(' Repository: getGroupById $groupId - $e');
      throw Exception('Impossible de charger le groupe: $e');
    }
  }

  Future<GroupModel> getGroupDetails(String groupId) => getGroupById(groupId);

  Future<GroupModel> createGroup({
    required String name,
    required List<String> memberEmails,
    String? description,
    String? schoolId,
  }) async {
    try {
      return await _groupService.createGroup(
        name: name,
        description: description,
        memberEmails: memberEmails,
        schoolId: schoolId,
      );
    } catch (e) {
      debugPrint(' Repository: createGroup - $e');
      throw Exception('Impossible de créer le groupe: $e');
    }
  }

  Future<GroupModel> updateGroup({
    required String groupId,
    String? name,
    String? description,
  }) async {
    try {
      return await _groupService.updateGroup(
        groupId: groupId,
        name: name,
        description: description,
      );
    } catch (e) {
      throw Exception('Impossible de modifier le groupe: $e');
    }
  }

  Future<void> deleteGroup(String groupId) async {
    try {
      await _groupService.deleteGroup(groupId);
    } catch (e) {
      throw Exception('Impossible de supprimer le groupe: $e');
    }
  }

  Future<void> inviteMember({
    required String groupId,
    String? email,
    String? phone,
  }) async {
    if ((email == null || email.isEmpty) && (phone == null || phone.isEmpty)) {
      throw Exception('Email ou téléphone requis');
    }
    try {
      await _groupService.inviteMember(
        groupId: groupId,
        email: email,
        phone: phone,
      );
    } catch (e) {
      throw Exception('Impossible d\'inviter le membre: $e');
    }
  }

  Future<List<GroupMember>> getGroupMembers(String groupId) async {
    return await _groupService.fetchGroupMembers(groupId);
  }

  Future<List<GroupInvitation>> getInvitations() async {
    try {
      return await _groupService.fetchInvitationsTyped();
    } catch (e) {
      debugPrint(' Repository: getInvitations - $e');
      return [];
    }
  }

  Future<void> respondToInvitation({
    required String invitationId,
    required bool accept,
  }) async {
    try {
      await _groupService.respondToInvitation(
        invitationId: invitationId,
        accept: accept,
      );
    } catch (e) {
      throw Exception('Impossible de répondre à l\'invitation: $e');
    }
  }

  Future<void> joinGroup(String groupId) async {
    try {
      debugPrint(' [GroupRepository] joinGroup: $groupId');
      await _groupService.joinGroup(groupId: groupId);
    } catch (e) {
      debugPrint(' Repository: joinGroup - $e');
      throw Exception('Impossible de rejoindre le groupe: $e');
    }
  }

  Future<List<Planning>> getGroupCalendar(String groupId) async {
    try {
      return await _groupService.fetchGroupCalendar(groupId);
    } catch (e) {
      throw Exception('Impossible de charger le calendrier: $e');
    }
  }

  Future<List<Planning>> getGroupPlanning(String groupId) async {
    try {
      return await _groupService.fetchGroupCalendar(groupId);
    } catch (e) {
      throw Exception('Impossible de charger le planning: $e');
    }
  }

  Future<void> createPlanning({
    required String groupId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      await _groupService.createGroupPlanning(
        groupId: groupId,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      throw Exception('Impossible de créer le planning: $e');
    }
  }

  Future<void> confirmPlanning({required String planningId}) async {
    try {
      await _groupService.confirmCalendar(calendarId: planningId);
    } catch (e) {
      throw Exception('Impossible de confirmer le planning: $e');
    }
  }

  Future<void> requestReplacement({
    required Planning planning,
    required String reason,
  }) async {
    try {
      debugPrint('🔄 [GroupRepository] requestReplacement');
      debugPrint('   planningId: ${planning.id}');
      debugPrint('   groupId: ${planning.groupId}');
      debugPrint('   date: ${planning.date}');
      debugPrint('   reason: $reason');

      await _groupService.proposeExchange(planning: planning, reason: reason);
    } catch (e) {
      debugPrint(' [GroupRepository] requestReplacement error: $e');
      throw Exception('Impossible de demander un remplacement: $e');
    }
  }

  Future<void> respondToReplacement({
    required String planningId,
    required bool accept,
  }) async {
    try {
      debugPrint(' [GroupRepository] respondToReplacement');
      debugPrint('   planningId: $planningId');
      debugPrint('   accept: $accept');

      await _groupService.respondToExchange(
        proposalId: planningId,
        accept: accept,
      );

      debugPrint(' [GroupRepository] Réponse envoyée');
    } catch (e) {
      debugPrint(' [GroupRepository] respondToReplacement error: $e');
      throw Exception('Impossible de répondre: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getReplacementRequests(
    String groupId,
  ) async {
    try {
      debugPrint('[GroupRepository] getReplacementRequests: $groupId');
      return await _groupService.fetchReplacementRequests(groupId);
    } catch (e) {
      debugPrint(' [GroupRepository] getReplacementRequests error: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getAllReplacementRequests(
    String groupId,
  ) async {
    try {
      return await _groupService.fetchAllReplacementRequests(groupId);
    } catch (e) {
      debugPrint(' [GroupRepository] getAllReplacementRequests error: $e');
      return [];
    }
  }
}
