import 'package:flutter/foundation.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/utils/api_constants.dart';
import '../models/group_model.dart';

class GroupService {
  final ApiClient _apiClient = ApiClient();

  // ─────────────────────────────────────────────
  // GET /api/parents/carpool/groups — Mes groupes
  // ─────────────────────────────────────────────
  Future<List<GroupModel>> fetchMyGroups() async {
    try {
      debugPrint('🔍 [GroupService] GET /api/parents/carpool/groups');
      final response = await _apiClient.get(ApiConstants.carpoolGroups);
      debugPrint('✅ [GroupService] Response: ${response.statusCode}');

      final List<dynamic> data = _extractList(response.data, ['data', 'groups']);
      final groups = data
          .map((json) => GroupModel.fromJson(json as Map<String, dynamic>))
          .toList();

      debugPrint('✅ [GroupService] ${groups.length} my groups loaded');
      return groups;
    } catch (e) {
      debugPrint('❌ [GroupService] fetchMyGroups error: $e');
      throw Exception('Unable to load groups: $e');
    }
  }

  // ─────────────────────────────────────────────
  // GET /api/parents/carpool/groups?available=true
  // ─────────────────────────────────────────────
  Future<List<GroupModel>> fetchAvailableGroups() async {
    try {
      debugPrint('🔍 [GroupService] GET /api/parents/carpool/groups?available=true');
      final response = await _apiClient.get(
        ApiConstants.carpoolGroups,
        queryParameters: {'available': true},
      );

      final List<dynamic> data = _extractList(response.data, ['data', 'groups']);
      final groups = data
          .map((json) => GroupModel.fromJson(json as Map<String, dynamic>))
          .toList();

      debugPrint('✅ [GroupService] ${groups.length} available groups loaded');
      return groups;
    } catch (e) {
      debugPrint('❌ [GroupService] fetchAvailableGroups error: $e');
      throw Exception('Unable to load available groups: $e');
    }
  }


