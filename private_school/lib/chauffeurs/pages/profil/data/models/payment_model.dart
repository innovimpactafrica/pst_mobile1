class PaymentModel {
  final String id;
  final double amount;
  final String currency;
  final DateTime date;
  final PaymentStatus status;
  final String? tripId;

  PaymentModel({
    required this.id,
    required this.amount,
    this.currency = 'FCFA',
    required this.date,
    required this.status,
    this.tripId,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['_id'] ?? json['id'] ?? '',
      amount: (json['amount'] ?? json['montant'] ?? 0).toDouble(),
      currency: json['currency'] ?? json['devise'] ?? 'FCFA',
      date: DateTime.parse(json['date'] ?? json['createdAt'] ?? DateTime.now().toIso8601String()),
      status: _parsePaymentStatus(json['status'] ?? json['statut']),
      tripId: json['tripId'] ?? json['trajetId'],
    );
  }

  static PaymentStatus _parsePaymentStatus(String? status) {
    switch (status) {
      case 'completed':
      case 'complete':
      case 'paid':
        return PaymentStatus.completed;
      case 'pending':
      case 'en_attente':
        return PaymentStatus.pending;
      case 'failed':
      case 'echoue':
        return PaymentStatus.failed;
      default:
        return PaymentStatus.pending;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'currency': currency,
      'date': date.toIso8601String(),
      'status': status.name,
      'tripId': tripId,
    };
  }

  String get formattedAmount => '${amount.toStringAsFixed(0)} $currency';

  String get formattedDate {
    final months = [
      'janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin',
      'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.'
    ];
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]}, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

enum PaymentStatus {
  completed,
  pending,
  failed,
}