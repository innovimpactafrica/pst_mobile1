import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_constants.dart';
import '../../data/models/trip_model.dart';

/// Trip card widget
/// Displays trip information including driver, route, and status
class TripCardWidget extends StatelessWidget {
  final TripModel trip;
  final VoidCallback? onTap;

  const TripCardWidget({super.key, required this.trip, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppConstants.spacingXL),
        padding: const EdgeInsets.all(AppConstants.spacingXL),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusXL - 8),
          boxShadow: [
            BoxShadow(
              color: AppColors.blackOpacity10,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Driver section + status
            Row(
              children: [
                // Overlapping photos
                SizedBox(
                  width: 60,
                  height: 40,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.grey200,
                        backgroundImage: trip.driver?.photo != null
                            ? AssetImage('assets/images/${trip.driver!.photo}')
                            : null,
                        onBackgroundImageError: (_, __) {},
                        child: trip.driver?.photo == null
                            ? Icon(
                                Icons.person,
                                color: AppColors.grey600,
                                size: 20,
                              )
                            : null,
                      ),
                      Positioned(
                        left: 28,
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: AppColors.white,
                          child: CircleAvatar(
                            radius: 14,
                            backgroundColor: AppColors.grey300,
                            backgroundImage: trip.driver?.vehicle?.photo != null
                                ? AssetImage(
                                    'assets/images/${trip.driver!.vehicle!.photo}',
                                  )
                                : null,
                            onBackgroundImageError: (_, __) {},
                            child: trip.driver?.vehicle?.photo == null
                                ? Icon(
                                    Icons.directions_bus,
                                    color: AppColors.grey600,
                                    size: 14,
                                  )
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppConstants.spacingL),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trip.driver?.name ?? 'Chauffeur',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: AppConstants.fontSizeL - 1,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            trip.driver?.vehicle?.plate ?? 'N/A',
                            style: GoogleFonts.inter(
                              fontSize: AppConstants.fontSizeS,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: AppConstants.spacingS),
                          const Icon(
                            Icons.star,
                            color: AppColors.rating,
                            size: 13,
                          ),
                          const SizedBox(width: 2),
                         Text(
                         '${trip.passengers.length} enfants inscrits / ${(trip.driver?.vehicle?.capacity) ?? 0}',
                         style: GoogleFonts.inter(
                         fontSize: AppConstants.fontSizeS,
                         color: AppColors.textSecondary,
                         ),
                       ),
                        ],
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(trip.status),
              ],
            ),
            const SizedBox(height: AppConstants.spacingXL),

            // Route section
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Icon(
                      Icons.circle_outlined,
                      color: AppColors.textGrey,
                      size: 16,
                    ),
                    Container(
                      width: 2,
                      height: 30,
                      margin: const EdgeInsets.symmetric(
                        vertical: AppConstants.spacingXS,
                      ),
                      child: CustomPaint(painter: DashedLinePainter()),
                    ),
                    const Icon(
                      Icons.location_on,
                      color: AppColors.success,
                      size: 18,
                    ),
                  ],
                ),
                const SizedBox(width: AppConstants.spacingL),
                Expanded(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              trip.departure,
                              style: GoogleFonts.inter(
                                fontSize: AppConstants.fontSizeS + 1,
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            trip.departureTime,
                            style: GoogleFonts.inter(
                              fontSize: AppConstants.fontSizeS + 1,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            trip.arrival,
                            style: GoogleFonts.inter(
                              fontSize: AppConstants.fontSizeS + 1,
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            trip.arrivalTime,
                            style: GoogleFonts.inter(
                              fontSize: AppConstants.fontSizeS + 1,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingL),

            // Info section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${trip.schools.length} écoles desservies',
                  style: GoogleFonts.inter(
                    color: AppColors.success,
                    fontSize: AppConstants.fontSizeS,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${trip.passengers.length} enfants inscrits / ${trip.driver?.vehicle?.capacity ?? 0}',
                  style: GoogleFonts.inter(
                    fontSize: AppConstants.fontSizeS,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color badgeColor;
    String badgeText;

    switch (status) {
      case 'Accepté':
        badgeColor = AppColors.primary;
        badgeText = 'Accepté';
        break;
      case 'En attente':
        badgeColor = AppColors.warning;
        badgeText = 'En attente';
        break;
      default:
        badgeColor = AppColors.textGrey;
        badgeText = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusXL - 8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: badgeColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppConstants.spacingXS),
          Text(
            badgeText,
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeXS + 1,
              fontWeight: FontWeight.w600,
              color: badgeColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for dashed line
class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.grey400
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const dashHeight = 3;
    const dashSpace = 3;
    double startY = 0;

    while (startY < size.height) {
      canvas.drawLine(
        Offset(size.width / 2, startY),
        Offset(size.width / 2, startY + dashHeight),
        paint,
      );
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}