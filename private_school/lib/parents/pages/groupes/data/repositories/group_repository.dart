/// Repository pour gérer la logique métier des groupes
/// Chemin: lib/parents/groupes/data/repositories/group_repository.dart

import '../models/group_model.dart';
import '../services/group_service.dart';

class GroupRepository {
  final GroupService _groupService = GroupService();

  /// ========== MÉTHODES POUR LES LISTES ==========

  /// Récupérer mes groupes (groupes dont je suis membre)
  Future<List<GroupModel>> getMyGroups() async {
    try {
      return await _groupService.fetchMyGroups();
    } catch (e) {
      print('❌ Repository: Failed to load groups - $e');
      throw Exception('Impossible de charger les groupes: $e');
    }
  }

  /// Récupérer les groupes disponibles (pour rejoindre)
  Future<List<GroupModel>> getAvailableGroups() async {
    try {
      return await _groupService.fetchAvailableGroups();
    } catch (e) {
      print('❌ Repository: Failed to load available groups - $e');
      throw Exception('Impossible de charger les groupes disponibles: $e');
    }
  }

  /// ========== MÉTHODES POUR UN GROUPE SPÉCIFIQUE ==========

  /// Récupérer un groupe par son ID
  Future<GroupModel> getGroupById(String groupId) async {
    try {
      return await _groupService.fetchGroupById(groupId);
    } catch (e) {
      print('❌ Repository: Failed to load group $groupId - $e');
      throw Exception('Impossible de charger le groupe: $e');
    }
  }

  /// Alias pour getGroupById (pour compatibilité avec le BLoC)
  Future<GroupModel> getGroupDetails(String groupId) async {
    return getGroupById(groupId);
  }

  /// ========== MÉTHODES DE CRÉATION ==========

  /// Créer un nouveau groupe
  Future<GroupModel> createGroup({
    required String name,
    required List<String> memberEmails,
    String? description,
  }) async {
    try {
      return await _groupService.createGroup(
        name: name,
        description: description,
        memberEmails: memberEmails,
      );
    } catch (e) {
      print('❌ Repository: Failed to create group - $e');
      throw Exception('Impossible de créer le groupe: $e');
    }
  }

  /// Modifier un groupe
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
      print('❌ Repository: Failed to update group - $e');
      throw Exception('Impossible de modifier le groupe: $e');
    }
  }

  /// Supprimer un groupe
  Future<void> deleteGroup(String groupId) async {
    try {
      await _groupService.deleteGroup(groupId);
    } catch (e) {
      print('❌ Repository: Failed to delete group - $e');
      throw Exception('Impossible de supprimer le groupe: $e');
    }
  }

  /// ========== MÉTHODES POUR LES MEMBRES ==========

  /// Inviter un membre au groupe (par email OU téléphone)
  Future<void> inviteMember({
    required String groupId,
    String? email,
    String? phone,
  }) async {
    try {
      // Validation : au moins un des deux doit être fourni
      if ((email == null || email.isEmpty) && (phone == null || phone.isEmpty)) {
        throw Exception('Email ou téléphone requis');
      }

      await _groupService.inviteMember(
        groupId: groupId,
        email: email,
        phone: phone,
      );
    } catch (e) {
      print('❌ Repository: Failed to invite member - $e');
      throw Exception('Impossible d\'inviter le membre: $e');
    }
  }

  /// Récupérer les invitations
  Future<List<Map<String, dynamic>>> getInvitations() async {
    try {
      return await _groupService.fetchInvitations();
    } catch (e) {
      print('❌ Repository: Failed to load invitations - $e');
      throw Exception('Impossible de charger les invitations: $e');
    }
  }

  /// Répondre à une invitation
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
      print('❌ Repository: Failed to respond to invitation - $e');
      throw Exception('Impossible de répondre à l\'invitation: $e');
    }
  }

  /// Rejoindre un groupe (accepter une invitation)
  Future<void> joinGroup(String groupId) async {
    try {
      // TODO: Implémenter la logique de rejoindre un groupe
      // Pour l'instant, on considère que c'est équivalent à accepter une invitation
      print('⚠️ joinGroup not yet implemented via API');
      throw UnimplementedError('Fonctionnalité à implémenter avec le backend');
    } catch (e) {
      print('❌ Repository: Failed to join group - $e');
      throw Exception('Impossible de rejoindre le groupe: $e');
    }
  }

  /// ========== MÉTHODES POUR LES PLANNINGS ==========

  /// Récupérer le calendrier d'un groupe
  Future<List<Planning>> getGroupCalendar(String groupId) async {
    try {
      return await _groupService.fetchGroupCalendar(groupId);
    } catch (e) {
      print('❌ Repository: Failed to load calendar - $e');
      throw Exception('Impossible de charger le calendrier: $e');
    }
  }

  /// Créer un planning pour le groupe
  Future<void> createPlanning({
    required String groupId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // Créer un planning pour chaque jour entre startDate et endDate
      DateTime currentDate = startDate;

      while (currentDate.isBefore(endDate) || currentDate.isAtSameMomentAs(endDate)) {
        await _groupService.addToCalendar(
          groupId: groupId,
          date: currentDate,
          assignedTo: 'Auto-assigné', // À définir selon la logique métier
        );

        currentDate = currentDate.add(const Duration(days: 1));
      }
    } catch (e) {
      print('❌ Repository: Failed to create planning - $e');
      throw Exception('Impossible de créer le planning: $e');
    }
  }

  /// Créer un planning simple (avec objet Planning)
  Future<Planning> createPlanningWithObject({
    required String groupId,
    required Planning planning,
  }) async {
    try {
      return await _groupService.addToCalendar(
        groupId: groupId,
        date: planning.date,
        assignedTo: planning.assignedTo,
      );
    } catch (e) {
      print('❌ Repository: Failed to create planning - $e');
      throw Exception('Impossible de créer le planning: $e');
    }
  }

  /// Confirmer un planning
  Future<Planning> confirmPlanning({
    required String groupId,
    required String planningId,
  }) async {
    try {
      return await _groupService.updateCalendar(
        calendarId: planningId,
      );
    } catch (e) {
      print('❌ Repository: Failed to confirm planning - $e');
      throw Exception('Impossible de confirmer le planning: $e');
    }
  }

  /// ========== MÉTHODES POUR LES REMPLACEMENTS ==========

  /// Demander un remplacement pour un planning
  Future<void> requestReplacement({
    required String planningId,
    required String reason,
  }) async {
    try {
      await _groupService.proposeExchange(
        planningId: planningId,
        reason: reason,
      );
    } catch (e) {
      print('❌ Repository: Failed to request replacement - $e');
      throw Exception('Impossible de demander un remplacement: $e');
    }
  }

  /// Récupérer les propositions d'échange
  Future<List<Map<String, dynamic>>> getExchangeProposals(String groupId) async {
    try {
      return await _groupService.fetchExchangeProposals(groupId);
    } catch (e) {
      print('❌ Repository: Failed to load exchange proposals - $e');
      throw Exception('Impossible de charger les propositions: $e');
    }
  }

  /// Répondre à une demande de remplacement
  Future<void> respondToReplacement({
    required String planningId,
    required bool accept,
  }) async {
    try {
      await _groupService.respondToExchange(
        proposalId: planningId,
        accept: accept,
      );
    } catch (e) {
      print('❌ Repository: Failed to respond to replacement - $e');
      throw Exception('Impossible de répondre à la demande: $e');
    }
  }
}