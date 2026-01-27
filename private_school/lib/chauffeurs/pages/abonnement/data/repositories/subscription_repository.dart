
import '../models/subscription_model.dart';
import '../services/subscription_service.dart';

class SubscriptionRepository {
  final SubscriptionService _service = SubscriptionService();


  Future<SubscriptionModel?> getCurrentSubscription() async {
  try {
    return await _service.getCurrentSubscription();
  } catch (e) {
    return null;
  }
}

  Future<List<SubscriptionPlan>> getPlans() async {
    try {
      return await _service.fetchPlans();
    } catch (e) {
      throw Exception('Failed to load plans: $e');
    }
  }

  Future<SubscriptionModel> subscribe(String planId, String paymentMethodId) async {
    try {
      return await _service.subscribe(planId: planId, paymentMethodId: paymentMethodId);
    } catch (e) {
      throw Exception('Failed to subscribe: $e');
    }
  }

  Future<SubscriptionModel> renewSubscription() async {
    try {
      return await _service.renewSubscription();
    } catch (e) {
      throw Exception('Failed to renew: $e');
    }
  }

  Future<void> cancelSubscription(String subscriptionId) async {
    try {
      await _service.cancelSubscription(subscriptionId);
    } catch (e) {
      throw Exception('Failed to cancel: $e');
    }
  }

  Future<List<PaymentMethod>> getPaymentMethods() async {
    try {
      return await _service.fetchPaymentMethods();
    } catch (e) {
      throw Exception('Failed to load payment methods: $e');
    }
  }

  Future<PaymentMethod> addPaymentMethod({
    required String type,
    String? cardNumber,
    String? phoneNumber,
  }) async {
    try {
      return await _service.addPaymentMethod(
        type: type,
        cardNumber: cardNumber,
        phoneNumber: phoneNumber,
      );
    } catch (e) {
      throw Exception('Failed to add payment method: $e');
    }
  }

  Future<void> setDefaultPaymentMethod(String methodId) async {
    try {
      await _service.setDefaultPaymentMethod(methodId);
    } catch (e) {
      throw Exception('Failed to set default: $e');
    }
  }

  Future<void> deletePaymentMethod(String methodId) async {
    try {
      await _service.deletePaymentMethod(methodId);
    } catch (e) {
      throw Exception('Failed to delete payment method: $e');
    }
  }
}