import 'package:equatable/equatable.dart';
import '../../data/models/transaction_model.dart';

abstract class TransactionState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TransactionInitial extends TransactionState {}

class TransactionLoading extends TransactionState {}

class TransactionsLoaded extends TransactionState {
  final List<TransactionModel> transactions;
  final String? filterType;

  TransactionsLoaded(this.transactions, {this.filterType});

  @override
  List<Object?> get props => [transactions, filterType];
}

class TransactionError extends TransactionState {
  final String message;

  TransactionError(this.message);

  @override
  List<Object?> get props => [message];
}
