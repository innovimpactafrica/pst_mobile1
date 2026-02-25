import 'package:flutter/material.dart';

class EvaluationModel {
  final int? id;
  final int tripId;
  final int? driverId;
  final int? parentId;
  final String? parentName;
  final int rating;
  final String? badge; // ponctuel, professionnel, sympathique
  final String? comment;
  final DateTime? createdAt;

  EvaluationModel({
    this.id,
    required this.tripId,
    this.driverId,
    this.parentId,
    this.parentName,
    required this.rating,
    this.badge,
    this.comment,
    this.createdAt,
  });

  // Getter pour la date formatée
  String get formattedDate {
    if (createdAt == null) return '';
    return '${createdAt!.day}/${createdAt!.month}/${createdAt!.year}';
  }

  factory EvaluationModel.fromJson(Map<String, dynamic> json) {
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint(' [EvaluationModel] Parsing evaluation:');
    debugPrint('   ID: ${json['id']}');
    debugPrint('   Trip ID: ${json['trip_id']}');
    debugPrint('   Rating: ${json['rating']}');
    debugPrint('   Parent: ${json['parent_name']}');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    return EvaluationModel(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      tripId: int.parse(json['trip_id'].toString()),
      driverId: json['driver_id'] != null
          ? int.tryParse(json['driver_id'].toString())
          : null,
      parentId: json['parent_id'] != null
          ? int.tryParse(json['parent_id'].toString())
          : null,
      parentName: json['parent_name']?.toString(),
      rating: int.parse(json['rating'].toString()),
      badge: json['badge']?.toString(),
      comment: json['comment']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'trip_id': tripId,
      if (driverId != null) 'driver_id': driverId,
      if (parentId != null) 'parent_id': parentId,
      if (parentName != null) 'parent_name': parentName,
      'rating': rating,
      if (badge != null) 'badge': badge,
      if (comment != null && comment!.isNotEmpty) 'comment': comment,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  EvaluationModel copyWith({
    int? id,
    int? tripId,
    int? driverId,
    int? parentId,
    String? parentName,
    int? rating,
    String? badge,
    String? comment,
    DateTime? createdAt,
  }) {
    return EvaluationModel(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      driverId: driverId ?? this.driverId,
      parentId: parentId ?? this.parentId,
      parentName: parentName ?? this.parentName,
      rating: rating ?? this.rating,
      badge: badge ?? this.badge,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
