

import '../models/transaction_model.dart';
import '../services/transaction_service.dart';

class TransactionRepository {
  final TransactionService _service = TransactionService();

  Future<List<TransactionModel>> getTransactions() async {
    try {
      return await _service.fetchTransactions();
    } catch (e) {
      throw Exception('Failed to load transactions: $e');
    }
  }
}