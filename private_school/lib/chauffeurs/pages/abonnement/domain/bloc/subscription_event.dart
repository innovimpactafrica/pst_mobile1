

abstract class SubscriptionEvent {}

class LoadCurrentSubscriptionEvent extends SubscriptionEvent {}

class LoadSubscriptionPlansEvent extends SubscriptionEvent {}

class SubscribeEvent extends SubscriptionEvent {
  final String planId;
  final String paymentMethodId;

  SubscribeEvent(this.planId, this.paymentMethodId);
}

class RenewSubscriptionEvent extends SubscriptionEvent {}

class CancelSubscriptionEvent extends SubscriptionEvent {
  final String subscriptionId;

  CancelSubscriptionEvent(this.subscriptionId);
}

class LoadPaymentMethodsEvent extends SubscriptionEvent {}

class AddPaymentMethodEvent extends SubscriptionEvent {
  final String type;
  final String? cardNumber;
  final String? phoneNumber;

  AddPaymentMethodEvent(this.type, {this.cardNumber, this.phoneNumber});
}

class SetDefaultPaymentMethodEvent extends SubscriptionEvent {
  final String methodId;

  SetDefaultPaymentMethodEvent(this.methodId);
}

class DeletePaymentMethodEvent extends SubscriptionEvent {
  final String methodId;

  DeletePaymentMethodEvent(this.methodId);
}