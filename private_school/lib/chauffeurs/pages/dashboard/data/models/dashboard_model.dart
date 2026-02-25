class DashboardModel {
  final DriverInfo driver;
  final DashboardStats stats;
  final List<dynamic> upcomingTripsList;
  final List<dynamic> todayTrips;
  final List<NotificationItem> notifications;
  final int unreadNotificationsCount;
  final List<dynamic> recentBookings;
  final SubscriptionStatus? subscription;

  DashboardModel({
    required this.driver,
    required this.stats,
    this.upcomingTripsList = const [],
    this.todayTrips = const [],
    this.notifications = const [],
    this.unreadNotificationsCount = 0,
    this.recentBookings = const [],
    this.subscription,
  });

  int get totalTrips => stats.completedTrips + stats.upcomingTrips;
  int get completedTrips => stats.completedTrips;
  int get canceledTrips => stats.canceledTrips;
  int get upcomingTrips => stats.upcomingTrips;
  double get totalEarnings => 0.0;
  double get monthlyEarnings => 0.0;
  int get activePassengers => stats.totalChildrenTransported;
  double get rating => stats.averageRating;
  List<dynamic> get recentTrips => [
    ...upcomingTripsList,
    ...todayTrips,
    ...recentBookings,
  ];

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      driver: DriverInfo.fromJson(json['driver'] ?? {}),
      stats: DashboardStats.fromJson(json['stats'] ?? {}),
      upcomingTripsList: json['upcomingTrips'] != null
          ? (json['upcomingTrips'] as List).map((trip) => trip).toList()
          : [],

      todayTrips: json['todayTrips'] != null
          ? (json['todayTrips'] as List).map((trip) => trip).toList()
          : [],

      notifications: json['notifications'] != null
          ? (json['notifications'] as List)
                .map((notif) => NotificationItem.fromJson(notif))
                .toList()
          : [],

      unreadNotificationsCount: json['unreadNotificationsCount'] ?? 0,

      recentBookings: json['recentBookings'] != null
          ? (json['recentBookings'] as List).map((booking) => booking).toList()
          : [],

      subscription: json['subscription'] != null
          ? SubscriptionStatus.fromJson(json['subscription'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'driver': driver.toJson(),
      'stats': stats.toJson(),
      'upcomingTrips': upcomingTripsList,
      'todayTrips': todayTrips,
      'notifications': notifications.map((notif) => notif.toJson()).toList(),
      'unreadNotificationsCount': unreadNotificationsCount,
      'recentBookings': recentBookings,
      'subscription': subscription?.toJson(),
    };
  }
}

class DriverInfo {
  final int id;
  final int userId;
  final String name;
  final String status;

  DriverInfo({
    required this.id,
    required this.userId,
    required this.name,
    required this.status,
  });

