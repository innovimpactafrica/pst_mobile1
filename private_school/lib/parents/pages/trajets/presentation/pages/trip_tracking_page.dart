import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:private_school/chauffeurs/pages/trajets/presentation/widgets/trip_map_widget.dart';
import '../../data/models/trip_model.dart';
import '../widgets/review_page.dart';
import '../widgets/passengers_list_modal.dart';
import '../widgets/schools_list_modal.dart';
import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_constants.dart';

class TripTrackingPage extends StatefulWidget {
  final TripModel trip;

  const TripTrackingPage({super.key, required this.trip});

  @override
  State<TripTrackingPage> createState() => _TripTrackingPageState();
}

class _TripTrackingPageState extends State<TripTrackingPage> {
  int? _durationMinutes;

  @override
  void initState() {
    super.initState();
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('📋 [TripTrackingPage] INFOS DU TRAJET');
    debugPrint('   Trip ID: ${widget.trip.id}');
    debugPrint('   Status: ${widget.trip.status}');
    debugPrint('   Driver: ${widget.trip.driverName}');
    debugPrint('   Driver Photo: ${widget.trip.driver?.photo}');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
  }

  void _onRouteCalculated(double distance, int duration) {
    setState(() => _durationMinutes = duration);
    debugPrint('✅ [TripTrackingPage] Distance: ${distance.toStringAsFixed(1)} km, Durée: $duration min');
  }

  String _calculateArrivalTime() {
    if (_durationMinutes == null) return widget.trip.arrivalTime;
    try {
      final parts = widget.trip.departureTime.split(':');
      if (parts.length == 2) {
        final hours = int.parse(parts[0]);
        final minutes = int.parse(parts[1]);
        final totalMinutes = hours * 60 + minutes + _durationMinutes!;
        final arrivalHour = (totalMinutes ~/ 60) % 24;
        final arrivalMinute = totalMinutes % 60;
        return '${arrivalHour.toString().padLeft(2, '0')}:${arrivalMinute.toString().padLeft(2, '0')}';
      }
    } catch (e) {
      debugPrint('Error calculating arrival time: $e');
    }
    return widget.trip.arrivalTime;
  }

