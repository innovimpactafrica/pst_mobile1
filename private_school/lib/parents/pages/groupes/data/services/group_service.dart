/// Service pour gérer les appels API des groupes de covoiturage
/// Chemin: lib/parents/groupes/data/services/group_service.dart

import '../../../../../core/network/api_client.dart';
import '../../../../../core/utils/api_constants.dart';

import '../models/group_model.dart';

class GroupService {
  final ApiClient _apiClient = ApiClient();

  /// ✅ Récupérer mes groupes (groupes dont je suis membre)
  /// Endpoint: GET /api/parents/carpool/groups
  Future<List<GroupModel>> fetchMyGroups() async {
    try {
      print('🔍 Fetching my groups from API...');

      final response = await _apiClient.get(ApiConstants.carpoolGroups);

      print('✅ Response received: ${response.statusCode}');
      print('📦 Data: ${response.data}');

      // L'API peut retourner soit un tableau direct, soit { data: [...] }
      final List<dynamic> groupsData = response.data is List
          ? response.data
          : response.data['data'] ?? response.data['groups'] ?? [];

      final groups = groupsData
          .map((json) => GroupModel.fromJson(json as Map<String, dynamic>))
          .toList();

      print('✅ ${groups.length} groups loaded successfully');
      return groups;
    } catch (e) {
      print('❌ Error fetching groups: $e');
      throw Exception('Impossible de charger les groupes: $e');
    }
  }

  /// ✅ Récupérer les groupes disponibles (pour rejoindre)
  /// Note: Si l'API n'a pas d'endpoint spécifique, on filtre côté client
  Future<List<GroupModel>> fetchAvailableGroups() async {
    try {
      print('🔍 Fetching available groups from API...');

      // TODO: Vérifier si l'API a un endpoint spécifique pour les groupes disponibles
      // Pour l'instant, on utilise le même endpoint
      final response = await _apiClient.get(
        ApiConstants.carpoolGroups,
        queryParameters: {'available': true}, // Paramètre à vérifier avec le backend
      );

      print('✅ Response received: ${response.statusCode}');

      final List<dynamic> groupsData = response.data is List
          ? response.data
          : response.data['data'] ?? response.data['groups'] ?? [];

      final groups = groupsData
          .map((json) => GroupModel.fromJson(json as Map<String, dynamic>))
          .toList();

      print('✅ ${groups.length} available groups loaded');
      return groups;
    } catch (e) {
      print('❌ Error fetching available groups: $e');
      throw Exception('Impossible de charger les groupes disponibles: $e');
    }
  }

  /// ✅ Récupérer un groupe par son ID
  /// Endpoint: GET /api/parents/carpool/groups/{groupId}
  Future<GroupModel> fetchGroupById(String groupId) async {
    try {
      print('🔍 Fetching group with ID: $groupId');

      final response = await _apiClient.get(
        '${ApiConstants.carpoolGroups}/$groupId',
      );

      print('✅ Group details received');

      final groupData = response.data is Map
          ? (response.data['data'] ?? response.data)
          : response.data;

      return GroupModel.fromJson(groupData as Map<String, dynamic>);
    } catch (e) {
      print('❌ Error fetching group $groupId: $e');
      throw Exception('Impossible de charger les détails du groupe: $e');
    }
  }

  /// ✅ Créer un nouveau groupe
  /// Endpoint: POST /api/parents/carpool/groups
  Future<GroupModel> createGroup({
    required String name,
    String? description,
    List<String>? memberEmails,
  }) async {
    try {
      print('📤 Creating new group: $name');

      final response = await _apiClient.post(
        ApiConstants.carpoolGroups,
        data: {
          'name': name,
          'description': description,
          'members': memberEmails?.map((email) => {'email': email}).toList(),
        },
      );

      print('✅ Group created successfully');

      final groupData = response.data is Map
          ? (response.data['data'] ?? response.data)
          : response.data;

      return GroupModel.fromJson(groupData as Map<String, dynamic>);
    } catch (e) {
      print('❌ Error creating group: $e');
      throw Exception('Impossible de créer le groupe: $e');
    }
  }

