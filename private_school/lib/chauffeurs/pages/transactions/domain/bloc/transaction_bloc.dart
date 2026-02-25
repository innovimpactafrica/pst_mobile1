import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/transaction_repository.dart';
import 'transaction_event.dart';
import 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionRepository repository;

  TransactionBloc({required this.repository}) : super(TransactionInitial()) {
    on<LoadTransactionsEvent>(_onLoadTransactions);
    on<RefreshTransactionsEvent>(_onRefreshTransactions);
    on<FilterTransactionsByTypeEvent>(_onFilterByType);
  }

  Future<void> _onLoadTransactions(
    LoadTransactionsEvent event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    try {
      final transactions = await repository.getTransactions();
      emit(TransactionsLoaded(transactions));
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  Future<void> _onRefreshTransactions(
    RefreshTransactionsEvent event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      final transactions = await repository.getTransactions();
      emit(TransactionsLoaded(transactions));
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  Future<void> _onFilterByType(
    FilterTransactionsByTypeEvent event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      final transactions = await repository.getTransactions();

      if (event.type == null || event.type!.isEmpty) {
        emit(TransactionsLoaded(transactions));
      } else {
        final filtered = transactions
            .where((t) => t.type == event.type)
            .toList();
        emit(TransactionsLoaded(filtered, filterType: event.type));
      }
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }
}
