import 'package:flutter/foundation.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/utils/api_constants.dart';
import '../models/group_model.dart';

class GroupService {
  final ApiClient _apiClient = ApiClient();

  // ─────────────────────────────────────────────
  // Mes groupes
  // ─────────────────────────────────────────────
  Future<List<GroupModel>> fetchMyGroups() async {
    try {
      debugPrint(' [GroupService] GET /api/parents/carpool/groups');
      final response = await _apiClient.get(ApiConstants.carpoolGroups);
      debugPrint(' [GroupService] Response: ${response.statusCode}');

      final List<dynamic> data = _extractList(response.data, [
        'data',
        'groups',
      ]);

      debugPrint('');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint(' [fetchMyGroups] ANALYSE DES GROUPES REÇUS');
      debugPrint('   Total brut: ${data.length}');

      final filteredData = data.where((json) {
        final status = json['membership_status']?.toString();
        final isCreator = json['is_creator'] == true;
        final groupId = json['id'];
        final groupName = json['name'];
        final isValid = status == 'accepted' || isCreator;

        debugPrint('   Group $groupId: $groupName');
        debugPrint('      membership_status: "$status"');
        debugPrint('      is_creator: $isCreator');
        debugPrint(
          '      → ${isValid ? "✅ INCLUS (membre valide)" : "❌ EXCLU (pas membre)"}',
        );

        return isValid;
      }).toList();

      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint(' RÉSULTAT FINAL:');
      debugPrint('   Groupes valides: ${filteredData.length}');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      final groups = filteredData
          .map((json) => GroupModel.fromJson(json as Map<String, dynamic>))
          .toList();

      return groups;
    } catch (e) {
      debugPrint(' [GroupService] fetchMyGroups error: $e');
      throw Exception('Unable to load groups: $e');
    }
  }

  Future<List<GroupModel>> fetchAvailableGroups() async {
    try {
      debugPrint('🔍 [GroupService] GET /api/parents/carpool/groups/available');

      final response = await _apiClient.get(
        '${ApiConstants.carpoolGroups}/available',
      );

      final List<dynamic> data = _extractList(response.data, [
        'data',
        'groups',
      ]);

      debugPrint('');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint(' [fetchAvailableGroups] GROUPES DISPONIBLES');
      debugPrint('   Total: ${data.length}');

      final groups = data
          .map((json) => GroupModel.fromJson(json as Map<String, dynamic>))
          .toList();

      debugPrint('   Groupes disponibles: ${groups.length}');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      return groups;
    } catch (e) {
      debugPrint(' [GroupService] fetchAvailableGroups error: $e');
      throw Exception('Unable to load available groups: $e');
    }
  }

