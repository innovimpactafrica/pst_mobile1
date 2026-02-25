class PaymentModel {
  final String id;
  final double amount;
  final String currency;
  final DateTime date;
  final String paymentMethod;
  final String status;
  final String? description;
  final String? transactionId;

  PaymentModel({
    required this.id,
    required this.amount,
    this.currency = 'FCFA',
    required this.date,
    required this.paymentMethod,
    this.status = 'completed',
    this.description,
    this.transactionId,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['_id'] ?? json['id'] ?? '',
      amount: (json['amount'] ?? json['montant'] ?? 0).toDouble(),
      currency: json['currency'] ?? json['devise'] ?? 'FCFA',
      date: json['date'] != null || json['createdAt'] != null
          ? DateTime.parse(json['date'] ?? json['createdAt'])
          : DateTime.now(),
      paymentMethod: json['paymentMethod'] ?? json['moyenPaiement'] ?? 'mobile',
      status: json['status'] ?? json['statut'] ?? 'completed',
      description: json['description'],
      transactionId: json['transactionId'] ?? json['reference'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'currency': currency,
      'date': date.toIso8601String(),
      'paymentMethod': paymentMethod,
      'status': status,
      'description': description,
      'transactionId': transactionId,
    };
  }

  String get formattedAmount {
    return '${amount.toStringAsFixed(0)} $currency';
  }

  String get formattedDate {
    const months = [
      'janv.',
      'févr.',
      'mars',
      'avr.',
      'mai',
      'juin',
      'juil.',
      'août',
      'sept.',
      'oct.',
      'nov.',
      'déc.',
    ];
    return '${date.day} ${months[date.month - 1]}, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  bool get isCardPayment =>
      paymentMethod.toLowerCase() == 'card' ||
      paymentMethod.toLowerCase() == 'carte';

  bool get isMobilePayment =>
      paymentMethod.toLowerCase() == 'mobile' ||
      paymentMethod.toLowerCase() == 'orange_money' ||
      paymentMethod.toLowerCase() == 'kpay' ||
      paymentMethod.toLowerCase() == 'wave';
}
