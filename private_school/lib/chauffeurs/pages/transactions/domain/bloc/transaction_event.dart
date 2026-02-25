abstract class TransactionEvent {}

class LoadTransactionsEvent extends TransactionEvent {}

class RefreshTransactionsEvent extends TransactionEvent {}

class FilterTransactionsByTypeEvent extends TransactionEvent {
  final String? type;

  FilterTransactionsByTypeEvent({this.type});
}
