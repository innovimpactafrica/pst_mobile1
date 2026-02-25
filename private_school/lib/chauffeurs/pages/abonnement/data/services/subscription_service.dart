import '../../../../../core/network/api_client.dart';
import '../../../../../core/utils/api_constants.dart';
import '../models/subscription_model.dart';

class SubscriptionService {
  final ApiClient _apiClient = ApiClient();

  // RÉCUPÉRER LES PLANS
  Future<List<SubscriptionPlan>> fetchPlans() async {
    final response = await _apiClient.get(ApiConstants.driverSubscriptionPlans);
    final List data = response.data['data'] ?? response.data;
    return data.map((e) => SubscriptionPlan.fromJson(e)).toList();
  }

  // RÉCUPÉRER L'ABONNEMENT ACTUEL
  Future<SubscriptionModel?> getCurrentSubscription() async {
    try {
      final response = await _apiClient.get(ApiConstants.driverSubscription);

      final subData = response.data['data'] ?? response.data;
      if (subData == null) return null;

      return SubscriptionModel.fromJson(subData);
    } catch (e) {
      return null;
    }
  }

  Future<SubscriptionModel> subscribe({
    required String planId,
    required String paymentMethodId,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.driverSubscription,
      data: {'plan_id': planId, 'payment_method_id': paymentMethodId},
    );
    return SubscriptionModel.fromJson(response.data['data'] ?? response.data);
  }

  // ANNULER
  Future<void> cancelSubscription(String id) async {
    await _apiClient.delete(ApiConstants.driverSubscriptionCancel(id));
  }

  // RENOUVELER
  Future<SubscriptionModel> renewSubscription() async {
    final response = await _apiClient.post(
      ApiConstants.driverSubscriptionRenew,
    );
    return SubscriptionModel.fromJson(response.data['data'] ?? response.data);
  }

  // AJOUTER PAIEMENT
  Future<void> addPaymentMethod({
    required String type,
    String? cardNumber,
    String? phoneNumber,
  }) async {
    await _apiClient.post(
      ApiConstants.driverSubscriptionPlans,
      data: {
        'type': type,
        'cardNumber': cardNumber,
        'phoneNumber': phoneNumber,
      },
    );
  }

  Future<List<PaymentMethod>> fetchPaymentMethods() async {
    final response = await _apiClient.get(ApiConstants.driverSubscriptionPlans);
    final List rawData = response.data['paymentMethods'] ?? [];
    return rawData.map((e) => PaymentMethod.fromJson(e)).toList();
  }

  Future<void> setDefaultPaymentMethod(String methodId) async {
    await _apiClient.put(
      ApiConstants.driverSubscriptionPlanSetDefault(methodId),
    );
  }

  Future<void> deletePaymentMethod(String methodId) async {
    await _apiClient.delete(
      ApiConstants.driverSubscriptionPlanDelete(methodId),
    );
  }
}
