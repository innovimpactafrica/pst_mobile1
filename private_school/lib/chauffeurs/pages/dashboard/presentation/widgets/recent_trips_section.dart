import 'package:flutter/material.dart';
import 'package:private_school/core/utils/app_colors.dart';
import 'package:private_school/core/utils/app_constants.dart';
import '../../data/models/dashboard_model.dart';

/// Recent trips section for dashboard
/// Location: lib/features/dashboard/presentation/widgets/recent_trips_section.dart
class RecentTripsSection extends StatelessWidget {
  final List<RecentTrip> trips;

  const RecentTripsSection({
    super.key,
    required this.trips,
  });

  @override
  Widget build(BuildContext context) {
    if (trips.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingXL),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                AppConstants.labelRecentTrips,
                style: TextStyle(
                  fontSize: AppConstants.fontSizeXL,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to all trips
                },
                child: const Text(
                  AppConstants.labelViewAll,
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeM,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppConstants.spacingM),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingXL),
          itemCount: trips.length > 3 ? 3 : trips.length,
          itemBuilder: (context, index) {
            return _buildTripCard(trips[index]);
          },
        ),
      ],
    );
  }

  Widget _buildTripCard(RecentTrip trip) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingM),
      padding: const EdgeInsets.all(AppConstants.spacingM),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Row(
        children: [
          Container(
            width: AppConstants.avatarSizeL,
            height: AppConstants.avatarSizeL,
            decoration: BoxDecoration(
              color: _getStatusColor(trip.status).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
            ),
            child: Icon(
              Icons.directions_car,
              color: _getStatusColor(trip.status),
              size: AppConstants.iconSizeL,
            ),
          ),
          const SizedBox(width: AppConstants.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trip.destination,
                  style: const TextStyle(
                    fontSize: AppConstants.fontSizeL,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${trip.passengers} passagers',
                  style: const TextStyle(
                    fontSize: AppConstants.fontSizeM,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          _buildStatusBadge(trip.status),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final config = _getStatusConfig(status);
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingS,
        vertical: AppConstants.spacingXS,
      ),
      decoration: BoxDecoration(
        color: config['bgColor'],
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
      ),
      child: Text(
        config['label'],
        style: TextStyle(
          fontSize: AppConstants.fontSizeS,
          color: config['color'],
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Map<String, dynamic> _getStatusConfig(String status) {
    switch (status) {
      case AppConstants.statusCompleted:
        return {
          'color': AppColors.success,
          'bgColor': AppColors.successBackground,
          'label': 'Terminé',
        };
      case AppConstants.statusActive:
      case AppConstants.statusStarted:
        return {
          'color': AppColors.warning,
          'bgColor': AppColors.warningBackground,
          'label': 'En cours',
        };
      case AppConstants.statusCanceled:
        return {
          'color': AppColors.error,
          'bgColor': AppColors.errorBackground,
          'label': 'Annulé',
        };
      default:
        return {
          'color': AppColors.info,
          'bgColor': AppColors.infoBackground,
          'label': 'En attente',
        };
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case AppConstants.statusCompleted:
        return AppColors.success;
      case AppConstants.statusActive:
      case AppConstants.statusStarted:
        return AppColors.warning;
      case AppConstants.statusCanceled:
        return AppColors.error;
      default:
        return AppColors.info;
    }
  }
}