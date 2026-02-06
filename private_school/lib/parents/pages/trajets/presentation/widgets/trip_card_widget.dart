import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_constants.dart';
import '../../data/models/trip_model.dart';

/// Trip card widget
/// Displays trip information including route and status
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
            // Header avec status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 🔥 CORRECTION : Afficher la date formatée
                Text(
                  _formatDate(trip.date),
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: AppConstants.fontSizeL - 1,
                    color: AppColors.textPrimary,
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
                              trip.startLocation ?? 'Point de départ',
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
                            trip.time,
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
                          Expanded(
                            child: Text(
                              trip.destination,
                              style: GoogleFonts.inter(
                                fontSize: AppConstants.fontSizeS + 1,
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // 🔥 Calcul approximatif de l'heure d'arrivée (+1h30)
                          Text(
                            _calculateArrivalTime(trip.time),
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
                Row(
                  children: [
                    Icon(
                      Icons.school,
                      size: 16,
                      color: AppColors.success,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      trip.schools.isNotEmpty 
                          ? '${trip.schools.length} école${trip.schools.length > 1 ? 's' : ''}'
                          : 'Aucune école',
                      style: GoogleFonts.inter(
                        color: AppColors.success,
                        fontSize: AppConstants.fontSizeS,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      Icons.people,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${trip.passengers.length}/${trip.totalSeats} places',
                      style: GoogleFonts.inter(
                        fontSize: AppConstants.fontSizeS,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Format la date
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return "Aujourd'hui";
    } else if (dateOnly == tomorrow) {
      return "Demain";
    } else {
      return DateFormat('EEEE d MMMM', 'fr_FR').format(date);
    }
  }

  /// Calcule l'heure d'arrivée approximative
  String _calculateArrivalTime(String departureTime) {
    try {
      final parts = departureTime.split(':');
      if (parts.length >= 2) {
        int hours = int.parse(parts[0]);
        int minutes = int.parse(parts[1]);
        
        // Ajouter 1h30
        minutes += 30;
        if (minutes >= 60) {
          hours += 1;
          minutes -= 60;
        }
        hours += 1;
        
        if (hours >= 24) hours -= 24;
        
        return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
      }
    } catch (e) {
      // En cas d'erreur, retourner "--:--"
    }
    return '--:--';
  }

  Widget _buildStatusBadge(String status) {
    Color badgeColor;
    String badgeText;

    switch (status.toLowerCase()) {
      case 'active':
      case 'started':
      case 'in_progress':
        badgeColor = AppColors.success;
        badgeText = 'En cours';
        break;
      case 'completed':
        badgeColor = AppColors.primary;
        badgeText = 'Terminé';
        break;
      case 'canceled':
        badgeColor = AppColors.error;
        badgeText = 'Annulé';
        break;
      case 'pending':
      default:
        badgeColor = AppColors.warning;
        badgeText = 'En attente';
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