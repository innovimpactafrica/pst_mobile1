// Upcoming trips section widget
// Path: lib/chauffeurs/pages/dashboard/presentation/widgets/upcoming_trips_section.dart

import 'package:flutter/material.dart';
import 'package:private_school/core/utils/app_colors.dart';
import 'package:intl/intl.dart';

class UpcomingTripsSection extends StatelessWidget {
  final List<dynamic> upcomingTrips;
  final List<dynamic> todayTrips;

  const UpcomingTripsSection({
    super.key,
    required this.upcomingTrips,
    required this.todayTrips,
  });

  @override
  Widget build(BuildContext context) {
    final allTrips = [...todayTrips, ...upcomingTrips];

    if (allTrips.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Icon(
                Icons.route_outlined,
                size: 48,
                color: AppColors.textSecondary.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'Aucun trajet à venir',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Vos prochains trajets apparaîtront ici',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary.withValues(alpha: 0.5),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: allTrips.length,
        itemBuilder: (context, index) {
          return _buildTripCard(allTrips[index]);
        },
      ),
    );
  }

  Widget _buildTripCard(dynamic trip) {
    // Extract trip data safely
    final date = trip is Map && trip['date'] != null 
        ? DateTime.tryParse(trip['date'].toString()) ?? DateTime.now()
        : DateTime.now();
    final passengers = trip is Map ? (trip['passengers'] ?? 0) : 0;
    
    // ✅ FIX: Gérer schools comme liste OU nombre
    int schools = 0;
    if (trip is Map && trip['schools'] != null) {
      if (trip['schools'] is List) {
        schools = (trip['schools'] as List).length;
      } else if (trip['schools'] is int) {
        schools = trip['schools'] as int;
      } else {
        schools = int.tryParse(trip['schools'].toString()) ?? 0;
      }
    }
    
    final dateFormatter = DateFormat('dd MMM', 'fr_FR');

    return Container(
      width: 300,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with date badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: AppColors.white,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      dateFormatter.format(date),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'En attente',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Location info
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.location_on_outlined,
                  color: AppColors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '123 Avenue des Champs-Élysées',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.white.withValues(alpha: 0.9),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ouakam',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Passengers info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.people_outline,
                  color: AppColors.white,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  '$passengers passagers',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
                const Spacer(),
                Text(
                  '$schools école${schools > 1 ? 's' : ''} desservie${schools > 1 ? 's' : ''}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}