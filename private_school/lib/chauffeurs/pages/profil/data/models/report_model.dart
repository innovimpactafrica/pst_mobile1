class ReportModel {
  final String id;
  final String title;
  final String description;
  final ReportType type;
  final ReportStatus status;
  final String? imageUrl;
  final DateTime createdAt;

  ReportModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.status,
    this.imageUrl,
    required this.createdAt,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? json['titre'] ?? '',
      description: json['description'] ?? '',
      type: _parseReportType(json['type']),
      status: _parseReportStatus(json['status'] ?? json['statut']),
      imageUrl: json['imageUrl'] ?? json['photo'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  static ReportType _parseReportType(String? type) {
    switch (type) {
      case 'incident':
        return ReportType.incident;
      case 'dispute':
      case 'litige':
        return ReportType.dispute;
      case 'security':
      case 'securite':
        return ReportType.security;
      default:
        return ReportType.general;
    }
  }

  static ReportStatus _parseReportStatus(String? status) {
    switch (status) {
      case 'resolved':
      case 'resolu':
        return ReportStatus.resolved;
      case 'in_progress':
      case 'en_cours':
        return ReportStatus.inProgress;
      case 'rejected':
      case 'rejete':
        return ReportStatus.rejected;
      default:
        return ReportStatus.pending;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'status': status.name,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  String get statusText {
    switch (status) {
      case ReportStatus.resolved:
        return 'Résolu';
      case ReportStatus.inProgress:
        return 'En cours';
      case ReportStatus.rejected:
        return 'Rejeté';
      default:
        return 'En attente';
    }
  }

  String get typeText {
    switch (type) {
      case ReportType.incident:
        return 'Incident';
      case ReportType.dispute:
        return 'Litiges';
      case ReportType.security:
        return 'Sécurité';
      default:
        return 'Général';
    }
  }
}

enum ReportType {
  general,
  incident,
  dispute,
  security,
}

enum ReportStatus {
  pending,
  inProgress,
  resolved,
  rejected,
}