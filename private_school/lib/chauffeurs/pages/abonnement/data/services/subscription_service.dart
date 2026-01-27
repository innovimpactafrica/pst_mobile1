// Subscription service - Fixed for real API
// Path: lib/chauffeurs/pages/abonnement/data/services/subscription_service.dart

import '../../../../../core/network/api_client.dart';
import '../models/subscription_model.dart';

class SubscriptionService {
  final ApiClient _apiClient = ApiClient();

  // Get subscription plans
  Future<List<SubscriptionPlan>> fetchPlans() async {
    try {
      final response = await _apiClient.get('/api/drivers/subscription/plans');

      final List<dynamic> plansData = response.data is List
          ? response.data
          : response.data['data'] ?? response.data['plans'] ?? [];

      return plansData
          .map((json) => SubscriptionPlan.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to load plans: $e');
    }
  }

  // Subscribe to a plan
  Future<SubscriptionModel> subscribe({
    required String planId,
    required String paymentMethodId,
  }) async {
    try {
      final response = await _apiClient.post(
        '/api/drivers/subscription',
        data: {
          'planId': planId,
          'paymentMethodId': paymentMethodId,
        },
      );

      final subData = response.data is Map
          ? (response.data['data'] ?? response.data['subscription'] ?? response.data)
          : response.data;

      return SubscriptionModel.fromJson(subData as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to subscribe: $e');
    }
  }

  // Renew subscription
  Future<SubscriptionModel> renewSubscription() async {
    try {
      final response = await _apiClient.post('/api/drivers/subscription/renew');

      final subData = response.data is Map
          ? (response.data['data'] ?? response.data['subscription'] ?? response.data)
          : response.data;

      return SubscriptionModel.fromJson(subData as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to renew subscription: $e');
    }
  }

  // Cancel subscription
  Future<void> cancelSubscription(String subscriptionId) async {
    try {
      await _apiClient.delete('/api/drivers/subscription/$subscriptionId');
    } catch (e) {
      throw Exception('Failed to cancel subscription: $e');
    }
  }

  // Get current subscription (NEW - récupérer l'abonnement actuel)
  Future<SubscriptionModel?> getCurrentSubscription() async {
    try {
      final response = await _apiClient.get('/api/drivers/subscription');

      if (response.data == null) return null;

      final subData = response.data is Map
          ? (response.data['data'] ?? response.data['subscription'] ?? response.data)
          : response.data;

      return SubscriptionModel.fromJson(subData as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  // Get payment methods (FIXED endpoint)
  Future<List<PaymentMethod>> fetchPaymentMethods() async {
    try {
      final response = await _apiClient.get('/api/drivers/subscription/plans');

      final List<dynamic> methodsData = response.data is List
          ? response.data
          : response.data['paymentMethods'] ?? [];

      return methodsData
          .map((json) => PaymentMethod.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to load payment methods: $e');
    }
  }

  // Add payment method
  Future<PaymentMethod> addPaymentMethod({
    required String type,
    String? cardNumber,
    String? phoneNumber,
  }) async {
    try {
      final response = await _apiClient.post(
        '/api/drivers/subscription/plans',
        data: {
          'type': type,
          if (cardNumber != null) 'cardNumber': cardNumber,
          if (phoneNumber != null) 'phoneNumber': phoneNumber,
        },
      );

      final methodData = response.data is Map
          ? (response.data['data'] ?? response.data['paymentMethod'] ?? response.data)
          : response.data;

      return PaymentMethod.fromJson(methodData as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to add payment method: $e');
    }
  }

  // Set default payment method
  Future<void> setDefaultPaymentMethod(String methodId) async {
    try {
      await _apiClient.put('/api/drivers/subscription/plans/$methodId');
    } catch (e) {
      throw Exception('Failed to set default payment method: $e');
    }
  }

  // Delete payment method
  Future<void> deletePaymentMethod(String methodId) async {
    try {
      await _apiClient.delete('/api/drivers/subscription/plans/$methodId');
    } catch (e) {
      throw Exception('Failed to delete payment method: $e');
    }
  }
}

// Subscription Plan Model
class SubscriptionPlan {
  final String id;
  final String name;
  final double price;
  final int durationDays;
  final List<String> features;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.price,
    required this.durationDays,
    this.features = const [],
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? json['nom'] ?? '',
      price: _parseDouble(json['price'] ?? json['prix'] ?? 0),
      durationDays: json['durationDays'] ?? json['dureejours'] ?? 30,
      features: _parseFeatures(json['features']),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static List<String> _parseFeatures(dynamic features) {
    if (features == null) return [];
    if (features is List) {
      return features.map((e) => e.toString()).toList();
    }
    return [];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'durationDays': durationDays,
      'features': features,
    };
  }
}