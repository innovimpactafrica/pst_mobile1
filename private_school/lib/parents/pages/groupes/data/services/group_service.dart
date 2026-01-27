import 'package:flutter/foundation.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/utils/api_constants.dart';
import '../models/group_model.dart';

/// Service for managing carpool group API calls
/// Handles all group-related operations: CRUD, invitations, calendar, exchanges
class GroupService {
  final ApiClient _apiClient = ApiClient();

  /// Fetch my groups (groups I'm a member of)
  /// Endpoint: GET /api/parents/carpool/groups
  Future<List<GroupModel>> fetchMyGroups() async {
    try {
      debugPrint('🔍 [GroupService] Fetching my groups from API...');

      final response = await _apiClient.get(ApiConstants.carpoolGroups);

      debugPrint('✅ [GroupService] Response received: ${response.statusCode}');
      debugPrint('📦 [GroupService] Data: ${response.data}');

      // API can return either a direct array or { data: [...] }
      final List<dynamic> groupsData = response.data is List
          ? response.data
          : response.data['data'] ?? response.data['groups'] ?? [];

      final groups = groupsData
          .map((json) => GroupModel.fromJson(json as Map<String, dynamic>))
          .toList();

      debugPrint('✅ [GroupService] ${groups.length} groups loaded successfully');
      return groups;
    } catch (e) {
      debugPrint('❌ [GroupService] Error fetching groups: $e');
      throw Exception('Unable to load groups: $e');
    }
  }

  /// Fetch available groups (to join)
  /// Note: Using same endpoint with query parameter
  Future<List<GroupModel>> fetchAvailableGroups() async {
    try {
      debugPrint('🔍 [GroupService] Fetching available groups from API...');

      final response = await _apiClient.get(
        ApiConstants.carpoolGroups,
        queryParameters: {'available': true},
      );

      debugPrint('✅ [GroupService] Response received: ${response.statusCode}');

      final List<dynamic> groupsData = response.data is List
          ? response.data
          : response.data['data'] ?? response.data['groups'] ?? [];

      final groups = groupsData
          .map((json) => GroupModel.fromJson(json as Map<String, dynamic>))
          .toList();

      debugPrint('✅ [GroupService] ${groups.length} available groups loaded');
      return groups;
    } catch (e) {
      debugPrint('❌ [GroupService] Error fetching available groups: $e');
      throw Exception('Unable to load available groups: $e');
    }
  }

  /// Fetch a group by its ID
  /// Endpoint: GET /api/parents/carpool/groups (with groupId parameter)
  Future<GroupModel> fetchGroupById(String groupId) async {
    try {
      debugPrint('🔍 [GroupService] Fetching group with ID: $groupId');

      final response = await _apiClient.get(
        ApiConstants.carpoolGroups,
        queryParameters: {'groupId': groupId},
      );

      debugPrint('✅ [GroupService] Group details received');

      final groupData = response.data is Map
          ? (response.data['data'] ?? response.data)
          : response.data;

      return GroupModel.fromJson(groupData as Map<String, dynamic>);
    } catch (e) {
      debugPrint('❌ [GroupService] Error fetching group $groupId: $e');
      throw Exception('Unable to load group details: $e');
    }
  }

  /// Create a new group
  /// Endpoint: POST /api/parents/carpool/groups
  Future<GroupModel> createGroup({
    required String name,
    String? description,
    List<String>? memberEmails,
  }) async {
    try {
      debugPrint('📤 [GroupService] Creating new group: $name');

      final response = await _apiClient.post(
        ApiConstants.carpoolGroups,
        data: {
          'name': name,
          'description': description,
          'members': memberEmails?.map((email) => {'email': email}).toList(),
        },
      );

      debugPrint('✅ [GroupService] Group created successfully');

      final groupData = response.data is Map
          ? (response.data['data'] ?? response.data)
          : response.data;

      return GroupModel.fromJson(groupData as Map<String, dynamic>);
    } catch (e) {
      debugPrint('❌ [GroupService] Error creating group: $e');
      throw Exception('Unable to create group: $e');
    }
  }

