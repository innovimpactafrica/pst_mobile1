import '../../../../../core/network/api_client.dart';
import '../models/transaction_model.dart';

class TransactionService {
  final ApiClient _apiClient = ApiClient();

  Future<List<TransactionModel>> fetchTransactions() async {
    try {
      final response = await _apiClient.get('/api/drivers/transactions');

      final List<dynamic> transactionsData = response.data is List
          ? response.data
          : response.data['data'] ?? response.data['transactions'] ?? [];

      return transactionsData
          .map(
            (json) => TransactionModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to load transactions: $e');
    }
  }
}
