
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:private_school/chauffeurs/pages/abonnement/data/models/subscription_model.dart';
import '../../data/repositories/subscription_repository.dart';
import 'subscription_event.dart';
import 'subscription_state.dart';

class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  final SubscriptionRepository repository;

  SubscriptionBloc({required this.repository}) : super(SubscriptionInitial()) {
    on<LoadSubscriptionPlansEvent>(_onLoadPlans);
    on<SubscribeEvent>(_onSubscribe);
    on<RenewSubscriptionEvent>(_onRenew);
    on<CancelSubscriptionEvent>(_onCancel);
    on<LoadPaymentMethodsEvent>(_onLoadPaymentMethods);
    on<AddPaymentMethodEvent>(_onAddPaymentMethod);
    on<SetDefaultPaymentMethodEvent>(_onSetDefault);
    on<DeletePaymentMethodEvent>(_onDeletePaymentMethod);
    on<LoadCurrentSubscriptionEvent>(_onLoadCurrentSubscription);
  }


  Future<void> _onLoadCurrentSubscription(
  LoadCurrentSubscriptionEvent event,
  Emitter<SubscriptionState> emit,
) async {
  try {
    final subscription = await repository.getCurrentSubscription();
    emit(CurrentSubscriptionLoaded(subscription)); 
  } catch (e) {
    emit(CurrentSubscriptionLoaded(null));
  }
}
  
  Future<void> _onLoadPlans(
  LoadSubscriptionPlansEvent event,
  Emitter<SubscriptionState> emit,
) async {
 
  try {
    final plans = await repository.getPlans();
    emit(SubscriptionPlansLoaded(plans));
  } catch (e) {
    emit(SubscriptionError(e.toString()));
  }
}

  Future<void> _onSubscribe(
    SubscribeEvent event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(SubscriptionLoading());
    try {
      final subscription = await repository.subscribe(event.planId, event.paymentMethodId);
      emit(SubscriptionActive(subscription));
    } catch (e) {
      emit(SubscriptionError(e.toString()));
    }
  }

  Future<void> _onRenew(
    RenewSubscriptionEvent event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(SubscriptionLoading());
    try {
      final subscription = await repository.renewSubscription();
      emit(SubscriptionRenewed(subscription));
    } catch (e) {
      emit(SubscriptionError(e.toString()));
    }
  }

  Future<void> _onCancel(
    CancelSubscriptionEvent event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(SubscriptionLoading());
    try {
      await repository.cancelSubscription(event.subscriptionId);
      emit(SubscriptionCanceled());
    } catch (e) {
      emit(SubscriptionError(e.toString()));
    }
  }

  Future<void> _onLoadPaymentMethods(
    LoadPaymentMethodsEvent event,
    Emitter<SubscriptionState> emit,
  ) async {
    try {
      final methods = await repository.getPaymentMethods();
      emit(PaymentMethodsLoaded(methods));
    } catch (e) {
      emit(SubscriptionError(e.toString()));
    }
  }

  Future<void> _onAddPaymentMethod(
  AddPaymentMethodEvent event,
  Emitter<SubscriptionState> emit,
) async {
  try { 
    await repository.addPaymentMethod(
      type: event.type,
      cardNumber: event.cardNumber,
      phoneNumber: event.phoneNumber,
    );
    
    emit(PaymentMethodAdded(PaymentMethod(id: '', type: event.type))); 
    add(LoadPaymentMethodsEvent());

  } catch (e) {
    emit(SubscriptionError(e.toString()));
  }
}

  Future<void> _onSetDefault(
    SetDefaultPaymentMethodEvent event,
    Emitter<SubscriptionState> emit,
  ) async {
    try {
      await repository.setDefaultPaymentMethod(event.methodId);
      add(LoadPaymentMethodsEvent());
    } catch (e) {
      emit(SubscriptionError(e.toString()));
    }
  }

  Future<void> _onDeletePaymentMethod(
    DeletePaymentMethodEvent event,
    Emitter<SubscriptionState> emit,
  ) async {
    try {
      await repository.deletePaymentMethod(event.methodId);
      emit(PaymentMethodDeleted());
      add(LoadPaymentMethodsEvent());
    } catch (e) {
      emit(SubscriptionError(e.toString()));
    }
  }
}