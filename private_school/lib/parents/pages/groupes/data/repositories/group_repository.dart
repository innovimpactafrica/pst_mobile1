import '../models/group_model.dart';
import '../services/group_service.dart';
import 'package:flutter/foundation.dart';

class GroupRepository {
  final GroupService _groupService = GroupService();

  Future<List<GroupModel>> getMyGroups() async {
    try {
      return await _groupService.fetchMyGroups();
    } catch (e) {
      debugPrint('❌ Repository: getMyGroups - $e');
      throw Exception('Impossible de charger les groupes: $e');
    }
  }

  Future<List<GroupModel>> getAvailableGroups() async {
    try {
      return await _groupService.fetchAvailableGroups();
    } catch (e) {
      debugPrint('❌ Repository: getAvailableGroups - $e');
      throw Exception('Impossible de charger les groupes disponibles: $e');
    }
  }

  Future<GroupModel> getGroupById(String groupId) async {
    try {
      return await _groupService.fetchGroupById(groupId);
    } catch (e) {
      debugPrint('❌ Repository: getGroupById $groupId - $e');
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
      debugPrint('❌ Repository: createGroup - $e');
      throw Exception('Impossible de créer le groupe: $e');
    }
  }

  Future<GroupModel> updateGroup({required String groupId, String? name, String? description}) async {
    try {
      return await _groupService.updateGroup(groupId: groupId, name: name, description: description);
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

  Future<void> inviteMember({required String groupId, String? email, String? phone}) async {
    if ((email == null || email.isEmpty) && (phone == null || phone.isEmpty)) {
      throw Exception('Email ou téléphone requis');
    }
    try {
      await _groupService.inviteMember(groupId: groupId, email: email, phone: phone);
    } catch (e) {
      throw Exception('Impossible d\'inviter le membre: $e');
    }
  }

  /// ✅ GET /api/parents/carpool/invitations
  Future<List<GroupInvitation>> getInvitations() async {
    try {
      return await _groupService.fetchInvitationsTyped();
    } catch (e) {
      debugPrint('❌ Repository: getInvitations - $e');
      return []; // Ne pas bloquer l'UI si les invitations échouent
    }
  }

  /// ✅ PUT /api/parents/carpool/invitations — accepter ou refuser
  Future<void> respondToInvitation({required String invitationId, required bool accept}) async {
    try {
      await _groupService.respondToInvitation(invitationId: invitationId, accept: accept);
    } catch (e) {
      throw Exception('Impossible de répondre à l\'invitation: $e');
    }
  }

  /// ✅ "Rejoindre" = accepter l'invitation via PUT /api/parents/carpool/invitations
  Future<void> joinGroup(String groupId) async {
    try {
      debugPrint('🔵 [GroupRepository] joinGroup: $groupId');
      await _groupService.joinGroup(groupId: groupId);
    } catch (e) {
      debugPrint('❌ Repository: joinGroup - $e');
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

  Future<void> createPlanning({required String groupId, required DateTime startDate, required DateTime endDate}) async {
    try {
      DateTime current = startDate;
      while (current.isBefore(endDate) || current.isAtSameMomentAs(endDate)) {
        await _groupService.addToCalendar(groupId: groupId, date: current, assignedTo: 'Auto-assigné');
        current = current.add(const Duration(days: 1));
      }
    } catch (e) {
      throw Exception('Impossible de créer le planning: $e');
    }
  }

  Future<void> requestReplacement({required String planningId, required String reason}) async {
    try {
      await _groupService.proposeExchange(planningId: planningId, reason: reason);
    } catch (e) {
      throw Exception('Impossible de demander un remplacement: $e');
    }
  }

  Future<void> respondToReplacement({required String planningId, required bool accept}) async {
    try {
      await _groupService.respondToExchange(proposalId: planningId, accept: accept);
    } catch (e) {
      throw Exception('Impossible de répondre: $e');
    }
  }
}