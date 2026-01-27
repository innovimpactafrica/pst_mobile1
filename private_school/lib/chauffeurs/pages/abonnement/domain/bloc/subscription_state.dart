
import 'package:equatable/equatable.dart';
import '../../data/models/subscription_model.dart';
import '../../data/services/subscription_service.dart';

abstract class SubscriptionState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CurrentSubscriptionLoaded extends SubscriptionState {
  final SubscriptionModel? subscription;
  
  CurrentSubscriptionLoaded(this.subscription);
  
  @override
  List<Object?> get props => [subscription];
}

class SubscriptionInitial extends SubscriptionState {}

class SubscriptionLoading extends SubscriptionState {}

class SubscriptionPlansLoaded extends SubscriptionState {
  final List<SubscriptionPlan> plans;

  SubscriptionPlansLoaded(this.plans);

  @override
  List<Object?> get props => [plans];
}

class SubscriptionActive extends SubscriptionState {
  final SubscriptionModel subscription;

  SubscriptionActive(this.subscription);

  @override
  List<Object?> get props => [subscription];
}

class SubscriptionRenewed extends SubscriptionState {
  final SubscriptionModel subscription;

  SubscriptionRenewed(this.subscription);

  @override
  List<Object?> get props => [subscription];
}

class SubscriptionCanceled extends SubscriptionState {}

class PaymentMethodsLoaded extends SubscriptionState {
  final List<PaymentMethod> methods;

  PaymentMethodsLoaded(this.methods);

  @override
  List<Object?> get props => [methods];
}

class PaymentMethodAdded extends SubscriptionState {
  final PaymentMethod method;

  PaymentMethodAdded(this.method);

  @override
  List<Object?> get props => [method];
}

class PaymentMethodDeleted extends SubscriptionState {}

class SubscriptionError extends SubscriptionState {
  final String message;

  SubscriptionError(this.message);

  @override
  List<Object?> get props => [message];
}