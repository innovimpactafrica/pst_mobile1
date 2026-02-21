import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart' as easy;
import 'package:private_school/core/utils/app_colors.dart';
import 'package:private_school/core/utils/app_constants.dart';
import '../../data/models/trip_model.dart';


class TripCardWidget extends StatelessWidget {
  final TripModel trip;
  final VoidCallback onTap;

  const TripCardWidget({
    super.key,
    required this.trip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppConstants.spacingL),
        padding: const EdgeInsets.all(AppConstants.spacingL),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
          boxShadow: [
            BoxShadow(
              color: AppColors.blackOpacity05,
              blurRadius: AppConstants.spacingS,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: AppConstants.spacingL),
            _buildRoute(),
            const SizedBox(height: AppConstants.spacingL),
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
          padding: const EdgeInsets.all(AppConstants.spacingS + 2),
          decoration: BoxDecoration(
            color: AppColors.successBackground,
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
          ),
          child: const Icon(
            Icons.calendar_today_outlined,
            size: AppConstants.iconSizeM,
            color: AppColors.success,
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
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
             
              Text(
                '${trip.totalSeats} ${'available_seats_vehicle'.tr()} ',
                style: const TextStyle(
                  fontSize: AppConstants.fontSizeS,
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
    final isReturnTrip = ((trip.status == 'completed' || trip.status == 'partially_completed') && trip.returnStatus == 'pending') || trip.returnStatus == 'in_progress';
    final start = isReturnTrip ? trip.destination : (trip.startLocation ?? 'departure_point'.tr());
    final end = isReturnTrip ? (trip.startLocation ?? 'departure_point'.tr()) : trip.destination;
    final displayTime = isReturnTrip && trip.returnTime != null ? trip.returnTime! : trip.time;
    
    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.radio_button_checked, color: AppColors.primary, size: AppConstants.iconSizeM),
            const SizedBox(width: AppConstants.spacingM),
            Expanded(
              child: Text(
                start,
                style: const TextStyle(
                  fontSize: AppConstants.fontSizeM,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              displayTime,
              style: const TextStyle(
                fontSize: AppConstants.fontSizeM,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        
        Container(
          margin: const EdgeInsets.only(left: AppConstants.spacingS + 2),
          height: AppConstants.spacingXXL,
          child: CustomPaint(
            painter: DottedLinePainter(color: AppColors.grey300),
          ),
        ),
        
        Row(
          children: [
            const Icon(Icons.location_on, color: AppColors.error, size: AppConstants.iconSizeM),
            const SizedBox(width: AppConstants.spacingM),
            Expanded(
              child: Text(
                end,
                style: const TextStyle(
                  fontSize: AppConstants.fontSizeM,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }


  Widget _buildFooter() {
    final schoolCount = trip.schools.length;
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingL,
        vertical: AppConstants.spacingXS + 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.successBackground,
        borderRadius: BorderRadius.circular(AppConstants.radiusXL),
      ),
      child: Text(
        '$schoolCount ${schoolCount > 1 ? 'schools_served'.tr() : 'school_served'.tr()}',
        style: const TextStyle(
          fontSize: AppConstants.fontSizeS,
          color: AppColors.success,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    final statusConfig = _getStatusConfig();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingL,
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
            width: AppConstants.spacingXS + 2,
            height: AppConstants.spacingXS + 2,
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
    // Si l'aller est terminé et le retour est en attente
    if ((trip.status == 'completed' || trip.status == 'partially_completed') && trip.returnStatus == 'pending') {
      return {
        'bgColor': const Color(0xFFFEF3C7),
        'textColor': const Color(0xFFF59E0B),
        'label': 'partially_completed'.tr(),
      };
    }
    
    // Si le retour est en cours
    if (trip.returnStatus == 'in_progress') {
      return {
        'bgColor': const Color(0xFFDCFCE7),
        'textColor': const Color(0xFF16A34A),
        'label': 'in_progress_return'.tr(),
      };
    }
    
    switch (trip.status) {
      case AppConstants.statusPending:
        return {
          'bgColor': AppColors.statusPendingBg,
          'textColor': AppColors.statusPending,
          'label': 'pending'.tr(),
        };
      case AppConstants.statusActive:
        return {
          'bgColor': AppColors.statusActiveBg,
          'textColor': AppColors.statusActive,
          'label': 'accepted'.tr(),
        };
      case AppConstants.statusStarted:
        return {
          'bgColor': AppColors.statusStartedBg,
          'textColor': AppColors.statusStarted,
          'label': 'completed'.tr(),
        };
      case AppConstants.statusInProgress: 
        return {
          'bgColor': AppColors.statusInProgressBg,
          'textColor': AppColors.statusInProgress,
          'label': 'in_progress'.tr(),
        };
      case AppConstants.statusCompleted:
        return {
          'bgColor': AppColors.statusCompletedBg,
          'textColor': AppColors.statusCompleted,
          'label': 'completed'.tr(),
        };
      case AppConstants.statusCanceled:
        return {
          'bgColor': AppColors.statusCanceledBg,
          'textColor': AppColors.statusCanceled,
          'label': 'cancelled'.tr(),
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
}

/// Custom painter for dotted line between departure and destination
class DottedLinePainter extends CustomPainter {
  final Color color;

  DottedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    const dashHeight = AppConstants.spacingXS;
    const dashSpace = AppConstants.spacingXS;
    double startY = 0;

    while (startY < size.height) {
      canvas.drawLine(
        Offset(0, startY),
        Offset(0, startY + dashHeight),
        paint,
      );
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}