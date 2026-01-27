class DocumentModel {
  final String id;
  final String name;
  final String type; // 'license' or 'id_card'
  final String? fileUrl;
  final int? fileSizeKB;
  final DateTime? uploadedAt;
  final bool isVerified;

  DocumentModel({
    required this.id,
    required this.name,
    required this.type,
    this.fileUrl,
    this.fileSizeKB,
    this.uploadedAt,
    this.isVerified = false,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? json['nom'] ?? '',
      type: json['type'] ?? '',
      fileUrl: json['fileUrl'] ?? json['url'],
      fileSizeKB: json['fileSizeKB'] ?? json['tailleFichier'],
      uploadedAt: json['uploadedAt'] != null 
          ? DateTime.parse(json['uploadedAt'])
          : null,
      isVerified: json['isVerified'] ?? json['verifie'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'fileUrl': fileUrl,
      'fileSizeKB': fileSizeKB,
      'uploadedAt': uploadedAt?.toIso8601String(),
      'isVerified': isVerified,
    };
  }

  String get formattedSize {
    if (fileSizeKB == null) return '';
    if (fileSizeKB! < 1024) {
      return '$fileSizeKB Ko';
    } else {
      return '${(fileSizeKB! / 1024).toStringAsFixed(1)} Mo';
    }
  }

  String get displayName {
    switch (type) {
      case 'license':
        return 'Permis de conduire';
      case 'id_card':
        return 'CNI/Passeport';
      default:
        return name;
    }
  }
}