  factory DriverInfo.fromJson(Map<String, dynamic> json) {
    return DriverInfo(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      name: json['name'] ?? '',
      status: json['status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'user_id': userId, 'name': name, 'status': status};
  }
}

class DashboardStats {
  final int completedTrips;
  final int canceledTrips;
  final int upcomingTrips;
  final int missedTrips;
  final double averageRating;
  final int totalEvaluations;
  final int fiveStarCount;
  final int fourStarCount;
  final int threeStarCount;
  final int lowRatingCount;
  final int totalChildrenTransported;
  final int tripsThisMonth;
  final int tripsThisWeek;

  DashboardStats({
    this.completedTrips = 0,
    this.canceledTrips = 0,
    this.upcomingTrips = 0,
    this.missedTrips = 0,
    this.averageRating = 0.0,
    this.totalEvaluations = 0,
    this.fiveStarCount = 0,
    this.fourStarCount = 0,
    this.threeStarCount = 0,
    this.lowRatingCount = 0,
    this.totalChildrenTransported = 0,
    this.tripsThisMonth = 0,
    this.tripsThisWeek = 0,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    int parseToInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    double parseToDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return DashboardStats(
      completedTrips: parseToInt(json['completed_trips']),
      canceledTrips: parseToInt(json['canceled_trips']),
      upcomingTrips: parseToInt(json['upcoming_trips']),
      missedTrips: parseToInt(json['missed_trips']),
      averageRating: parseToDouble(json['average_rating']),
      totalEvaluations: parseToInt(json['total_evaluations']),
      fiveStarCount: parseToInt(json['five_star_count']),
      fourStarCount: parseToInt(json['four_star_count']),
      threeStarCount: parseToInt(json['three_star_count']),
      lowRatingCount: parseToInt(json['low_rating_count']),
      totalChildrenTransported: parseToInt(json['total_children_transported']),
      tripsThisMonth: parseToInt(json['trips_this_month']),
      tripsThisWeek: parseToInt(json['trips_this_week']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'completed_trips': completedTrips,
      'canceled_trips': canceledTrips,
      'upcoming_trips': upcomingTrips,
      'missed_trips': missedTrips,
      'average_rating': averageRating,
      'total_evaluations': totalEvaluations,
      'five_star_count': fiveStarCount,
      'four_star_count': fourStarCount,
      'three_star_count': threeStarCount,
      'low_rating_count': lowRatingCount,
      'total_children_transported': totalChildrenTransported,
      'trips_this_month': tripsThisMonth,
      'trips_this_week': tripsThisWeek,
    };
  }
}

class NotificationItem {
  final int id;
  final String title;
  final String type;
  final String description;
  final String? imageUrl;
  final DateTime dateCreation;
  final String status;
  final bool isRead;
  final DateTime? dateRead;
  final String emitterName;
  final String emitterRole;

  NotificationItem({
    required this.id,
    required this.title,
    required this.type,
    required this.description,
    this.imageUrl,
    required this.dateCreation,
    required this.status,
    this.isRead = false,
    this.dateRead,
    required this.emitterName,
    required this.emitterRole,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] ?? 0,
      title: json['libelle'] ?? json['title'] ?? '',
      type: json['type'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['image_url'],
      dateCreation: json['date_creation'] != null
          ? DateTime.tryParse(json['date_creation'].toString()) ??
                DateTime.now()
          : DateTime.now(),
      status: json['statut'] ?? json['status'] ?? '',
      isRead: json['lu'] ?? json['isRead'] ?? false,
      dateRead: json['date_lecture'] != null
          ? DateTime.tryParse(json['date_lecture'].toString())
          : null,
      emitterName: json['emetteur_name'] ?? json['emitterName'] ?? '',
      emitterRole: json['emetteur_role'] ?? json['emitterRole'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'libelle': title,
      'type': type,
      'description': description,
      'image_url': imageUrl,
      'date_creation': dateCreation.toIso8601String(),
      'statut': status,
      'lu': isRead,
      'date_lecture': dateRead?.toIso8601String(),
      'emetteur_name': emitterName,
      'emetteur_role': emitterRole,
    };
  }
}

class SubscriptionStatus {
  final String plan;
  final DateTime? expiryDate;
  final bool isActive;
  final int daysRemaining;

  SubscriptionStatus({
    required this.plan,
    this.expiryDate,
    required this.isActive,
    this.daysRemaining = 0,
  });

  factory SubscriptionStatus.fromJson(Map<String, dynamic> json) {
    return SubscriptionStatus(
      plan: json['plan'] ?? json['formule'] ?? '',
      expiryDate: json['expiryDate'] != null
          ? DateTime.tryParse(json['expiryDate'].toString())
          : null,
      isActive: json['isActive'] ?? json['actif'] ?? false,
      daysRemaining: json['daysRemaining'] ?? json['joursRestants'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'plan': plan,
      'expiryDate': expiryDate?.toIso8601String(),
      'isActive': isActive,
      'daysRemaining': daysRemaining,
    };
  }
}
