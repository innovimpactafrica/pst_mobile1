// Payment Service - API calls only
//
// Path: lib/parents/profil/data/services/payment_service.dart
import 'package:private_school/core/network/api_client.dart';

import 'package:flutter/foundation.dart';
import '../models/payment_model.dart';

class PaymentService {
  final ApiClient _apiClient = ApiClient();

  Future<List<PaymentModel>> fetchPaymentHistory() async {
    try {
      debugPrint('🔍 Fetching payment history...');

      final response = await _apiClient.get('/api/payments/history');

      debugPrint('✅ Payment history received: ${response.statusCode}');

      final List<dynamic> paymentsData = response.data is List
          ? response.data
          : response.data['data'] ?? response.data['payments'] ?? [];

      return paymentsData
          .map((json) => PaymentModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('❌ Error fetching payment history: $e');
      throw Exception('Failed to load payment history: $e');
    }
  }

  Future<PaymentModel> fetchPaymentDetails(String paymentId) async {
    try {
      debugPrint('🔍 Fetching payment details for: $paymentId');

      final response = await _apiClient.get('/api/payments/$paymentId');

      final paymentData = response.data is Map
          ? (response.data['data'] ?? response.data)
          : response.data;

      return PaymentModel.fromJson(paymentData as Map<String, dynamic>);
    } catch (e) {
      debugPrint('❌ Error fetching payment details: $e');
      throw Exception('Failed to load payment details: $e');
    }
  }
}
