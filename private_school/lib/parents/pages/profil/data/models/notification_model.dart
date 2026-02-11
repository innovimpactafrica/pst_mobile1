import 'package:flutter/material.dart';

enum NotificationType {
  tripStarted,
  tripCompleted,
  weatherAlert,
  subscription,
  payment,
  child,
  incident,
  general,
}

class NotificationModel {
  final String id;
  final String title;        // libelle
  final String message;      // description
  final String type;         // type
  final String? imageUrl;    // image_url
  final int? emetteurId;     // emetteur_id
  final String? emetteurNom; // emetteur_nom
  final DateTime dateCreation; // date_creation
  final String statut;       // statut
  final String? nbDestinataires; // nb_destinataires
  final String? nbLus;       // nb_lus
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.imageUrl,
    this.emetteurId,
    this.emetteurNom,
    required this.dateCreation,
    required this.statut,
    this.nbDestinataires,
    this.nbLus,
    this.isRead = false,
  });

  NotificationType get notificationType {
    final lowerType = type.toLowerCase();
    
    if (lowerType.contains('trip') || lowerType.contains('trajet')) {
      return NotificationType.tripStarted;
    }
    if (lowerType.contains('incident')) {
      return NotificationType.incident;
    }
    if (lowerType.contains('subscription') || lowerType.contains('abonnement')) {
      return NotificationType.subscription;
    }
    if (lowerType.contains('payment') || lowerType.contains('paiement')) {
      return NotificationType.payment;
    }
    if (lowerType.contains('child') || lowerType.contains('enfant')) {
      return NotificationType.child;
    }
    if (lowerType.contains('weather') || lowerType.contains('météo')) {
      return NotificationType.weatherAlert;
    }
    
    return NotificationType.general;
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(dateCreation);

    if (difference.inDays > 7) {
      return 'Il y a ${(difference.inDays / 7).floor()} semaine${difference.inDays > 14 ? 's' : ''}';
    } else if (difference.inDays > 0) {
      return 'Il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'Il y a ${difference.inHours} heure${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'Il y a ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return "À l'instant";
    }
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('🔍 [NotificationModel] Parsing notification:');
    debugPrint('   ID: ${json['id']}');
    debugPrint('   Libelle: ${json['libelle']}');
    debugPrint('   Type: ${json['type']}');
    debugPrint('   Description: ${json['description']}');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    // Déterminer si la notification est lue
    bool isRead = false;
    if (json['nb_lus'] != null && json['nb_destinataires'] != null) {
      try {
        final lus = int.parse(json['nb_lus'].toString());
        final total = int.parse(json['nb_destinataires'].toString());
        isRead = lus > 0 || total > 0;
      } catch (e) {
        debugPrint('⚠️ Erreur parsing nb_lus/nb_destinataires: $e');
      }
    }

    return NotificationModel(
      id: json['id']?.toString() ?? '',
      title: json['libelle']?.toString() ?? 'Notification',
      message: json['description']?.toString() ?? '',
      type: json['type']?.toString() ?? 'general',
      imageUrl: json['image_url']?.toString(),
      emetteurId: json['emetteur_id'] != null 
          ? int.tryParse(json['emetteur_id'].toString()) 
          : null,
      emetteurNom: json['emetteur_nom']?.toString(),
      dateCreation: json['date_creation'] != null
          ? DateTime.parse(json['date_creation'].toString())
          : DateTime.now(),
      statut: json['statut']?.toString() ?? 'active',
      nbDestinataires: json['nb_destinataires']?.toString(),
      nbLus: json['nb_lus']?.toString(),
      isRead: isRead,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'libelle': title,
      'description': message,
      'type': type,
      'image_url': imageUrl,
      'emetteur_id': emetteurId,
      'emetteur_nom': emetteurNom,
      'date_creation': dateCreation.toIso8601String(),
      'statut': statut,
      'nb_destinataires': nbDestinataires,
      'nb_lus': nbLus,
    };
  }

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    String? type,
    String? imageUrl,
    int? emetteurId,
    String? emetteurNom,
    DateTime? dateCreation,
    String? statut,
    String? nbDestinataires,
    String? nbLus,
    bool? isRead,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      imageUrl: imageUrl ?? this.imageUrl,
      emetteurId: emetteurId ?? this.emetteurId,
      emetteurNom: emetteurNom ?? this.emetteurNom,
      dateCreation: dateCreation ?? this.dateCreation,
      statut: statut ?? this.statut,
      nbDestinataires: nbDestinataires ?? this.nbDestinataires,
      nbLus: nbLus ?? this.nbLus,
      isRead: isRead ?? this.isRead,
    );
  }
}