  /// Update a group
  /// Endpoint: PUT /api/parents/carpool/groups
  Future<GroupModel> updateGroup({
    required String groupId,
    String? name,
    String? description,
  }) async {
    try {
      debugPrint('📝 [GroupService] Updating group: $groupId');

      final response = await _apiClient.put(
        ApiConstants.carpoolGroups,
        data: {
          'groupId': groupId,
          'name': name,
          'description': description,
        },
      );

      debugPrint('✅ [GroupService] Group updated successfully');

      final groupData = response.data is Map
          ? (response.data['data'] ?? response.data)
          : response.data;

      return GroupModel.fromJson(groupData as Map<String, dynamic>);
    } catch (e) {
      debugPrint('❌ [GroupService] Error updating group: $e');
      throw Exception('Unable to update group: $e');
    }
  }

  /// Delete a group
  /// Endpoint: DELETE /api/parents/carpool/groups
  Future<void> deleteGroup(String groupId) async {
    try {
      debugPrint('🗑️ [GroupService] Deleting group: $groupId');

      await _apiClient.delete(
        ApiConstants.carpoolGroups,
        data: {'groupId': groupId},
      );

      debugPrint('✅ [GroupService] Group deleted successfully');
    } catch (e) {
      debugPrint('❌ [GroupService] Error deleting group: $e');
      throw Exception('Unable to delete group: $e');
    }
  }

  /// Invite a member to the group
  /// Endpoint: POST /api/parents/carpool/invitations
  Future<void> inviteMember({
    required String groupId,
    String? email,
    String? phone,
  }) async {
    try {
      debugPrint('📨 [GroupService] Inviting member to group: $groupId');

      await _apiClient.post(
        ApiConstants.carpoolInvitations,
        data: {
          'groupId': groupId,
          'email': email,
          'phone': phone,
        },
      );

      debugPrint('✅ [GroupService] Invitation sent successfully');
    } catch (e) {
      debugPrint('❌ [GroupService] Error inviting member: $e');
      throw Exception('Unable to invite member: $e');
    }
  }

  /// Fetch invitations
  /// Endpoint: GET /api/parents/carpool/invitations
  Future<List<Map<String, dynamic>>> fetchInvitations() async {
    try {
      debugPrint('🔍 [GroupService] Fetching invitations from API...');

      final response = await _apiClient.get(ApiConstants.carpoolInvitations);

      debugPrint('✅ [GroupService] Invitations received');

      final List<dynamic> invitationsData = response.data is List
          ? response.data
          : response.data['data'] ?? response.data['invitations'] ?? [];

      return invitationsData.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('❌ [GroupService] Error fetching invitations: $e');
      throw Exception('Unable to load invitations: $e');
    }
  }

  /// Respond to an invitation
  /// Endpoint: PUT /api/parents/carpool/invitations
  Future<void> respondToInvitation({
    required String invitationId,
    required bool accept,
  }) async {
    try {
      debugPrint(
        '📝 [GroupService] Responding to invitation: $invitationId (${accept ? "accept" : "decline"})',
      );

      await _apiClient.put(
        ApiConstants.carpoolInvitations,
        data: {
          'invitationId': invitationId,
          'accept': accept,
        },
      );

      debugPrint('✅ [GroupService] Response sent successfully');
    } catch (e) {
      debugPrint('❌ [GroupService] Error responding to invitation: $e');
      throw Exception('Unable to respond to invitation: $e');
    }
  }

