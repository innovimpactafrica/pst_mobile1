import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:private_school/core/utils/app_colors.dart';
import 'package:private_school/core/utils/app_constants.dart';
import '../../data/models/trip_model.dart';
import '../../domain/bloc/trip_bloc.dart';
import '../../domain/bloc/trip_event.dart';
import 'passengers_list_modal.dart';
import 'schools_list_modal.dart';

/// Trip detail modal with full information
/// Location: lib/features/trajets/presentation/widgets/trip_detail_modal.dart
class TripDetailModal extends StatelessWidget {
  final TripModel trip;
  const TripDetailModal({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return Container(
      height:
          MediaQuery.of(context).size.height * AppConstants.modalHeightFactor,
      decoration: const BoxDecoration(
        color: AppColors.textWhite,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppConstants.radiusXXL),
          topRight: Radius.circular(AppConstants.radiusXXL),
        ),
      ),
      child: Column(
        children: [
          _buildHandle(),
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildMap(),
                  _buildTripInfo(),
                  _buildPassengersSection(context),
                  _buildSchoolsSection(context),
                  if (trip.status == AppConstants.statusCompleted)
                    _buildReviewsSection(),
                ],
              ),
            ),
          ),
          if (trip.status == AppConstants.statusPending ||
              trip.status == AppConstants.statusActive)
            _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      margin:  EdgeInsets.only(
        top: AppConstants.spacingM,
        bottom: AppConstants.spacingS,
      ),
      width: AppConstants.modalHandleWidth,
      height: AppConstants.modalHandleHeight,
      decoration: BoxDecoration(
        color: AppColors.grey300,
        borderRadius: BorderRadius.circular(AppConstants.radiusS / 4),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingXL,
        vertical: AppConstants.spacingL,
      ),
      decoration: const BoxDecoration(
        color: AppColors.primary
,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppConstants.radiusXXL),
          topRight: Radius.circular(AppConstants.radiusXXL),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textWhite),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: AppConstants.spacingS),
          Expanded(
            child: Text(
              '${trip.startLocation ?? "Dakar"} → ${trip.destination}',
              style: const TextStyle(
                color: AppColors.textWhite,
                fontSize: AppConstants.fontSizeXL,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return Container(
      height: AppConstants.mapHeight,
      margin: const EdgeInsets.all(AppConstants.spacingXL),
      decoration: BoxDecoration(
        color: AppColors.grey200,
        borderRadius: BorderRadius.circular(AppConstants.mapBorderRadius),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.mapBorderRadius),
            child: Container(
              color: AppColors.grey300,
              child: const Center(
                child: Icon(
                  Icons.map,
                  size: AppConstants.iconSizeXXXL,
                  color: AppColors.grey600,
                ),
              ),
            ),
          ),
          Positioned(
            top: AppConstants.spacingL,
            right: AppConstants.spacingL,
            child: Container(
              padding: const EdgeInsets.all(AppConstants.spacingS),
              decoration: BoxDecoration(
                color: AppColors.textWhite,
                borderRadius: BorderRadius.circular(AppConstants.radiusXL),
              ),
              child: const Icon(
                Icons.my_location,
                size: AppConstants.iconSizeM,
                color: AppColors.primary
,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spacingXL),
      padding: const EdgeInsets.all(AppConstants.spacingL),
      decoration: BoxDecoration(
        color: AppColors.textWhite,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppConstants.spacingS),
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight
,
                  borderRadius: BorderRadius.circular(AppConstants.radiusS),
                ),
                child: const Icon(
                  Icons.calendar_today,
                  size: AppConstants.iconSizeM,
                  color: AppColors.primary
,
                ),
              ),
              const SizedBox(width: AppConstants.spacingM),
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
                        '${trip.schools.length} ${trip.schools.length > 1 ? "écoles desservies" : "école desservie"}',
                        style: const TextStyle(
                        fontSize: AppConstants.fontSizeM,
                      color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              _buildStatusBadge(),
            ],
          ),
          const SizedBox(height: AppConstants.spacingL),
          const Divider(color: AppColors.divider),
          const SizedBox(height: AppConstants.spacingL),
          _buildRouteInfo(
            icon: Icons.radio_button_checked,
            label: AppConstants.labelStartPoint,
            location: trip.startLocation ?? '123 Avenue des Champs-Élysées',
            time: '06:30',
            color: AppColors.locationStart,
          ),
          Container(
            margin: const EdgeInsets.only(
              left: AppConstants.spacingM,
              top: AppConstants.spacingXS,
              bottom: AppConstants.spacingXS,
            ),
            height: AppConstants.spacingXL,
            width: 2,
            color: AppColors.grey300,
          ),
          _buildRouteInfo(
            icon: Icons.location_on,
            label: AppConstants.labelDestination,
            location: trip.destination,
            time: '07:30',
            color: AppColors.locationDestination,
          ),
        ],
      ),
    );
  }

  Widget _buildRouteInfo({
    required IconData icon,
    required String label,
    required String location,
    required String time,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: AppConstants.iconSizeL),
        const SizedBox(width: AppConstants.spacingM),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: AppConstants.fontSizeS,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                location,
                style: const TextStyle(
                  fontSize: AppConstants.fontSizeM,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        Text(
          time,
          style: const TextStyle(
            fontSize: AppConstants.fontSizeM,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildPassengersSection(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPassengersList(context),
      child: Container(
        margin: const EdgeInsets.fromLTRB(
          AppConstants.spacingXL,
          AppConstants.spacingL,
          AppConstants.spacingXL,
          0,
        ),
        padding: const EdgeInsets.all(AppConstants.spacingL),
        decoration: BoxDecoration(
          color: AppColors.textWhite,
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
          border: Border.all(color: AppColors.grey200),
        ),
        child: Row(
          children: [
            _buildPassengerAvatars(),
            const SizedBox(width: AppConstants.spacingM),
            Text(
              '${trip.passengers.length.toString().padLeft(2, '0')} ${AppConstants.labelPassengers.toLowerCase()}',
              style: const TextStyle(
                fontSize: AppConstants.fontSizeL,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_ios,
              size: AppConstants.iconSizeS,
              color: AppColors.grey600,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPassengerAvatars() {
    final displayPassengers = trip.passengers.take(3).toList();
    return SizedBox(
      width: 80,
      height: AppConstants.avatarSizeM,
      child: Stack(
        children: List.generate(displayPassengers.length, (index) {
          final passenger = displayPassengers[index];
          return Positioned(
            left: index * 24.0,
            child: Container(
              width: AppConstants.avatarSizeM,
              height: AppConstants.avatarSizeM,
              decoration: BoxDecoration(
                color: _getAvatarColor(passenger.name),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.textWhite, width: 2),
              ),
              child: Center(
                child: Text(
                  _getInitials(passenger.name),
                  style: const TextStyle(
                    color: AppColors.textWhite,
                    fontSize: AppConstants.fontSizeS,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSchoolsSection(BuildContext context) {
    return GestureDetector(
      onTap: () => _showSchoolsList(context),
      child: Container(
        margin: const EdgeInsets.fromLTRB(
          AppConstants.spacingXL,
          AppConstants.spacingL,
          AppConstants.spacingXL,
          AppConstants.spacingL,
        ),
        padding: const EdgeInsets.all(AppConstants.spacingL),
        decoration: BoxDecoration(
          color: AppColors.textWhite,
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
          border: Border.all(color: AppColors.grey200),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppConstants.spacingS),
              decoration: BoxDecoration(
                color: AppColors.successBackground,
                borderRadius: BorderRadius.circular(AppConstants.radiusS),
              ),
              child: const Icon(
                Icons.school,
                color: AppColors.success,
                size: AppConstants.iconSizeL,
              ),
            ),
            const SizedBox(width: AppConstants.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    AppConstants.labelSchools,
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeL,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                  '${trip.schools.length} ${trip.schools.length > 1 ? "écoles" : "école"}',
                   style:  const TextStyle(
                  fontSize: AppConstants.fontSizeM,
                  color: AppColors.textSecondary,
                  ),
),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: AppConstants.iconSizeS,
              color: AppColors.grey600,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppConstants.spacingXL,
        0,
        AppConstants.spacingXL,
        AppConstants.spacingL,
      ),
      padding: const EdgeInsets.all(AppConstants.spacingL),
      decoration: BoxDecoration(
        color: AppColors.textWhite,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '4.0',
                style: TextStyle(
                  fontSize: AppConstants.fontSizeHuge,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: AppConstants.spacingL),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRatingBar(5, 0.7),
                    _buildRatingBar(4, 0.5),
                    _buildRatingBar(3, 0.3),
                    _buildRatingBar(2, 0.1),
                    _buildRatingBar(1, 0.05),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingS),
          const Row(
            children: [
              Icon(
                Icons.star,
                color: AppColors.rating,
                size: AppConstants.iconSizeM,
              ),
              Icon(
                Icons.star,
                color: AppColors.rating,
                size: AppConstants.iconSizeM,
              ),
              Icon(
                Icons.star,
                color: AppColors.rating,
                size: AppConstants.iconSizeM,
              ),
              Icon(
                Icons.star,
                color: AppColors.rating,
                size: AppConstants.iconSizeM,
              ),
              Icon(
                Icons.star_border,
                color: AppColors.rating,
                size: AppConstants.iconSizeM,
              ),
              SizedBox(width: AppConstants.spacingS),
              Text(
                '52 avis',
                style: TextStyle(
                  fontSize: AppConstants.fontSizeS,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBar(int stars, double percentage) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            '$stars',
            style: const TextStyle(
              fontSize: AppConstants.fontSizeS,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: AppConstants.spacingS),
          const Icon(
            Icons.star,
            size: AppConstants.fontSizeS,
            color: AppColors.rating,
          ),
          const SizedBox(width: AppConstants.spacingS),
          Expanded(
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: AppColors.grey200,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.success,
              ),
              minHeight: 4,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingXL),
      decoration: BoxDecoration(
        color: AppColors.textWhite,
        boxShadow: [
          BoxShadow(
            color: AppColors.blackOpacity05,
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          if (trip.status == AppConstants.statusPending) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: () => _showCancelDialog(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppConstants.spacingL,
                  ),
                  side: const BorderSide(color: AppColors.error),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusXXL),
                  ),
                ),
                child: const Text(
                  AppConstants.labelReject,
                  style: TextStyle(
                    color: AppColors.error,
                    fontSize: AppConstants.fontSizeL,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppConstants.spacingM),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _acceptTrip(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary
,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppConstants.spacingL,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusXXL),
                  ),
                ),
                child: const Text(
                  AppConstants.labelAccept,
                  style: TextStyle(
                    color: AppColors.textWhite,
                    fontSize: AppConstants.fontSizeL,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ] else if (trip.status == AppConstants.statusActive) ...[
            Expanded(
              child: ElevatedButton(
                onPressed: () => _startTrip(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary
,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppConstants.spacingL,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusXXL),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppConstants.labelStartTrip,
                      style: TextStyle(
                        color: AppColors.textWhite,
                        fontSize: AppConstants.fontSizeL,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: AppConstants.spacingS),
                    Icon(Icons.arrow_forward, color: AppColors.textWhite),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    final statusConfig = _getStatusConfig();

    return Container(
      padding: const EdgeInsets.symmetric(
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
          const SizedBox(width: AppConstants.spacingXS + 2),
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
        return {
          'bgColor': AppColors.statusActiveBg,
          'textColor': AppColors.statusActive,
          'label': 'Accepté',
        };
      case AppConstants.statusStarted:
        return {
          'bgColor': AppColors.statusStartedBg,
          'textColor': AppColors.statusStarted,
          'label': 'En cours',
        };
      case AppConstants.statusCompleted:
        return {
          'bgColor': AppColors.statusCompletedBg,
          'textColor': AppColors.statusCompleted,
          'label': 'Terminé',
        };
      default:
        return {
          'bgColor': AppColors.grey200,
          'textColor': AppColors.grey700,
          'label': trip.status,
        };
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('EEEE d MMMM', 'fr_FR').format(date);
  }

  Color _getAvatarColor(String name) {
    final colors = [
      AppColors.info,
      AppColors.success,
      AppColors.warning,
      AppColors.error,
      AppColors.primaryLight,  // ✅ CORRECT,
    ];
    return colors[name.hashCode % colors.length];
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 2).toUpperCase();
  }

  void _showPassengersList(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PassengersListModal(passengers: trip.passengers),
    );
  }

  void _showSchoolsList(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
     builder: (context) => SchoolsListModal(schools: trip.schools),
    );
  }

  void _acceptTrip(BuildContext context) {
    context.read<TripBloc>().add(StartTripEvent(trip.id));
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(AppConstants.successTripAccepted),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _startTrip(BuildContext context) {
    context.read<TripBloc>().add(StartTripEvent(trip.id));
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(AppConstants.successTripStarted),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(
          AppConstants.labelCancelTrip,
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          'Êtes-vous sûr de vouloir rejeter ce trajet ?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'Non',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              context.read<TripBloc>().add(
                CancelTripEvent(
                  tripId: trip.id,
                  reason: 'Rejeté par le chauffeur',
                ),
              );
              Navigator.pop(dialogContext);
              Navigator.pop(context);
            },
            child: const Text('Oui', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
