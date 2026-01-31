// 1. CLASSE POUR LES OFFRES (MENSUELL/ANNUEL)
class SubscriptionPlan {
  final String id;
  final String name;
  final double price;
  final int durationDays;
  final List<String> features;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.price,
    required this.durationDays,
    this.features = const [],
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name'] ?? json['nom'] ?? 'Plan',
      price: (json['price'] ?? json['prix'] ?? 0).toDouble(),
      durationDays: json['durationDays'] ?? json['dureejours'] ?? 30,
      features: json['features'] != null 
          ? List<String>.from(json['features']) 
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'price': price,
    'durationDays': durationDays,
    'features': features,
  };
}

// 2. CLASSE POUR L'ABONNEMENT ACTUEL DU CHAUFFEUR
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
    final data = json['data'] ?? json; 
    
    return SubscriptionModel(
      id: data['_id']?.toString() ?? data['id']?.toString() ?? '',
      driverId: data['driver_id']?.toString() ?? data['chauffeur_id']?.toString() ?? '',
      plan: data['plan'] ?? data['formule'] ?? data['libelle'] ?? 'Plan Standard',
      price: (data['price'] ?? data['prix'] ?? 0).toDouble(),
      startDate: data['startDate'] != null 
          ? DateTime.parse(data['startDate']) 
          : (data['date_creation'] != null ? DateTime.parse(data['date_creation']) : DateTime.now()),
      expiryDate: data['expiryDate'] != null 
          ? DateTime.parse(data['expiryDate']) 
          : DateTime.now().add(const Duration(days: 30)),
      isActive: data['isActive'] ?? (data['statut'] == 'active') ?? false,
      status: data['status'] ?? data['statut'] ?? 'active',
      paymentMethods: data['paymentMethods'] != null
          ? (data['paymentMethods'] as List).map((pm) => PaymentMethod.fromJson(pm)).toList()
          : const [],
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

// 3. CLASSE POUR LES MOYENS DE PAIEMENT
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