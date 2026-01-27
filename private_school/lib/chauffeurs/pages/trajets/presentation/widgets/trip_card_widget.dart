import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:private_school/core/utils/app_colors.dart';
import 'package:private_school/core/utils/app_constants.dart';
import '../../data/models/trip_model.dart';

/// Reusable trip card widget
/// Location: lib/features/trajets/presentation/widgets/trip_card_widget.dart
class TripCardWidget extends StatelessWidget {
  final TripModel trip;
  final VoidCallback onTap;

  const TripCardWidget({super.key, required this.trip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: AppConstants.spacingL),
        padding: EdgeInsets.all(AppConstants.spacingL),
        decoration: BoxDecoration(
          color: AppColors.textWhite,
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
          boxShadow: [
            BoxShadow(
              color: AppColors.blackOpacity05,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            SizedBox(height: AppConstants.spacingM),
            _buildRoute(),
            SizedBox(height: AppConstants.spacingM),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(AppConstants.spacingS),
          decoration: BoxDecoration(
            color: AppColors.backgroundLight,
            borderRadius: BorderRadius.circular(AppConstants.radiusS),
          ),
          child: Icon(
            Icons.calendar_today,
            size: AppConstants.iconSizeM,
            color: AppColors.primary,
          ),
        ),
        SizedBox(width: AppConstants.spacingM),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _formatDate(trip.date),
                style: const TextStyle(
                  fontSize: AppConstants.fontSizeL,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '${trip.passengers.length} passagers',
                style: TextStyle(
                  fontSize: AppConstants.fontSizeM,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        _buildStatusBadge(),
      ],
    );
  }

  Widget _buildRoute() {
    return Column(
      children: [
        _buildLocationRow(
          icon: Icons.radio_button_checked,
          location: trip.startLocation ?? 'Point de départ',
          iconColor: AppColors.locationStart,
        ),
        Container(
          margin: EdgeInsets.only(left: AppConstants.spacingM),
          height: AppConstants.spacingXL,
          width: 2,
          color: AppColors.grey300,
        ),
        _buildLocationRow(
          icon: Icons.location_on,
          location: trip.destination,
          iconColor: AppColors.locationDestination,
        ),
      ],
    );
  }

  Widget _buildLocationRow({
    required IconData icon,
    required String location,
    required Color iconColor,
  }) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: AppConstants.iconSizeL),
        SizedBox(width: AppConstants.spacingM),
        Expanded(
          child: Text(
            location,
            style: const TextStyle(
              fontSize: AppConstants.fontSizeM,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppConstants.spacingM,
        vertical: AppConstants.spacingXS + 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.successBackground,
        borderRadius: BorderRadius.circular(AppConstants.radiusXL),
      ),
      child: Text(
        '${trip.availableSeats} écoles desservies',
        style: TextStyle(
          fontSize: AppConstants.fontSizeS,
          color: AppColors.success,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    final statusConfig = _getStatusConfig();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppConstants.spacingM,
        vertical: AppConstants.spacingXS + 2,
      ),
      decoration: BoxDecoration(
        color: statusConfig['bgColor'],
        borderRadius: BorderRadius.circular(AppConstants.radiusXL),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: AppConstants.spacingS,
            height: AppConstants.spacingS,
            decoration: BoxDecoration(
              color: statusConfig['textColor'],
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: AppConstants.spacingXS + 2),
          Text(
            statusConfig['label'],
            style: TextStyle(
              fontSize: AppConstants.fontSizeS,
              color: statusConfig['textColor'],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getStatusConfig() {
    switch (trip.status) {
      case AppConstants.statusPending:
        return {
          'bgColor': AppColors.statusPendingBg,
          'textColor': AppColors.statusPending,
          'label': 'En attente',
        };
      case AppConstants.statusActive:
      case AppConstants.statusStarted:
        return {
          'bgColor': AppColors.statusStartedBg,
          'textColor': AppColors.statusStarted,
          'label': 'En cours',
        };
      case AppConstants.statusCompleted:
        return {
          'bgColor': AppColors.statusCompletedBg,
          'textColor': AppColors.success,
          'label': 'Terminé',
        };
      case AppConstants.statusCanceled:
        return {
          'bgColor': AppColors.statusCanceledBg,
          'textColor': AppColors.error,
          'label': 'Annulé',
        };
      default:
        return {
          'bgColor': AppColors.imagePlaceholder,
          'textColor': AppColors.grey700,
          'label': trip.status,
        };
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final tripDate = DateTime(date.year, date.month, date.day);

    if (tripDate == today) {
      return AppConstants.labelToday;
    } else if (tripDate == tomorrow) {
      return AppConstants.labelTomorrow;
    } else {
      return DateFormat('EEEE d MMMM', 'fr_FR').format(date);
    }
  }
}
