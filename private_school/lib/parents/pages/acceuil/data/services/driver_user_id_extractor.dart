import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:private_school/core/storage/secure_storage.dart';
import 'package:private_school/core/network/api_client.dart';

class DriverUserIdExtractor {
  final ApiClient _apiClient = ApiClient();
  Future<List<Map<String, dynamic>>> getAllDriversWithUserId() async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint(' Extraction des chauffeurs avec user_id...');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final driversMap = <int, Map<String, dynamic>>{};
      final availableResponse = await _apiClient.get(
        '/api/parents/trips/available',
      );
      final availableData = availableResponse.data;

      List<dynamic> availableTrips = [];
      if (availableData is Map && availableData['data'] != null) {
        availableTrips = availableData['data'] as List;
      } else if (availableData is List) {
        availableTrips = availableData;
      }

      debugPrint(' Trajets disponibles: ${availableTrips.length}');

      //  Récupérer trajets réservés (JSON brut)
      final reservedResponse = await _apiClient.get('/api/parents/trips');
      final reservedData = reservedResponse.data;

      List<dynamic> reservedTrips = [];
      if (reservedData is Map && reservedData['data'] != null) {
        reservedTrips = reservedData['data'] as List;
      } else if (reservedData is List) {
        reservedTrips = reservedData;
      }

      debugPrint(' Trajets réservés: ${reservedTrips.length}');

      final allTrips = [...availableTrips, ...reservedTrips];
      debugPrint(' Total trajets: ${allTrips.length}');

      //  Extraire les chauffeurs avec user_id
      for (final tripJson in allTrips) {
        if (tripJson is! Map<String, dynamic>) continue;

        // Objet driver complet avec user_id
        if (tripJson['driver'] != null && tripJson['driver'] is Map) {
          final driverJson = tripJson['driver'] as Map<String, dynamic>;

          final int? userId = driverJson['user_id'] as int?;
          final int? driverId = driverJson['id'] as int?;
          final String? name = driverJson['name'] as String?;
          final String? phone = driverJson['phone'] as String?;
          final String? photo = driverJson['photo_profil'] as String?;

          if (userId != null && name != null) {
            if (!driversMap.containsKey(userId)) {
              String? fullPhotoUrl;
              if (photo != null && photo.isNotEmpty) {
                fullPhotoUrl = photo.startsWith('http')
                    ? photo
                    : 'http://86.106.181.31:3000$photo';
              }

              driversMap[userId] = {
                'id': userId,
                'driver_id': driverId,
                'name': name,
                'role': 'driver',
                'phone': phone,
                'photo': fullPhotoUrl,
                'rating': null,
              };

              debugPrint('    Chauffeur ajouté: $name');
              debugPrint(
                '      - user_id: $userId ← UTILISÉ POUR LA MESSAGERIE',
              );
              debugPrint('      - driver_id: $driverId');
            } else {
              debugPrint('   Chauffeur déjà présent: $name (user_id: $userId)');
            }
          }
        } else if (tripJson['driver_name'] != null) {
          final int? driverId = tripJson['driver_id'] as int?;
          final String? name = tripJson['driver_name'] as String?;
          final String? phone = tripJson['driver_phone'] as String?;
          final String? photo = tripJson['driver_photo'] as String?;
          final dynamic rating = tripJson['driver_rating'];

          if (driverId != null && name != null) {
            if (!driversMap.containsKey(driverId)) {
              debugPrint(
                '   Chauffeur sans user_id: $name (driver_id: $driverId)',
              );
              debugPrint('      On utilise driver_id temporairement');

              String? fullPhotoUrl;
              if (photo != null && photo.isNotEmpty) {
                fullPhotoUrl = photo.startsWith('http')
                    ? photo
                    : 'http://86.106.181.31:3000$photo';
              }

              driversMap[driverId] = {
                'id': driverId,
                'driver_id': driverId,
                'name': name,
                'role': 'driver',
                'phone': phone,
                'photo': fullPhotoUrl,
                'rating': rating,
                'warning': 'user_id non disponible, utilise driver_id',
              };
            } else {
              debugPrint(
                '   Chauffeur déjà présent: $name (driver_id: $driverId)',
              );
            }
          }
        }
      }

      final storage = SecureStorage();
      final userDataRaw = await storage.getUserData();
      int? currentUserId;

      if (userDataRaw != null && userDataRaw.isNotEmpty) {
        try {
          final decoded = jsonDecode(userDataRaw) as Map<String, dynamic>;
          currentUserId = decoded['id'] as int?;
          if (currentUserId != null) {
            driversMap.remove(currentUserId);
            debugPrint(' Utilisateur actuel exclu (ID: $currentUserId)');
          }
        } catch (e) {
          debugPrint(' Erreur parsing user data: $e');
        }
      }

      final allDrivers = driversMap.values.toList();
      final validDrivers = allDrivers
          .where((d) => d['warning'] == null)
          .toList();

      validDrivers.sort(
        (a, b) => (a['name'] as String).compareTo(b['name'] as String),
      );

      debugPrint('');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint(' RÉSULTAT:');
      debugPrint('   Total chauffeurs: ${allDrivers.length}');
      debugPrint('   - Avec user_id: ${validDrivers.length} ✅ AFFICHÉS');
      debugPrint(
        '   - Sans user_id: ${allDrivers.length - validDrivers.length} ⚠️ EXCLUS',
      );

      if (validDrivers.length < allDrivers.length) {
        debugPrint('');
        debugPrint(
          ' ATTENTION: ${allDrivers.length - validDrivers.length} chauffeurs exclus car sans user_id',
        );
        debugPrint('   Ces chauffeurs ne peuvent pas être ajoutés aux groupes');
        debugPrint(
          '   Demandez au backend de fournir user_id pour tous les chauffeurs',
        );
      }
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      return validDrivers;
    } catch (e, stackTrace) {
      debugPrint('');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('ERREUR: $e');
      debugPrint('Stack: $stackTrace');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      rethrow;
    }
  }
}
