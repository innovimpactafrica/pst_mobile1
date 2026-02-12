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
// Dans GroupService (group_service.dart)
Future<void> inviteMember({
  required String groupId,
  String? email,
  String? phone,
}) async {
  try {
    await _apiClient.post(
      ApiConstants.carpoolInvitations,
      data: {
        // ✅ On convertit l'ID en int car le backend semble le demander pour les routes carpool
        'group_id': int.tryParse(groupId) ?? groupId, 
        if (email != null) 'parent_email': email.trim(), // ✅ Ajout du .trim() par sécurité
        if (phone != null) 'phone': phone.trim(),
      },
    );
  } catch (e) {
    // On propage l'erreur exacte du serveur pour mieux debugger
    throw e; 
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
    debugPrint('🔍 [GroupService] GET /api/parents/carpool/calendar?group_id=$groupId');
    final response = await _apiClient.get(
      ApiConstants.carpoolCalendar,
      queryParameters: {'group_id': groupId}, // ✅ CHANGÉ: groupId -> group_id
    );
    final List<dynamic> data = _extractList(response.data, ['data', 'calendar']);
    debugPrint('✅ [GroupService] ${data.length} plannings chargés');
    return data.map((json) => Planning.fromJson(json as Map<String, dynamic>)).toList();
  } catch (e) {
    debugPrint('❌ [GroupService] fetchGroupCalendar error: $e');
    throw Exception('Unable to load calendar: $e');
  }
}

  // ✅ MÉTHODE CORRIGÉE : addToCalendar
  // Correspond au format attendu par l'API POST /api/parents/carpool/calendar
  Future<Planning> addToCalendar({
    required String groupId,
    required DateTime date,
    required String assignedTo,
  }) async {
    try {
      debugPrint('📅 [GroupService] POST /api/parents/carpool/calendar');
      debugPrint('   group_id: $groupId');
      debugPrint('   date: ${date.toIso8601String()}');
      
      // ✅ Format selon le Swagger API
      final response = await _apiClient.post(
        ApiConstants.carpoolCalendar,
        data: {
          'group_id': int.parse(groupId), // ✅ snake_case + int
          'date': date.toIso8601String().split('T')[0], // ✅ Format "2026-02-19"
          'departure_time': '08:00:00', // ✅ OBLIGATOIRE - Heure par défaut
          // Champs optionnels selon le Swagger
          'driver_id': 0, // Auto-assigné
          'start_point': 'Point de départ', // À adapter selon vos besoins
          'end_point': 'Point d\'arrivée', // À adapter selon vos besoins
          'return_time': '16:00:00', // Heure de retour par défaut
          'capacity_max': 4, // Capacité par défaut
          'notes': assignedTo, // Utilise assignedTo comme note
        },
      );
      
      debugPrint('✅ [GroupService] Planning ajouté');
      final data = response.data is Map ? (response.data['data'] ?? response.data) : response.data;
      return Planning.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      debugPrint('❌ [GroupService] addToCalendar error: $e');
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
Future<void> proposeExchange({
  required Planning planning,
  required String reason,
}) async {
  try {
    debugPrint('📤 [GroupService] POST /api/parents/carpool/conduite');
    debugPrint('   group_id: ${planning.groupId}');
    debugPrint('   original_date: ${planning.date.toIso8601String()}');

    await _apiClient.post(
      ApiConstants.carpoolConduite,
      data: {
        'group_id': int.parse(planning.groupId),
        'original_date': planning.date.toIso8601String().split('T')[0],
        'exchange_type': 'replacement',
        'reason': reason,
      },
    );
  } catch (e) {
    debugPrint('❌ proposeExchange error: $e');
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