  /// ✅ Modifier un groupe
  /// Endpoint: PUT /api/parents/carpool/groups
  Future<GroupModel> updateGroup({
    required String groupId,
    String? name,
    String? description,
  }) async {
    try {
      print('📝 Updating group: $groupId');

      final response = await _apiClient.put(
        ApiConstants.carpoolGroups,
        data: {
          'groupId': groupId,
          'name': name,
          'description': description,
        },
      );

      print('✅ Group updated successfully');

      final groupData = response.data is Map
          ? (response.data['data'] ?? response.data)
          : response.data;

      return GroupModel.fromJson(groupData as Map<String, dynamic>);
    } catch (e) {
      print('❌ Error updating group: $e');
      throw Exception('Impossible de modifier le groupe: $e');
    }
  }

  /// ✅ Supprimer un groupe
  /// Endpoint: DELETE /api/parents/carpool/groups
  Future<void> deleteGroup(String groupId) async {
    try {
      print('🗑️ Deleting group: $groupId');

      await _apiClient.delete(
        ApiConstants.carpoolGroups,
        data: {'groupId': groupId},
      );

      print('✅ Group deleted successfully');
    } catch (e) {
      print('❌ Error deleting group: $e');
      throw Exception('Impossible de supprimer le groupe: $e');
    }
  }

  /// ✅ Inviter un membre au groupe
  /// Endpoint: POST /api/parents/carpool/invitations
  Future<void> inviteMember({
    required String groupId,
    String? email,
    String? phone,
  }) async {
    try {
      print('📨 Inviting member to group: $groupId');

      final response = await _apiClient.post(
        ApiConstants.carpoolInvitations,
        data: {
          'groupId': groupId,
          'email': email,
          'phone': phone,
        },
      );

      print('✅ Invitation sent successfully');
    } catch (e) {
      print('❌ Error inviting member: $e');
      throw Exception('Impossible d\'inviter le membre: $e');
    }
  }

  /// ✅ Récupérer les invitations
  /// Endpoint: GET /api/parents/carpool/invitations
  Future<List<Map<String, dynamic>>> fetchInvitations() async {
    try {
      print('🔍 Fetching invitations from API...');

      final response = await _apiClient.get(ApiConstants.carpoolInvitations);

      print('✅ Invitations received');

      final List<dynamic> invitationsData = response.data is List
          ? response.data
          : response.data['data'] ?? response.data['invitations'] ?? [];

      return invitationsData.cast<Map<String, dynamic>>();
    } catch (e) {
      print('❌ Error fetching invitations: $e');
      throw Exception('Impossible de charger les invitations: $e');
    }
  }

  /// ✅ Répondre à une invitation
  /// Endpoint: PUT /api/parents/carpool/invitations
  Future<void> respondToInvitation({
    required String invitationId,
    required bool accept,
  }) async {
    try {
      print('📝 Responding to invitation: $invitationId (${accept ? "accept" : "decline"})');

      await _apiClient.put(
        ApiConstants.carpoolInvitations,
        data: {
          'invitationId': invitationId,
          'accept': accept,
        },
      );

      print('✅ Response sent successfully');
    } catch (e) {
      print('❌ Error responding to invitation: $e');
      throw Exception('Impossible de répondre à l\'invitation: $e');
    }
  }

