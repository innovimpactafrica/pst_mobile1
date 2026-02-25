import '../../../../../core/network/api_client.dart';
import '../../../../../core/storage/secure_storage.dart';
import '../../../../../core/utils/api_constants.dart';

class LogoutService {
  final ApiClient _apiClient = ApiClient();
  final SecureStorage _storage = SecureStorage();

  Future<void> logout() async {
    try {
      try {
        await _apiClient.post(ApiConstants.logout);
      } catch (e) {
        //
      }
      await _storage.clearAll();
    } catch (e) {
      throw Exception('Erreur lors de la déconnexion: $e');
    }
  }
}
