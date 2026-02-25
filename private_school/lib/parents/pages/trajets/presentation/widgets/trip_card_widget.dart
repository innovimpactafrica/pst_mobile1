import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_constants.dart';
import '../../data/models/trip_model.dart';
import '../../data/repositories/evaluation_repository.dart';

class TripCardWidget extends StatefulWidget {
  final TripModel trip;
  final VoidCallback? onTap;
  final bool isReserved;

  const TripCardWidget({
    super.key,
    required this.trip,
    this.onTap,
    this.isReserved = false,
  });

  @override
  State<TripCardWidget> createState() => _TripCardWidgetState();
}

class _TripCardWidgetState extends State<TripCardWidget> {
  double? _realRating;
  bool _isLoadingRating = true;

  @override
  void initState() {
    super.initState();
    _loadRealRating();
  }

  Future<void> _loadRealRating() async {
    if (widget.trip.driverId == null) {
      setState(() => _isLoadingRating = false);
      return;
    }

    try {
      final driverId = int.tryParse(widget.trip.driverId!);
      if (driverId == null) {
        setState(() => _isLoadingRating = false);
        return;
      }

      final evaluations = await EvaluationRepository().getDriverEvaluations(
        driverId: driverId,
        limit: 100,
      );

      if (evaluations.isNotEmpty) {
        final avg =
            evaluations.map((e) => e.rating).reduce((a, b) => a + b) /
            evaluations.length;
        if (mounted) {
          setState(() {
            _realRating = avg;
            _isLoadingRating = false;
          });
        }
      } else {
        if (mounted) {
          setState(() => _isLoadingRating = false);
        }
      }
    } catch (e) {
      debugPrint(' Erreur chargement rating: $e');
      if (mounted) {
        setState(() => _isLoadingRating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
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
            //  Photo chauffeur + véhicule + infos + badge statut
            _buildDriverHeader(),

            const SizedBox(height: AppConstants.spacingXL),

            // Route section
            _buildRouteSection(),

            const SizedBox(height: AppConstants.spacingL),

            // Info section
            _buildInfoSection(),
          ],
        ),
      ),
    );
  }

  ///  Photo chauffeur + véhicule (superposées) + infos
  Widget _buildDriverHeader() {
    final displayRating = _realRating ?? widget.trip.driverRatingValue;

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingXL),
      child: Row(
        children: [
          //  Photo chauffeur + véhicule superposées
          Stack(
            clipBehavior: Clip.none,
            children: [
              // Photo chauffeur (grand cercle)
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.grey200,
                backgroundImage: widget.trip.hasDriverPhoto
                    ? NetworkImage(widget.trip.driverPhotoUrl)
                    : null,
                onBackgroundImageError: widget.trip.hasDriverPhoto
                    ? (exception, stackTrace) {
                        debugPrint('! Erreur chargement photo chauffeur');
                      }
                    : null,
                child: !widget.trip.hasDriverPhoto
                    ? const Icon(
                        Icons.person,
                        color: AppColors.grey600,
                        size: 24,
                      )
                    : null,
              ),

              // Photo véhicule (petit cercle en bas à droite)
              if (widget.trip.hasVehiclePhoto)
                Positioned(
                  right: -4,
                  bottom: -4,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.white, width: 2),
                    ),
                    child: ClipOval(
                      child: Image.network(
                        widget.trip.vehiclePhotoUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          debugPrint('! Erreur chargement photo véhicule');
                          return Container(
                            color: AppColors.primary,
                            child: const Icon(
                              Icons.directions_car,
                              color: AppColors.white,
                              size: 12,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(width: AppConstants.spacingL),

          // Infos chauffeur
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nom du chauffeur
                Text(
                  widget.trip.driverNameDisplay,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: AppConstants.fontSizeL - 1,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 4),

                // Plaque + Rating
                Row(
                  children: [
                    // Plaque
                    if (widget.trip.vehiclePlate != null &&
                        widget.trip.vehiclePlate!.isNotEmpty)
                      Flexible(
                        child: Text(
                          widget.trip.vehiclePlate!,
                          style: GoogleFonts.inter(
                            fontSize: AppConstants.fontSizeS,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),

                    // Séparateur
                    if (widget.trip.vehiclePlate != null &&
                        widget.trip.vehiclePlate!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Container(
                          width: 3,
                          height: 3,
                          decoration: const BoxDecoration(
                            color: AppColors.textSecondary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),

                    // Rating (toujours visible avec vraie évaluation)
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          size: 14,
                          color: AppColors.warning,
                        ),
                        const SizedBox(width: 4),
                        _isLoadingRating
                            ? SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.textSecondary,
                                ),
                              )
                            : Text(
                                displayRating > 0
                                    ? displayRating.toStringAsFixed(1)
                                    : 'N/A',
                                style: GoogleFonts.inter(
                                  fontSize: AppConstants.fontSizeS,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          //  BADGE STATUT (pending/active/completed) - PAS "Réservé"
          _buildStatusBadge(widget.trip.status),
        ],
      ),
    );
  }

  ///  SECTION ROUTE
  Widget _buildRouteSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icônes
        Column(
          children: [
            const Icon(
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
            const Icon(Icons.location_on, color: AppColors.success, size: 18),
          ],
        ),

        const SizedBox(width: AppConstants.spacingL),

        // Textes
        Expanded(
          child: Column(
            children: [
              // Départ
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.trip.startLocation ?? 'departure_point'.tr(),
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
                    widget.trip.time,
                    style: GoogleFonts.inter(
                      fontSize: AppConstants.fontSizeS + 1,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Arrivée
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.trip.destination,
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
                    _calculateArrivalTime(widget.trip.time),
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
    );
  }

  /// SECTION INFO (écoles + "X enfants inscrits / Y places")
  Widget _buildInfoSection() {
    final registeredCount = widget.trip.passengers.length;
    final totalPlaces = widget.trip.totalSeats;
    final schoolCount = widget.trip.schoolCount ?? 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Écoles
        Flexible(
          child: Row(
            children: [
              const Icon(Icons.school, size: 16, color: AppColors.success),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  schoolCount > 0
                      ? '$schoolCount ${schoolCount > 1 ? 'schools_served'.tr() : 'school_served'.tr()}'
                      : 'no_school'.tr(),
                  style: GoogleFonts.inter(
                    color: AppColors.success,
                    fontSize: AppConstants.fontSizeS,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 8),

        //  "X enfants inscrits / Y places"
        Row(
          children: [
            const Icon(Icons.people, size: 16, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(
              '$registeredCount/$totalPlaces',
              style: GoogleFonts.inter(
                fontSize: AppConstants.fontSizeS,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  ///  BADGE STATUT DE LA BASE (pending/active/in_progress/completed/canceled)
  Widget _buildStatusBadge(String status) {
    Color badgeColor;
    String badgeText;

    switch (status.toLowerCase()) {
      case 'active':
      case 'started':
      case 'in_progress':
        badgeColor = AppColors.success;
        badgeText = 'in_progress'.tr();
        break;
      case 'completed':
        badgeColor = AppColors.primary;
        badgeText = 'completed'.tr();
        break;
      case 'canceled':
        badgeColor = AppColors.error;
        badgeText = 'cancelled'.tr();
        break;
      case 'pending':
      default:
        badgeColor = AppColors.warning;
        badgeText = 'pending'.tr();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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

  /// Calcule l'heure d'arrivée (+1h30)
  String _calculateArrivalTime(String departureTime) {
    try {
      final parts = departureTime.split(':');
      if (parts.length >= 2) {
        int hours = int.parse(parts[0]);
        int minutes = int.parse(parts[1]);

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
      // Ignore
    }
    return '--:--';
  }
}

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