  /// ✅ Récupérer le calendrier du groupe
  /// Endpoint: GET /api/parents/carpool/calendar
  Future<List<Planning>> fetchGroupCalendar(String groupId) async {
    try {
      print('📅 Fetching calendar for group: $groupId');

      final response = await _apiClient.get(
        ApiConstants.carpoolCalendar,
        queryParameters: {'groupId': groupId},
      );

      print('✅ Calendar received');

      final List<dynamic> calendarData = response.data is List
          ? response.data
          : response.data['data'] ?? response.data['calendar'] ?? [];

      return calendarData
          .map((json) => Planning.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('❌ Error fetching calendar: $e');
      throw Exception('Impossible de charger le calendrier: $e');
    }
  }

  /// ✅ Ajouter un trajet au calendrier
  /// Endpoint: POST /api/parents/carpool/calendar
  Future<Planning> addToCalendar({
    required String groupId,
    required DateTime date,
    required String assignedTo,
  }) async {
    try {
      print('📅 Adding to calendar: $date');

      final response = await _apiClient.post(
        ApiConstants.carpoolCalendar,
        data: {
          'groupId': groupId,
          'date': date.toIso8601String(),
          'assignedTo': assignedTo,
        },
      );

      print('✅ Added to calendar successfully');

      final planningData = response.data is Map
          ? (response.data['data'] ?? response.data)
          : response.data;

      return Planning.fromJson(planningData as Map<String, dynamic>);
    } catch (e) {
      print('❌ Error adding to calendar: $e');
      throw Exception('Impossible d\'ajouter au calendrier: $e');
    }
  }

  /// ✅ Modifier une entrée du calendrier
  /// Endpoint: PUT /api/parents/carpool/calendar
  Future<Planning> updateCalendar({
    required String calendarId,
    DateTime? date,
    String? assignedTo,
  }) async {
    try {
      print('📝 Updating calendar entry: $calendarId');

      final response = await _apiClient.put(
        ApiConstants.carpoolCalendar,
        data: {
          'calendarId': calendarId,
          'date': date?.toIso8601String(),
          'assignedTo': assignedTo,
        },
      );

      print('✅ Calendar updated successfully');

      final planningData = response.data is Map
          ? (response.data['data'] ?? response.data)
          : response.data;

      return Planning.fromJson(planningData as Map<String, dynamic>);
    } catch (e) {
      print('❌ Error updating calendar: $e');
      throw Exception('Impossible de modifier le calendrier: $e');
    }
  }

  /// ✅ Supprimer une entrée du calendrier
  /// Endpoint: DELETE /api/parents/carpool/calendar
  Future<void> deleteFromCalendar(String calendarId) async {
    try {
      print('🗑️ Deleting from calendar: $calendarId');

      await _apiClient.delete(
        ApiConstants.carpoolCalendar,
        data: {'calendarId': calendarId},
      );

      print('✅ Deleted from calendar successfully');
    } catch (e) {
      print('❌ Error deleting from calendar: $e');
      throw Exception('Impossible de supprimer du calendrier: $e');
    }
  }

  /// ✅ Proposer un échange
  /// Endpoint: POST /api/parents/carpool/conduite
  Future<void> proposeExchange({
    required String planningId,
    required String reason,
  }) async {
    try {
      print('🔄 Proposing exchange for planning: $planningId');

      await _apiClient.post(
        ApiConstants.carpoolConduite,
        data: {
          'planningId': planningId,
          'reason': reason,
        },
      );

      print('✅ Exchange proposed successfully');
    } catch (e) {
      print('❌ Error proposing exchange: $e');
      throw Exception('Impossible de proposer l\'échange: $e');
    }
  }

  /// ✅ Récupérer les propositions d'échange
  /// Endpoint: GET /api/parents/carpool/conduite
  Future<List<Map<String, dynamic>>> fetchExchangeProposals(String groupId) async {
    try {
      print('🔍 Fetching exchange proposals for group: $groupId');

      final response = await _apiClient.get(
        ApiConstants.carpoolConduite,
        queryParameters: {'groupId': groupId},
      );

      print('✅ Exchange proposals received');

      final List<dynamic> proposalsData = response.data is List
          ? response.data
          : response.data['data'] ?? response.data['proposals'] ?? [];

      return proposalsData.cast<Map<String, dynamic>>();
    } catch (e) {
      print('❌ Error fetching exchange proposals: $e');
      throw Exception('Impossible de charger les propositions: $e');
    }
  }

  /// ✅ Répondre à une proposition d'échange
  /// Endpoint: PUT /api/parents/carpool/conduite
  Future<void> respondToExchange({
    required String proposalId,
    required bool accept,
  }) async {
    try {
      print('📝 Responding to exchange: $proposalId');

      await _apiClient.put(
        ApiConstants.carpoolConduite,
        data: {
          'proposalId': proposalId,
          'accept': accept,
        },
      );

      print('✅ Response sent successfully');
    } catch (e) {
      print('❌ Error responding to exchange: $e');
      throw Exception('Impossible de répondre à la proposition: $e');
    }
  }
}