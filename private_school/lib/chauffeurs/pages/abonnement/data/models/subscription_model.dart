
class SubscriptionModel {
  final String id;
  final String driverId;
  final String plan;
  final double price;
  final DateTime startDate;
  final DateTime expiryDate;
  final bool isActive;
  final String status;
  final List<PaymentMethod> paymentMethods;

  SubscriptionModel({
    required this.id,
    required this.driverId,
    required this.plan,
    required this.price,
    required this.startDate,
    required this.expiryDate,
    required this.isActive,
    this.status = 'active',
    this.paymentMethods = const [],
  });

  int get daysRemaining {
    final now = DateTime.now();
    if (expiryDate.isBefore(now)) return 0;
    return expiryDate.difference(now).inDays;
  }

  bool get isExpiringSoon => daysRemaining <= 7 && daysRemaining > 0;
  bool get isExpired => daysRemaining == 0;

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      id: json['_id'] ?? json['id'] ?? '',
      driverId: json['driverId'] ?? json['chauffeurId'] ?? '',
      plan: json['plan'] ?? json['formule'] ?? '',
      price: (json['price'] ?? json['prix'] ?? 0).toDouble(),
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'])
          : DateTime.now(),
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'])
          : DateTime.now().add(const Duration(days: 30)),
      isActive: json['isActive'] ?? json['actif'] ?? false,
      status: json['status'] ?? json['statut'] ?? 'active',
      paymentMethods: json['paymentMethods'] != null
          ? (json['paymentMethods'] as List)
              .map((pm) => PaymentMethod.fromJson(pm))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'driverId': driverId,
      'plan': plan,
      'price': price,
      'startDate': startDate.toIso8601String(),
      'expiryDate': expiryDate.toIso8601String(),
      'isActive': isActive,
      'status': status,
      'paymentMethods': paymentMethods.map((pm) => pm.toJson()).toList(),
    };
  }
}

class PaymentMethod {
  final String id;
  final String type;
  final String? cardNumber;
  final String? phoneNumber;
  final bool isDefault;

  PaymentMethod({
    required this.id,
    required this.type,
    this.cardNumber,
    this.phoneNumber,
    this.isDefault = false,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['_id'] ?? json['id'] ?? '',
      type: json['type'] ?? '',
      cardNumber: json['cardNumber'] ?? json['numeroCarte'],
      phoneNumber: json['phoneNumber'] ?? json['numeroTelephone'],
      isDefault: json['isDefault'] ?? json['parDefaut'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'cardNumber': cardNumber,
      'phoneNumber': phoneNumber,
      'isDefault': isDefault,
    };
  }
}