  String _formatDuration() {
    if (_durationMinutes == null) return widget.trip.duration;
    final hours = _durationMinutes! ~/ 60;
    final minutes = _durationMinutes! % 60;
    if (hours > 0) return '${hours}h${minutes.toString().padLeft(2, '0')}min';
    return '${minutes}min';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ══════════════════════════════════════════
            // HEADER — design inchangé
            // ══════════════════════════════════════════
            Container(
              color: AppColors.success,
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacingM,
                vertical: AppConstants.spacingS,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: AppColors.white,
                      size: AppConstants.iconSizeM,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      'Dakar → ${widget.trip.destination}',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: AppConstants.fontSizeM,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // ══════════════════════════════════════════
            // CONTENT
            // ══════════════════════════════════════════
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // GOOGLE MAPS — inchangé
                    SizedBox(
                      height: AppConstants.mapHeight,
                      width: double.infinity,
                      child: TripMapWidget(
                        startLocation: widget.trip.departure,
                        destination: widget.trip.arrival,
                        onRouteCalculated: _onRouteCalculated,
                      ),
                    ),

                    // WHITE CONTENT
                    Container(
                      color: AppColors.white,
                      padding: const EdgeInsets.all(AppConstants.spacingXL),
                      child: Column(
                        children: [
                          // ✅ DRIVER CARD avec vraies infos
                          if (widget.trip.driverName.isNotEmpty)
                            _driverCard(),

                          const SizedBox(height: AppConstants.spacingM),

                          // CALL / MESSAGE — inchangé
                          _actionButtons(),

                          const SizedBox(height: AppConstants.spacingXL),

                          // TRIP DETAILS — inchangé
                          _tripDetails(),

                          const SizedBox(height: AppConstants.spacingL),

                          _dateEstimation(),

                          const SizedBox(height: AppConstants.spacingXL),

                          _passengersTile(),

                          const SizedBox(height: AppConstants.spacingM),

                          _schoolsTile(),

                          const SizedBox(height: AppConstants.spacingXXL),

                          _reviewsSection(),

                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // BOTTOM BUTTON — inchangé
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(AppConstants.spacingXL),
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.blackOpacity05,
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ReviewPage(trip: widget.trip),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingM),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusL),
              ),
              elevation: 0,
            ),
            child: Text(
              'Donner un avis',
              style: GoogleFonts.inter(
                fontSize: AppConstants.fontSizeL,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════
  // ✅ DRIVER CARD — enrichie avec vraies infos
  //    photo (NetworkImage si URL, sinon initiales)
  //    nom complet, téléphone, email, statut actif
  //    Toutes les erreurs null-safety corrigées
  // ══════════════════════════════════════════
  Widget _driverCard() {
    // driver est DriverModel? — on accède toujours via ?.
    final driver = widget.trip.driver;

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusXL),
        boxShadow: [
          BoxShadow(
            color: AppColors.blackOpacity05,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // ✅ PHOTO — NetworkImage si URL disponible, sinon avatar avec initiales
          _buildDriverAvatar(driver),

          const SizedBox(width: AppConstants.spacingM),

          // ✅ INFOS CHAUFFEUR
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // NOM
                Text(
                  widget.trip.driverName,
                  style: GoogleFonts.inter(
                    fontSize: AppConstants.fontSizeM,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 2),

                // TÉLÉPHONE si disponible
                if (driver?.phone != null)
                  Row(
                    children: [
                      Icon(Icons.phone, size: 13, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        driver?.phone ?? '',
                        style: GoogleFonts.inter(
                          fontSize: AppConstants.fontSizeS,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),

                // EMAIL si disponible
                if (driver?.email != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Row(
                      children: [
                        Icon(Icons.email, size: 13, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            driver?.email ?? '',
                            style: GoogleFonts.inter(
                              fontSize: AppConstants.fontSizeS,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                // STATUT si driver présent
                if (driver != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        // ✅ driver.isActive — smart cast, pas de !
                        color: driver.isActive
                            ? AppColors.success.withValues(alpha: 0.1)
                            : AppColors.grey200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        driver.isActive ? 'Actif' : 'Inactif',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: driver.isActive
                              ? AppColors.success
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const Icon(Icons.chevron_right, color: AppColors.textGrey),
        ],
      ),
    );
  }

  /// ✅ Avatar du chauffeur :
  /// - photo de l'API si disponible (NetworkImage)
  /// - sinon avatar coloré avec initiales
  Widget _buildDriverAvatar(driver) {
    final photoUrl = driver?.photo as String?;
    final hasPhoto = photoUrl != null && photoUrl.isNotEmpty;
    final name = widget.trip.driverName;

    // Calcul des initiales
    final parts = name.trim().split(' ');
    final initials = parts.length >= 2
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : name.isNotEmpty
            ? name[0].toUpperCase()
            : '?';

    return CircleAvatar(
      radius: AppConstants.avatarSizeM,
      backgroundColor: AppColors.success.withValues(alpha: 0.15),
      backgroundImage: hasPhoto ? NetworkImage(photoUrl) : null,
      onBackgroundImageError: hasPhoto
          ? (_, __) => debugPrint('⚠️ Erreur chargement photo chauffeur')
          : null,
      child: !hasPhoto
          ? Text(
              initials,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.success,
              ),
            )
          : null,
    );
  }

  // ══════════════════════════════════════════
  // ACTION BUTTONS — design inchangé
  // ══════════════════════════════════════════
  Widget _actionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.phone),
            label: const Text('Appeler'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingM),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusL),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppConstants.spacingM),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: Icon(Icons.chat, color: AppColors.success),
            label: Text('Message', style: TextStyle(color: AppColors.success)),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.success),
              padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingM),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusL),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════
  // TRIP DETAILS — design inchangé
  // ══════════════════════════════════════════
  Widget _tripDetails() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _tripPoint(
            'Point de départ',
            widget.trip.departure,
            widget.trip.departureTime,
            AppColors.success,
            Icons.circle_outlined,
          ),
          const SizedBox(height: AppConstants.spacingS),
          _tripPoint(
            'Destination',
            widget.trip.arrival,
            _calculateArrivalTime(),
            AppColors.error,
            Icons.location_on,
          ),
        ],
      ),
    );
  }

  Widget _tripPoint(String title, String location, String time, Color color, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: color, size: AppConstants.iconSizeM),
        const SizedBox(width: AppConstants.spacingM),
        Expanded(child: Text(location)),
        Text(
          time,
          style: TextStyle(color: AppColors.info, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _dateEstimation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(widget.trip.formattedDate, style: TextStyle(color: AppColors.success)),
        Text('Estimation ${_formatDuration()}', style: TextStyle(color: AppColors.textSecondary)),
      ],
    );
  }

  // ══════════════════════════════════════════
  // TILES — design inchangé
  // ══════════════════════════════════════════
  Widget _passengersTile() => GestureDetector(
        onTap: _showPassengersList,
        child: _simpleTile('${widget.trip.passengers.length} passagers'),
      );

  Widget _schoolsTile() => GestureDetector(
        onTap: _showSchoolsList,
        child: _simpleTile('Écoles desservies'),
      );

  Widget _simpleTile(String text) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
      ),
      child: Row(
        children: [
          Expanded(child: Text(text)),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }

  Widget _reviewsSection() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        'Avis',
        style: GoogleFonts.inter(
          fontSize: AppConstants.fontSizeL,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showPassengersList() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => PassengersListModal(passengers: widget.trip.passengers),
    );
  }

  void _showSchoolsList() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => SchoolsListModal(schools: widget.trip.schools),
    );
  }
}