  // Ajoute exactement ce bloc :
  Future<GroupModel> fetchGroupById(String groupId) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.carpoolGroups,
        queryParameters: {'groupId': groupId},
      );

      final List<dynamic> dataList = _extractList(response.data, ['data', 'groups']);
      
      if (dataList.isNotEmpty) {
        return GroupModel.fromJson(dataList.first as Map<String, dynamic>);
      } else {
        throw Exception('Groupe non trouvé');
      }
    } catch (e) {
      throw Exception('Unable to load group: $e');
    }
  }

 
 Future<GroupModel> createGroup({
    required String name,
    String? description,
    List<String>? memberEmails,
    String? schoolId,
  }) async {
    try {
      debugPrint('📤 [GroupService] POST /api/parents/carpool/groups: $name');
      final response = await _apiClient.post(
        ApiConstants.carpoolGroups,
        data: {
          'name': name,
          if (description != null) 'description': description,
          if (schoolId != null) 'school_id': schoolId,
          if (memberEmails != null && memberEmails.isNotEmpty)
            'members': memberEmails.map((e) => {'email': e}).toList(),
        },
      );

      // On récupère les données de manière sécurisée
      final dynamic rawData = response.data['data'] ?? response.data;
      
      // Si l'API renvoie une liste, on prend le premier, sinon on prend l'objet
      if (rawData is List) {
        return GroupModel.fromJson(rawData.first as Map<String, dynamic>);
      } else {
        return GroupModel.fromJson(rawData as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint('❌ [GroupService] createGroup error: $e');
      throw Exception('Unable to create group: $e');
    }
  }

  // ─────────────────────────────────────────────
  // PUT /api/parents/carpool/groups — Modifier
  // ─────────────────────────────────────────────
  Future<GroupModel> updateGroup({
    required String groupId,
    String? name,
    String? description,
  }) async {
    try {
      final response = await _apiClient.put(
        ApiConstants.carpoolGroups,
        data: {
          'groupId': groupId,
          if (name != null) 'name': name,
          if (description != null) 'description': description,
        },
      );
      final groupData = response.data is Map
          ? (response.data['data'] ?? response.data)
          : response.data;
      return GroupModel.fromJson(groupData as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Unable to update group: $e');
    }
  }

  // ─────────────────────────────────────────────
  // DELETE /api/parents/carpool/groups
  // ─────────────────────────────────────────────
  Future<void> deleteGroup(String groupId) async {
    try {
      await _apiClient.delete(ApiConstants.carpoolGroups, data: {'groupId': groupId});
    } catch (e) {
      throw Exception('Unable to delete group: $e');
    }
  }

  // ─────────────────────────────────────────────
  // GET /api/parents/carpool/invitations — Invitations typées
  // ─────────────────────────────────────────────
  Future<List<GroupInvitation>> fetchInvitationsTyped() async {
    try {
      debugPrint('🔍 [GroupService] GET /api/parents/carpool/invitations');
      // Ajout obligatoire du paramètre type=received pour le backend
      final response = await _apiClient.get(
        ApiConstants.carpoolInvitations,
        queryParameters: {'type': 'received'}, 
      );

      final List<dynamic> data = _extractList(response.data, ['data', 'invitations']);
      final invitations = data
          .map((json) => GroupInvitation.fromJson(json as Map<String, dynamic>))
          .where((inv) => inv.status == 'pending')
          .toList();

      debugPrint('✅ [GroupService] ${invitations.length} pending invitations');
      return invitations;
    } catch (e) {
      debugPrint('❌ [GroupService] fetchInvitations error: $e');
      return [];
    }
  }

  // Compatibilité ancienne méthode
  Future<List<Map<String, dynamic>>> fetchInvitations() async {
    try {
      final response = await _apiClient.get(ApiConstants.carpoolInvitations);
      final List<dynamic> data = _extractList(response.data, ['data', 'invitations']);
      return data.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  // ─────────────────────────────────────────────
  // POST /api/parents/carpool/invitations — Inviter une famille
  // ─────────────────────────────────────────────
Future<void> inviteMember({
    required String groupId,
    String? email,
    String? phone,
  }) async {
    try {
      await _apiClient.post(
        ApiConstants.carpoolInvitations,
        data: {
          'group_id': groupId, // Changé groupId -> group_id
          if (email != null) 'parent_email': email, // Changé email -> parent_email
          if (phone != null) 'phone': phone,
        },
      );
    } catch (e) {
      throw Exception('Unable to invite member: $e');
    }
  }

  // ─────────────────────────────────────────────
  // PUT /api/parents/carpool/invitations — Répondre à invitation
  // ─────────────────────────────────────────────
Future<void> respondToInvitation({
    required String invitationId,
    required bool accept,
  }) async {
    try {
      await _apiClient.put(
        ApiConstants.carpoolInvitations,
        data: {
          'invitation_id': invitationId, // Changé invitationId -> invitation_id
          'action': accept ? 'accept' : 'decline', // Changé accept (bool) -> action (string)
        },
      );
    } catch (e) {
      throw Exception('Unable to respond: $e');
    }
  }

  // ─────────────────────────────────────────────
  // ✅ joinGroup — PUT /api/parents/carpool/invitations avec accept=true
  // Rejoindre un groupe disponible = accepter automatiquement
  // ─────────────────────────────────────────────
  Future<void> joinGroup({required String groupId}) async {
    try {
      debugPrint('🔵 [GroupService] JOIN GROUP: $groupId');
      debugPrint('   PUT /api/parents/carpool/invitations {groupId: $groupId, accept: true}');
      await _apiClient.put(
        ApiConstants.carpoolInvitations,
        data: {'groupId': groupId, 'accept': true},
      );
      debugPrint('✅ [GroupService] Joined group');
    } catch (e) {
      debugPrint('❌ [GroupService] joinGroup error: $e');
      throw Exception('Unable to join group: $e');
    }
  }

  // ─────────────────────────────────────────────
  // CALENDRIER
  // ─────────────────────────────────────────────
  Future<List<Planning>> fetchGroupCalendar(String groupId) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.carpoolCalendar,
        queryParameters: {'groupId': groupId},
      );
      final List<dynamic> data = _extractList(response.data, ['data', 'calendar']);
      return data.map((json) => Planning.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Unable to load calendar: $e');
    }
  }

  Future<Planning> addToCalendar({
    required String groupId,
    required DateTime date,
    required String assignedTo,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.carpoolCalendar,
        data: {'groupId': groupId, 'date': date.toIso8601String(), 'assignedTo': assignedTo},
      );
      final data = response.data is Map ? (response.data['data'] ?? response.data) : response.data;
      return Planning.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Unable to add to calendar: $e');
    }
  }

  Future<Planning> updateCalendar({required String calendarId, DateTime? date, String? assignedTo}) async {
    try {
      final response = await _apiClient.put(
        ApiConstants.carpoolCalendar,
        data: {'calendarId': calendarId, if (date != null) 'date': date.toIso8601String(), if (assignedTo != null) 'assignedTo': assignedTo},
      );
      final data = response.data is Map ? (response.data['data'] ?? response.data) : response.data;
      return Planning.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Unable to update calendar: $e');
    }
  }

  Future<void> deleteFromCalendar(String calendarId) async {
    await _apiClient.delete(ApiConstants.carpoolCalendar, data: {'calendarId': calendarId});
  }

  // ─────────────────────────────────────────────
  // ÉCHANGES / REMPLACEMENTS
  // ─────────────────────────────────────────────
  Future<void> proposeExchange({required String planningId, required String reason}) async {
    try {
      await _apiClient.post(ApiConstants.carpoolConduite, data: {'planningId': planningId, 'reason': reason});
    } catch (e) {
      throw Exception('Unable to propose exchange: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchExchangeProposals(String groupId) async {
    try {
      final response = await _apiClient.get(ApiConstants.carpoolConduite, queryParameters: {'groupId': groupId});
      final List<dynamic> data = _extractList(response.data, ['data', 'proposals']);
      return data.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  Future<void> respondToExchange({required String proposalId, required bool accept}) async {
    try {
      await _apiClient.put(ApiConstants.carpoolConduite, data: {'proposalId': proposalId, 'accept': accept});
    } catch (e) {
      throw Exception('Unable to respond to exchange: $e');
    }
  }

  // ─────────────────────────────────────────────
  // HELPER — extraire liste depuis réponse API
  // ─────────────────────────────────────────────
  List<dynamic> _extractList(dynamic responseData, List<String> keys) {
    if (responseData is List) return responseData;
    if (responseData is Map) {
      for (final key in keys) {
        if (responseData[key] is List) return responseData[key];
      }
    }
    return [];
  }
}