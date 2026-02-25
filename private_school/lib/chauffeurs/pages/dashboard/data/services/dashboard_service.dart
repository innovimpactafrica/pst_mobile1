import '../../../../../core/network/api_client.dart';
import '../models/dashboard_model.dart';

class DashboardService {
  final ApiClient _apiClient = ApiClient();

  Future<DashboardModel> fetchDashboard() async {
    try {
      final response = await _apiClient.get('/api/drivers/dashboard');

      final dashboardData = response.data is Map
          ? (response.data['data'] ?? response.data)
          : response.data;

      return DashboardModel.fromJson(dashboardData as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to load dashboard: $e');
    }
  }
}
