class TransactionModel {
  final String id;
  final String driverId;
  final double amount;
  final String type;
  final String description;
  final DateTime date;
  final String status;
  final String? paymentMethod;

  TransactionModel({
    required this.id,
    required this.driverId,
    required this.amount,
    required this.type,
    required this.description,
    required this.date,
    this.status = 'completed',
    this.paymentMethod,
  });

  bool get isIncome => type == 'income' || type == 'credit';
  bool get isExpense => type == 'expense' || type == 'debit';

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['_id'] ?? json['id'] ?? '',
      driverId: json['driverId'] ?? json['chauffeurId'] ?? '',
      amount: (json['amount'] ?? json['montant'] ?? 0).toDouble(),
      type: json['type'] ?? '',
      description: json['description'] ?? '',
      date: json['date'] != null || json['createdAt'] != null
          ? DateTime.parse(json['date'] ?? json['createdAt'])
          : DateTime.now(),
      status: json['status'] ?? json['statut'] ?? 'completed',
      paymentMethod: json['paymentMethod'] ?? json['moyenPaiement'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'driverId': driverId,
      'amount': amount,
      'type': type,
      'description': description,
      'date': date.toIso8601String(),
      'status': status,
      'paymentMethod': paymentMethod,
    };
  }
}
