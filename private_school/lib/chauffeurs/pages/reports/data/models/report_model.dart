
class ReportModel {
  final int id;
  final int userId;
  final String type; 
  final String category; 
  final String description;
  final String status;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final String? imageUrl;
  final String? driverName;
  final String? vehiclePlate;

  ReportModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.category,
    required this.description,
    required this.status,
    required this.createdAt,
    this.resolvedAt,
    this.imageUrl,
    this.driverName,
    this.vehiclePlate,
  });

 
  factory ReportModel.fromJson(Map<String, dynamic> json) {
    List<dynamic> docs = json['documents'] ?? [];
    String? firstImageUrl;
    if (docs.isNotEmpty && docs[0]['url'] != null) {
      firstImageUrl = docs[0]['url'];
    }

    return ReportModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      type: json['type_de_problem'] ?? json['type'] ?? 'incident',
      category: json['category'] ?? json['type_de_problem'] ?? 'Signalement',
      
      description: json['description'] ?? '',
      status: json['status'] ?? 'En cours',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      resolvedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      imageUrl: firstImageUrl,
      driverName: json['nom_chauffeur'],
      vehiclePlate: json['plaque_vehicule'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type_de_problem': type, 
      'category': category,
      'description': description,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'resolved_at': resolvedAt?.toIso8601String(),
      'image_url': imageUrl,
      'driver_name': driverName,
      'vehicle_plate': vehiclePlate,
    };
  }

  // Helper pour obtenir la couleur du statut
  String get statusColorName {
    switch (status.toLowerCase()) {
      case 'résolu':
      case 'resolved':
        return 'success';
      case 'en cours':
      case 'in_progress':
      case 'pending':
        return 'warning';
      case 'rejeté':
      case 'rejected':
        return 'error';
      default:
        return 'warning';
    }
  }

  // Helper pour obtenir le type traduit
  String get typeLabel {
    switch (type.toLowerCase()) {
      case 'incident':
        return 'Incident';
      case 'litige':
        return 'Litiges';
      case 'securite':
      case 'sécurité':
        return 'Sécurité';
      default:
        return type;
    }
  }
}