  Future<GroupModel> fetchGroupById(String groupId) async {
    try {
      debugPrint(' [GroupService] GET GROUP BY ID: $groupId');

      final response = await _apiClient.get(
        ApiConstants.carpoolGroups,
        queryParameters: {'groupId': groupId},
      );

      final List<dynamic> dataList = _extractList(response.data, [
        'data',
        'groups',
      ]);

      debugPrint(' Groupes reçus: ${dataList.length}');
      for (var json in dataList) {
        debugPrint('   - ID: ${json['id']}, Nom: ${json['name']}');
      }

      final matchingGroup = dataList.firstWhere(
        (json) => json['id'].toString() == groupId,
        orElse: () =>
            throw Exception('Groupe $groupId non trouvé dans la réponse'),
      );

      debugPrint(
        ' Groupe trouvé: ${matchingGroup['name']} (ID: ${matchingGroup['id']})',
      );

      return GroupModel.fromJson(matchingGroup as Map<String, dynamic>);
    } catch (e) {
      debugPrint(' [GroupService] fetchGroupById error: $e');
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
      debugPrint(' [GroupService] POST /api/parents/carpool/groups: $name');
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

      final dynamic rawData = response.data['data'] ?? response.data;

      if (rawData is List) {
        return GroupModel.fromJson(rawData.first as Map<String, dynamic>);
      } else {
        return GroupModel.fromJson(rawData as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint(' [GroupService] createGroup error: $e');
      throw Exception('Unable to create group: $e');
    }
  }

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

  Future<void> deleteGroup(String groupId) async {
    try {
      await _apiClient.delete(
        ApiConstants.carpoolGroups,
        data: {'groupId': groupId},
      );
    } catch (e) {
      throw Exception('Unable to delete group: $e');
    }
  }

  Future<List<GroupInvitation>> fetchInvitationsTyped() async {
    try {
      debugPrint('🔍 [GroupService] GET /api/parents/carpool/invitations');
      final response = await _apiClient.get(
        ApiConstants.carpoolInvitations,
        queryParameters: {'type': 'received'},
      );

      final List<dynamic> data = _extractList(response.data, [
        'data',
        'invitations',
      ]);
      final invitations = data
          .map((json) => GroupInvitation.fromJson(json as Map<String, dynamic>))
          .where((inv) => inv.status == 'pending')
          .toList();

      debugPrint(' [GroupService] ${invitations.length} pending invitations');
      return invitations;
    } catch (e) {
      debugPrint(' [GroupService] fetchInvitations error: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchInvitations() async {
    try {
      final response = await _apiClient.get(ApiConstants.carpoolInvitations);
      final List<dynamic> data = _extractList(response.data, [
        'data',
        'invitations',
      ]);
      return data.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  Future<void> inviteMember({
    required String groupId,
    String? email,
    String? phone,
  }) async {
    try {
      await _apiClient.post(
        ApiConstants.carpoolInvitations,
        data: {
          'group_id': int.tryParse(groupId) ?? groupId,
          if (email != null) 'parent_email': email.trim(),
          if (phone != null) 'phone': phone.trim(),
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> respondToInvitation({
    required String invitationId,
    required bool accept,
  }) async {
    try {
      await _apiClient.put(
        ApiConstants.carpoolInvitations,
        data: {
          'invitation_id': invitationId,
          'action': accept ? 'accept' : 'decline',
        },
      );
    } catch (e) {
      throw Exception('Unable to respond: $e');
    }
  }

  Future<void> joinGroup({required String groupId}) async {
    try {
      debugPrint('🔵 [GroupService] JOIN GROUP (adhésion directe): $groupId');

      await _apiClient.put(
        ApiConstants.carpoolInvitations,
        data: {'groupId': int.tryParse(groupId) ?? groupId, 'action': 'accept'},
      );

      debugPrint(' [GroupService] Groupe rejoint avec succès');
    } catch (e) {
      debugPrint(' [GroupService] joinGroup error: $e');
      throw Exception('Unable to join group: $e');
    }
  }

  Future<List<Planning>> fetchGroupCalendar(String groupId) async {
    try {
      debugPrint(
        '🔍 [GroupService] GET /api/parents/carpool/groups/$groupId/planning',
      );

      final response = await _apiClient.get(
        '${ApiConstants.carpoolGroups}/$groupId/planning',
      );

      final dynamic responseBody = response.data;
      List<dynamic> data = [];

      if (responseBody is Map && responseBody['data'] is Map) {
        data = (responseBody['data']['assignments'] as List?) ?? [];
      } else {
        data = _extractList(responseBody, [
          'data',
          'assignments',
          'planning',
          'calendar',
        ]);
      }

      debugPrint(' [GroupService] ${data.length} plannings chargés');

      for (var p in data) {
        debugPrint('   - ID: ${p['id']}, Date: ${p['date']}');
        debugPrint('     driver_id: ${p['driver_id']}');
        debugPrint('     assigned_to_name: ${p['assigned_to_name']}');
        debugPrint('     is_my_turn: ${p['is_my_turn']}');
        debugPrint('     confirmation_status: ${p['confirmation_status']}');
      }

      return data
          .map((json) => Planning.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint(' [GroupService] fetchGroupCalendar error: $e');
      throw Exception('Unable to load calendar: $e');
    }
  }

  Future<List<GroupMember>> fetchGroupMembers(String groupId) async {
    try {
      debugPrint(
        '🔍 [GroupService] GET /api/parents/carpool/groups/$groupId/members',
      );

      final response = await _apiClient.get(
        '${ApiConstants.carpoolGroups}/$groupId/members',
      );

      debugPrint(' Response status: ${response.statusCode}');

      final dynamic responseBody = response.data;
      final List<dynamic> data;

      if (responseBody is Map && responseBody['data'] is Map) {
        data = (responseBody['data']['members'] as List?) ?? [];
      } else {
        data = _extractList(responseBody, ['data', 'members']);
      }

      debugPrint(' [GroupService] ${data.length} membre(s) récupéré(s)');

      debugPrint(' [GroupService] ${data.length} membre(s) récupéré(s)');

      if (data.isEmpty) {
        debugPrint(' Aucun membre trouvé pour le groupe $groupId');
        return [];
      }

      for (var member in data) {
        debugPrint('   - ${member['name'] ?? member['full_name']}');
      }

      return data
          .map((json) => GroupMember.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint(' [GroupService] fetchGroupMembers error: $e');
      return [];
    }
  }

  Future<Planning> addToCalendar({
    required String groupId,
    required DateTime date,
    required String assignedTo,
  }) async {
    try {
      debugPrint(' [GroupService] POST /api/parents/carpool/calendar');
      debugPrint('   group_id: $groupId');
      debugPrint('   date: ${date.toIso8601String()}');

      final response = await _apiClient.post(
        ApiConstants.carpoolCalendar,
        data: {
          'group_id': int.parse(groupId),
          'date': date.toIso8601String().split('T')[0],
          'departure_time': '08:00:00',
          'start_point': 'Point de départ',
          'end_point': 'Point d\'arrivée',
          'return_time': '16:00:00',
          'capacity_max': 4,
          'notes': assignedTo,
        },
      );

      debugPrint(' [GroupService] Planning ajouté');
      final data = response.data is Map
          ? (response.data['data'] ?? response.data)
          : response.data;
      return Planning.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      debugPrint(' [GroupService] addToCalendar error: $e');
      throw Exception('Unable to add to calendar: $e');
    }
  }

  Future<Planning> updateCalendar({
    required String calendarId,
    DateTime? date,
    String? assignedTo,
  }) async {
    try {
      final response = await _apiClient.put(
        ApiConstants.carpoolCalendar,
        data: {
          'calendarId': calendarId,
          if (date != null) 'date': date.toIso8601String(),
          if (assignedTo != null) 'assignedTo': assignedTo,
        },
      );
      final data = response.data is Map
          ? (response.data['data'] ?? response.data)
          : response.data;
      return Planning.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Unable to update calendar: $e');
    }
  }

  Future<void> deleteFromCalendar(String calendarId) async {
    await _apiClient.delete(
      ApiConstants.carpoolCalendar,
      data: {'calendarId': calendarId},
    );
  }

  Future<void> confirmCalendar({required String calendarId}) async {
    try {
      debugPrint(
        ' [GroupService] POST /api/parents/carpool/calendar/$calendarId/confirm',
      );
      await _apiClient.post(
        '${ApiConstants.carpoolCalendar}/$calendarId/confirm',
      );
      debugPrint(' [GroupService] Planning confirmé');
    } catch (e) {
      debugPrint(' [GroupService] confirmCalendar error: $e');
      throw Exception('Unable to confirm calendar: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchReplacementRequests(
    String groupId,
  ) async {
    try {
      debugPrint(
        '🔍 [GroupService] GET /api/parents/carpool/groups/$groupId/replacement-requests',
      );

      final response = await _apiClient.get(
        '${ApiConstants.carpoolGroups}/$groupId/replacement-requests',
      );

      final dynamic responseBody = response.data;
      List<dynamic> data = [];

      if (responseBody is Map) {
        if (responseBody['data'] is List) {
          data = responseBody['data'] as List;
        } else if (responseBody['data'] is Map) {
          final inner = responseBody['data'] as Map;
          data =
              (inner['requests'] ?? inner['replacement_requests'] ?? [])
                  as List;
        }
      }

      data = data.where((req) => req['status'] == 'pending').toList();
      debugPrint(
        ' [GroupService] ${data.length} demande(s) de remplacement trouvée(s)',
      );

      for (var request in data) {
        debugPrint('   - Calendar ID: ${request['calendar_id']}');
        debugPrint('     Requester: ${request['requester_name']}');
        debugPrint('     Motif: ${request['reason']}');
        debugPrint('     Statut: ${request['status']}');
      }

      return data.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint(' [GroupService] fetchReplacementRequests error: $e');
      return [];
    }
  }

  Future<void> createGroupPlanning({
    required String groupId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      debugPrint(
        ' [GroupService] POST /api/parents/carpool/groups/$groupId/planning',
      );
      debugPrint('   start_date: ${startDate.toIso8601String().split('T')[0]}');
      debugPrint('   end_date: ${endDate.toIso8601String().split('T')[0]}');

      await _apiClient.post(
        '${ApiConstants.carpoolGroups}/$groupId/planning',
        data: {
          'start_date': startDate.toIso8601String().split('T')[0],
          'end_date': endDate.toIso8601String().split('T')[0],
        },
      );

      debugPrint(
        ' [GroupService] Planning créé avec assignations automatiques',
      );
    } catch (e) {
      debugPrint(' [GroupService] createGroupPlanning error: $e');
      throw Exception('Unable to create planning: $e');
    }
  }

  Future<void> proposeExchange({
    required Planning planning,
    required String reason,
  }) async {
    try {
      debugPrint(
        '📤 [GroupService] POST /api/parents/carpool/calendar/${planning.id}/replace',
      );
      debugPrint('   calendar_id: ${planning.id}');
      debugPrint('   reason: $reason');

      //  BON ENDPOINT
      await _apiClient.post(
        '${ApiConstants.carpoolCalendar}/${planning.id}/replace',
        data: {'reason': reason},
      );

      debugPrint(' [GroupService] Demande de remplacement envoyée');
    } catch (e) {
      debugPrint(' [GroupService] proposeExchange error: $e');
      throw Exception('Unable to propose exchange: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchExchangeProposals(
    String groupId,
  ) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.carpoolConduite,
        queryParameters: {'group_id': groupId},
      );
      final List<dynamic> data = _extractList(response.data, [
        'data',
        'proposals',
      ]);
      return data.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint(' fetchExchangeProposals error: $e');
      return [];
    }
  }

  Future<void> respondToExchange({
    required String proposalId,
    required bool accept,
  }) async {
    try {
      debugPrint(' [GroupService] PUT /api/parents/carpool/conduite');
      debugPrint('   exchange_id: $proposalId');
      debugPrint('   accept: $accept');

      await _apiClient.post(
        '/api/parents/carpool/replacement-requests/$proposalId',
        data: {'action': accept ? 'accept' : 'decline'},
      );

      debugPrint(' [GroupService] Réponse envoyée');
    } catch (e) {
      debugPrint(' [GroupService] respondToExchange error: $e');
      throw Exception('Unable to respond to exchange: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchAllReplacementRequests(
    String groupId,
  ) async {
    try {
      debugPrint(
        '🔍 [GroupService] GET ALL replacement-requests for group $groupId',
      );

      final response = await _apiClient.get(
        '${ApiConstants.carpoolGroups}/$groupId/replacement-requests',
      );

      final dynamic responseBody = response.data;
      List<dynamic> data = [];

      if (responseBody is Map) {
        if (responseBody['data'] is List) {
          data = responseBody['data'] as List;
        } else if (responseBody['data'] is Map) {
          final inner = responseBody['data'] as Map;
          data =
              (inner['requests'] ?? inner['replacement_requests'] ?? [])
                  as List;
        }
      }

      debugPrint(' [GroupService] ${data.length} demande(s) toutes confondues');
      return data.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint(' [GroupService] fetchAllReplacementRequests error: $e');
      return [];
    }
  }

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
