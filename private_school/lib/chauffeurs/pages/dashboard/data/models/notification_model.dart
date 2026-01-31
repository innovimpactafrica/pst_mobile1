

class NotificationModel {
  final int id;
  final String title;
  final String type;
  final String description;
  final String? imageUrl;
  final DateTime dateCreation;
  final String status;
  final bool isRead;
  final DateTime? dateLecture;
  final String emetteurName;
  final String emetteurRole;

  NotificationModel({
    required this.id,
    required this.title,
    required this.type,
    required this.description,
    this.imageUrl,
    required this.dateCreation,
    required this.status,
    required this.isRead,
    this.dateLecture,
    required this.emetteurName,
    required this.emetteurRole,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as int,
      title: json['libelle'] as String? ?? '',
      type: json['type'] as String? ?? '',
      description: json['description'] as String? ?? '',
      imageUrl: json['image_url'] as String?,
      dateCreation: DateTime.parse(json['date_creation'] as String),
      status: json['statut'] as String? ?? 'active',
      isRead: json['lu'] as bool? ?? false,
      dateLecture: json['date_lecture'] != null
          ? DateTime.parse(json['date_lecture'] as String)
          : null,
      emetteurName: json['emetteur_name'] as String? ?? '',
      emetteurRole: json['emetteur_role'] as String? ?? '',
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
      'date_lecture': dateLecture?.toIso8601String(),
      'emetteur_name': emetteurName,
      'emetteur_role': emetteurRole,
    };
  }

  NotificationModel copyWith({
    int? id,
    String? title,
    String? type,
    String? description,
    String? imageUrl,
    DateTime? dateCreation,
    String? status,
    bool? isRead,
    DateTime? dateLecture,
    String? emetteurName,
    String? emetteurRole,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      dateCreation: dateCreation ?? this.dateCreation,
      status: status ?? this.status,
      isRead: isRead ?? this.isRead,
      dateLecture: dateLecture ?? this.dateLecture,
      emetteurName: emetteurName ?? this.emetteurName,
      emetteurRole: emetteurRole ?? this.emetteurRole,
    );
  }
}