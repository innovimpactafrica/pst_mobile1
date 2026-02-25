import '../models/dashboard_model.dart';
import '../services/dashboard_service.dart';

class DashboardRepository {
  final DashboardService _service = DashboardService();

  Future<DashboardModel> getDashboard() async {
    try {
      return await _service.fetchDashboard();
    } catch (e) {
      throw Exception('Failed to load dashboard: $e');
    }
  }
}