  /// Fetch group calendar
  /// Endpoint: GET /api/parents/carpool/calendar
  Future<List<Planning>> fetchGroupCalendar(String groupId) async {
    try {
      debugPrint('📅 [GroupService] Fetching calendar for group: $groupId');

      final response = await _apiClient.get(
        ApiConstants.carpoolCalendar,
        queryParameters: {'groupId': groupId},
      );

      debugPrint('✅ [GroupService] Calendar received');

      final List<dynamic> calendarData = response.data is List
          ? response.data
          : response.data['data'] ?? response.data['calendar'] ?? [];

      return calendarData
          .map((json) => Planning.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('❌ [GroupService] Error fetching calendar: $e');
      throw Exception('Unable to load calendar: $e');
    }
  }

  /// Add to calendar
  /// Endpoint: POST /api/parents/carpool/calendar
  Future<Planning> addToCalendar({
    required String groupId,
    required DateTime date,
    required String assignedTo,
  }) async {
    try {
      debugPrint('📅 [GroupService] Adding to calendar: $date');

      final response = await _apiClient.post(
        ApiConstants.carpoolCalendar,
        data: {
          'groupId': groupId,
          'date': date.toIso8601String(),
          'assignedTo': assignedTo,
        },
      );

      debugPrint('✅ [GroupService] Added to calendar successfully');

      final planningData = response.data is Map
          ? (response.data['data'] ?? response.data)
          : response.data;

      return Planning.fromJson(planningData as Map<String, dynamic>);
    } catch (e) {
      debugPrint('❌ [GroupService] Error adding to calendar: $e');
      throw Exception('Unable to add to calendar: $e');
    }
  }

  /// Update calendar entry
  /// Endpoint: PUT /api/parents/carpool/calendar
  Future<Planning> updateCalendar({
    required String calendarId,
    DateTime? date,
    String? assignedTo,
  }) async {
    try {
      debugPrint('📝 [GroupService] Updating calendar entry: $calendarId');

      final response = await _apiClient.put(
        ApiConstants.carpoolCalendar,
        data: {
          'calendarId': calendarId,
          if (date != null) 'date': date.toIso8601String(),
          if (assignedTo != null) 'assignedTo': assignedTo,
        },
      );

      debugPrint('✅ [GroupService] Calendar updated successfully');

      final planningData = response.data is Map
          ? (response.data['data'] ?? response.data)
          : response.data;

      return Planning.fromJson(planningData as Map<String, dynamic>);
    } catch (e) {
      debugPrint('❌ [GroupService] Error updating calendar: $e');
      throw Exception('Unable to update calendar: $e');
    }
  }

  /// Delete from calendar
  /// Endpoint: DELETE /api/parents/carpool/calendar
  Future<void> deleteFromCalendar(String calendarId) async {
    try {
      debugPrint('🗑️ [GroupService] Deleting from calendar: $calendarId');

      await _apiClient.delete(
        ApiConstants.carpoolCalendar,
        data: {'calendarId': calendarId},
      );

      debugPrint('✅ [GroupService] Deleted from calendar successfully');
    } catch (e) {
      debugPrint('❌ [GroupService] Error deleting from calendar: $e');
      throw Exception('Unable to delete from calendar: $e');
    }
  }

  /// Propose an exchange
  /// Endpoint: POST /api/parents/carpool/conduite
  Future<void> proposeExchange({
    required String planningId,
    required String reason,
  }) async {
    try {
      debugPrint('🔄 [GroupService] Proposing exchange for planning: $planningId');

      await _apiClient.post(
        ApiConstants.carpoolConduite,
        data: {
          'planningId': planningId,
          'reason': reason,
        },
      );

      debugPrint('✅ [GroupService] Exchange proposed successfully');
    } catch (e) {
      debugPrint('❌ [GroupService] Error proposing exchange: $e');
      throw Exception('Unable to propose exchange: $e');
    }
  }

  /// Fetch exchange proposals
  /// Endpoint: GET /api/parents/carpool/conduite
  Future<List<Map<String, dynamic>>> fetchExchangeProposals(
    String groupId,
  ) async {
    try {
      debugPrint('🔍 [GroupService] Fetching exchange proposals for group: $groupId');

      final response = await _apiClient.get(
        ApiConstants.carpoolConduite,
        queryParameters: {'groupId': groupId},
      );

      debugPrint('✅ [GroupService] Exchange proposals received');

      final List<dynamic> proposalsData = response.data is List
          ? response.data
          : response.data['data'] ?? response.data['proposals'] ?? [];

      return proposalsData.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('❌ [GroupService] Error fetching exchange proposals: $e');
      throw Exception('Unable to load proposals: $e');
    }
  }

  /// Respond to an exchange proposal
  /// Endpoint: PUT /api/parents/carpool/conduite
  Future<void> respondToExchange({
    required String proposalId,
    required bool accept,
  }) async {
    try {
      debugPrint('📝 [GroupService] Responding to exchange: $proposalId');

      await _apiClient.put(
        ApiConstants.carpoolConduite,
        data: {
          'proposalId': proposalId,
          'accept': accept,
        },
      );

      debugPrint('✅ [GroupService] Response sent successfully');
    } catch (e) {
      debugPrint('❌ [GroupService] Error responding to exchange: $e');
      throw Exception('Unable to respond to proposal: $e');
    }
  }
}