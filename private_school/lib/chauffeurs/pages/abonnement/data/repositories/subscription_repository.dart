import '../models/subscription_model.dart';
import '../services/subscription_service.dart';

class SubscriptionRepository {
  final SubscriptionService _service;

  SubscriptionRepository(this._service);

  Future<List<SubscriptionPlan>> getPlans() async {
    return await _service.fetchPlans();
  }

  Future<SubscriptionModel?> getCurrentSubscription() async {
    return await _service.getCurrentSubscription();
  }

  Future<SubscriptionModel> subscribe(String planId, String paymentMethodId) async {
    return await _service.subscribe(
      planId: planId, 
      paymentMethodId: paymentMethodId,
    );
  }

  Future<void> cancelSubscription(String id) async {
    return await _service.cancelSubscription(id);
  }

  Future<SubscriptionModel> renewSubscription() async {
    return await _service.renewSubscription();
  }



  Future<List<PaymentMethod>> getPaymentMethods() async {
    return await _service.fetchPaymentMethods();
  }

  Future<void> addPaymentMethod({
    required String type,
    String? cardNumber,
    String? phoneNumber,
  }) async {
   
    return await _service.addPaymentMethod(
      type: type,
      cardNumber: cardNumber,
      phoneNumber: phoneNumber,
    );
  }

  Future<void> setDefaultPaymentMethod(String methodId) async {
    return await _service.setDefaultPaymentMethod(methodId);
  }

  Future<void> deletePaymentMethod(String methodId) async {
    return await _service.deletePaymentMethod(methodId);
  }
}