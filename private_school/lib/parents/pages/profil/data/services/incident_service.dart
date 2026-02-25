import 'package:private_school/core/network/api_client.dart';
import 'package:private_school/core/utils/api_constants.dart';
import 'package:flutter/foundation.dart';

import '../models/incident_model.dart';

class IncidentService {
  final ApiClient _apiClient = ApiClient();

  Future<List<IncidentModel>> fetchIncidents() async {
    try {
      debugPrint(' Fetching incidents...');

      final response = await _apiClient.get(ApiConstants.incidents);

      debugPrint(' Incidents received: ${response.statusCode}');

      final List<dynamic> incidentsData = response.data is List
          ? response.data
          : response.data['data'] ?? response.data['incidents'] ?? [];

      return incidentsData
          .map((json) => IncidentModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint(' Error fetching incidents: $e');
      throw Exception('Failed to load incidents: $e');
    }
  }

  Future<IncidentModel> createIncident({
    required String title,
    required String description,
    required String category,
    String? imageUrl,
  }) async {
    try {
      debugPrint(' Creating new incident...');

      final response = await _apiClient.post(
        ApiConstants.incidents,
        data: {
          'title': title,
          'description': description,
          'category': category,
          if (imageUrl != null) 'imageUrl': imageUrl,
        },
      );

      debugPrint(' Incident created');

      final incidentData = response.data is Map
          ? (response.data['data'] ?? response.data)
          : response.data;

      return IncidentModel.fromJson(incidentData as Map<String, dynamic>);
    } catch (e) {
      debugPrint(' Error creating incident: $e');
      throw Exception('Failed to create incident: $e');
    }
  }

  Future<IncidentModel> updateIncident(
    String incidentId,
    Map<String, dynamic> updates,
  ) async {
    try {
      debugPrint(' Updating incident: $incidentId');

      final response = await _apiClient.put(
        '${ApiConstants.incidents}/$incidentId',
        data: updates,
      );

      final incidentData = response.data is Map
          ? (response.data['data'] ?? response.data)
          : response.data;

      return IncidentModel.fromJson(incidentData as Map<String, dynamic>);
    } catch (e) {
      debugPrint(' Error updating incident: $e');
      throw Exception('Failed to update incident: $e');
    }
  }

  Future<void> deleteIncident(String incidentId) async {
    try {
      await _apiClient.delete('${ApiConstants.incidents}/$incidentId');
      debugPrint(' Incident deleted');
    } catch (e) {
      debugPrint(' Error deleting incident: $e');
      throw Exception('Failed to delete incident: $e');
    }
  }
}
