// Incident Model
// Path: lib/parents/profil/data/models/incident_model.dart

class IncidentModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String status;
  final DateTime createdAt;
  final String? imageUrl;
  final String? response;
  
  IncidentModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.status = 'Nouveau',
    required this.createdAt,
    this.imageUrl,
    this.response,
  });

  factory IncidentModel.fromJson(Map<String, dynamic> json) {
    return IncidentModel(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? json['titre'] ?? '',
      description: json['description'] ?? json['details'] ?? '',
      category: json['category'] ?? json['categorie'] ?? 'Incident',
      status: json['status'] ?? json['statut'] ?? 'Nouveau',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      imageUrl: json['imageUrl'] ?? json['image'],
      response: json['response'] ?? json['reponse'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'status': status,
      'imageUrl': imageUrl,
    };
  }

  IncidentModel copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? status,
    DateTime? createdAt,
    String? imageUrl,
    String? response,
  }) {
    return IncidentModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      imageUrl: imageUrl ?? this.imageUrl,
      response: response ?? this.response,
    );
  }

  int get statusColorValue {
    switch (status.toLowerCase()) {
      case 'résolu':
      case 'resolu':
        return 0xFF4CAF50;
      case 'en cours':
        return 0xFFFF9800;
      case 'rejeté':
      case 'rejete':
        return 0xFFF44336;
      default:
        return 0xFF2196F3;
    }
  }
}