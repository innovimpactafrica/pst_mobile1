import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:private_school/chauffeurs/pages/authentification/data/models/driver_model.dart';
import 'package:private_school/parents/pages/acceuil/data/models/conversation_model.dart';
import 'package:private_school/parents/pages/acceuil/domain/bloc/conversation_bloc.dart';
import 'package:private_school/parents/pages/acceuil/domain/bloc/conversation_event.dart';
import 'package:private_school/parents/pages/acceuil/domain/bloc/conversation_state.dart';
import 'package:private_school/parents/pages/acceuil/presentation/pages/chat.dart';
import 'package:private_school/parents/pages/trajets/data/models/evaluation_model.dart';
import 'package:private_school/parents/pages/trajets/data/repositories/evaluation_repository.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:private_school/shared/widgets/realtime_trip_map_widget.dart';
import '../../data/models/trip_model.dart';
import '../widgets/review_page.dart';
import '../widgets/passengers_list_modal.dart';
import '../widgets/schools_list_modal.dart';
import '../widgets/driver_details_modal.dart';
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
  List<EvaluationModel> _evaluations = [];
  bool _isLoadingEvaluations = false;
  double _avgRating = 0.0;
  final _evaluationRepository = EvaluationRepository();

  @override
  void initState() {
    super.initState();
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint(' [TripTrackingPage] INFOS DU TRAJET');
    debugPrint('   Trip ID: ${widget.trip.id}');
    debugPrint('   Status: ${widget.trip.status}');
    debugPrint('   Driver Name: ${widget.trip.driverName}');
    debugPrint('   Driver Photo: ${widget.trip.driver?.photo}');
    debugPrint('');
    debugPrint(' [ÉCOLES] INFOS:');
    debugPrint('   Nombre d\'écoles: ${widget.trip.schools.length}');
    debugPrint('   School Count: ${widget.trip.schoolCount}');
    for (var school in widget.trip.schools) {
      debugPrint('   - ${school.name} (ID: ${school.id})');
    }
    debugPrint('');
    debugPrint(' [PASSAGERS] INFOS:');
    debugPrint('   Nombre de passagers: ${widget.trip.passengers.length}');
    for (var passenger in widget.trip.passengers) {
      debugPrint(
        '   - ${passenger.name} (École: ${passenger.school ?? "non spécifiée"})',
      );
    }
    debugPrint('');
    debugPrint(' DRIVER COMPLET:');
    debugPrint('   Driver existe? ${widget.trip.driver != null}');
    debugPrint('   Driver ID: ${widget.trip.driver?.id}');
    debugPrint('   Driver User ID: ${widget.trip.driver?.userId}');
    debugPrint('   Driver FullName: ${widget.trip.driver?.fullName}');
    debugPrint('   Driver Phone: ${widget.trip.driver?.phone}');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
    _loadEvaluations();
  }

  Future<void> _loadEvaluations() async {
    if (widget.trip.driverId == null) return;

    setState(() {
      _isLoadingEvaluations = true;
    });

    try {
      debugPrint(' [TripTrackingPage] Chargement des évaluations...');

      final evaluations = await _evaluationRepository.getDriverEvaluations(
        driverId: int.parse(widget.trip.driverId!),
        limit: 10,
      );

      debugPrint(' ${evaluations.length} évaluation(s) chargée(s)');

      if (mounted) {
        setState(() {
          _evaluations = evaluations;

          if (evaluations.isNotEmpty) {
            _avgRating =
                evaluations.map((e) => e.rating).reduce((a, b) => a + b) /
                evaluations.length;
          }
          _isLoadingEvaluations = false;
        });
      }
    } catch (e) {
      debugPrint(' Erreur chargement évaluations: $e');
      if (mounted) {
        setState(() {
          _isLoadingEvaluations = false;
        });
      }
    }
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
      body: Column(
        children: [
          Container(
            color: AppColors.success,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top,
              left: AppConstants.spacingM,
              right: AppConstants.spacingM,
              bottom: AppConstants.spacingS,
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
                    '${widget.trip.departure} → ${widget.trip.destination}',
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

          Expanded(
            child: Column(
              children: [
                SizedBox(
                  height: AppConstants.mapHeight,
                  width: double.infinity,
                  child: RealtimeTripMapWidget(
                    tripId: widget.trip.id,
                    startLocation: widget.trip.departure,
                    destination: widget.trip.arrival,
                    stops: widget.trip.schools,
                    enableRealtime: widget.trip.isActive,
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: Container(
                      color: AppColors.white,
                      padding: const EdgeInsets.all(AppConstants.spacingXL),
                      child: Column(
                        children: [
                          if (widget.trip.driverName?.isNotEmpty ?? false)
                            _driverCard(),
                          const SizedBox(height: AppConstants.spacingM),
                          _actionButtons(),
                          const SizedBox(height: AppConstants.spacingXL),
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
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

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
            onPressed: () async {
              final result = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) => ReviewPage(trip: widget.trip),
                ),
              );

              if (result == true) {
                _loadEvaluations();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(
                vertical: AppConstants.spacingM,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusL),
              ),
              elevation: 0,
            ),
            child: Text(
              'rate_your_experience'.tr(),
              style: GoogleFonts.inter(
                fontSize: AppConstants.fontSizeL,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _driverCard() {
    final driver = widget.trip.driver;

    return GestureDetector(
      onTap: () {
        if (driver != null) {
          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            isScrollControlled: true,
            builder: (context) => DriverDetailsModal(
              driver: driver,
              vehiclePhotoUrl: widget.trip.vehiclePhotoUrl,
            ),
          );
        }
      },
      child: Container(
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
            _buildDriverAvatar(driver),

            const SizedBox(width: AppConstants.spacingM),

            //  INFOS CHAUFFEUR
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // NOM
                  Text(
                    widget.trip.driverName ?? '',
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
                        Icon(
                          Icons.phone,
                          size: 13,
                          color: AppColors.textSecondary,
                        ),
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
                          Icon(
                            Icons.email,
                            size: 13,
                            color: AppColors.textSecondary,
                          ),
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

                  // RATING RÉEL
                  if (_evaluations.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          Icon(Icons.star, size: 14, color: AppColors.warning),
                          const SizedBox(width: 4),
                          Text(
                            _avgRating.toStringAsFixed(1),
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(${_evaluations.length} ${'reviews'.tr()})',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: AppColors.textSecondary,
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: driver.isActive
                              ? AppColors.success.withValues(alpha: 0.1)
                              : AppColors.grey200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          driver.isActive ? 'active'.tr() : 'inactive'.tr(),
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
      ),
    );
  }

  Widget _buildDriverAvatar(DriverModel? driver) {
    final photoUrl = driver?.photo;
    final hasPhoto = photoUrl != null && photoUrl.isNotEmpty;
    final name = widget.trip.driverName ?? '';

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
          ? (_, __) => debugPrint('Erreur chargement photo chauffeur')
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

  Widget _actionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _callDriver(context),
            icon: const Icon(Icons.phone),
            label: Text('call'.tr()),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              padding: const EdgeInsets.symmetric(
                vertical: AppConstants.spacingM,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusL),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppConstants.spacingM),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _openChatWithDriver,
            icon: Icon(Icons.chat, color: AppColors.success),
            label: Text(
              'message'.tr(),
              style: TextStyle(color: AppColors.success),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.success),
              padding: const EdgeInsets.symmetric(
                vertical: AppConstants.spacingM,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusL),
              ),
            ),
          ),
        ),
      ],
    );
  }

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
            'departure_point'.tr(),
            widget.trip.departure,
            widget.trip.departureTime,
            AppColors.success,
            Icons.circle_outlined,
          ),
          const SizedBox(height: AppConstants.spacingS),
          _tripPoint(
            'arrival'.tr(),
            widget.trip.arrival,
            _calculateArrivalTime(),
            AppColors.error,
            Icons.location_on,
          ),
        ],
      ),
    );
  }

  Widget _tripPoint(
    String title,
    String location,
    String time,
    Color color,
    IconData icon,
  ) {
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
        Text(
          widget.trip.formattedDate,
          style: TextStyle(color: AppColors.success),
        ),
        Text(
          '${'estimated_time'.tr()} ${_formatDuration()}',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _passengersTile() => GestureDetector(
    onTap: _showPassengersList,
    child: _simpleTile('${widget.trip.passengers.length} ${'passengers'.tr()}'),
  );

  Widget _schoolsTile() => GestureDetector(
    onTap: _showSchoolsList,
    child: _simpleTile(
      '${widget.trip.schools.length} ${widget.trip.schools.length > 1 ? 'schools_served'.tr() : 'school_served'.tr()}',
    ),
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
    // Calcul de la moyenne
    final avgRating = _evaluations.isEmpty
        ? 0.0
        : _evaluations.map((e) => e.rating).reduce((a, b) => a + b) /
              _evaluations.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'reviews'.tr(),
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_evaluations.isNotEmpty)
              Row(
                children: [
                  Text(
                    avgRating.toStringAsFixed(1),
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.warning,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.star, color: AppColors.warning, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    '(${_evaluations.length})',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
          ],
        ),

        const SizedBox(height: 16),

        // GRAPHIQUE DES ÉTOILES
        if (_evaluations.isNotEmpty) _buildRatingBars(),

        const SizedBox(height: 20),

        // LISTE DES AVIS
        if (_isLoadingEvaluations)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: CircularProgressIndicator(color: AppColors.success),
            ),
          )
        else if (_evaluations.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'no_reviews'.tr(),
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
              ),
            ),
          )
        else
          Column(
            children: _evaluations
                .take(3)
                .map((eval) => _buildEvaluationCard(eval))
                .toList(),
          ),
      ],
    );
  }

  //  Graphique des étoiles
  Widget _buildRatingBars() {
    final counts = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    for (var eval in _evaluations) {
      counts[eval.rating] = (counts[eval.rating] ?? 0) + 1;
    }

    return Column(
      children: [5, 4, 3, 2, 1].map((star) {
        final count = counts[star] ?? 0;
        final percentage = _evaluations.isEmpty
            ? 0.0
            : count / _evaluations.length;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Text(
                '$star',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 4),
              Icon(Icons.star, size: 14, color: AppColors.warning),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percentage,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation(
                      star == 5
                          ? AppColors.success
                          : star >= 3
                          ? AppColors.warning
                          : AppColors.error,
                    ),
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 30,
                child: Text(
                  '$count',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEvaluationCard(EvaluationModel eval) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.success.withValues(alpha: 0.1),
                child: Text(
                  eval.parentName != null && eval.parentName!.isNotEmpty
                      ? eval.parentName![0].toUpperCase()
                      : '?',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      eval.parentName ?? 'unknown'.tr(),
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          return Icon(
                            index < eval.rating
                                ? Icons.star
                                : Icons.star_border,
                            size: 14,
                            color: AppColors.warning,
                          );
                        }),
                        const SizedBox(width: 8),
                        Text(
                          eval.formattedDate,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // BOUTON MODIFIER
              IconButton(
                icon: Icon(Icons.edit, size: 18, color: AppColors.primary),
                onPressed: () async {
                  // Ouvrir ReviewPage en mode édition
                  final result = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReviewPage(
                        trip: widget.trip,
                        existingEvaluation:
                            eval, // Passer l'évaluation existante
                      ),
                    ),
                  );

                  // Recharger si modifié
                  if (result == true) {
                    _loadEvaluations();
                  }
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          if (eval.comment != null && eval.comment!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              eval.comment!,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.grey.shade700,
                height: 1.4,
              ),
            ),
          ],
        ],
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

  void _callDriver(BuildContext context) async {
    final phone = widget.trip.driver?.phone ?? widget.trip.driverPhone;
    if (phone == null || phone.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('phone_not_available'.tr(), style: GoogleFonts.inter()),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'cannot_open_phone_app'.tr(),
            style: GoogleFonts.inter(),
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _openChatWithDriver() async {
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint(' [DEBUG] Vérification chauffeur:');
    debugPrint('   Driver existe? ${widget.trip.driver != null}');
    debugPrint('   Driver ID: ${widget.trip.driver?.id}');
    debugPrint('   Driver User ID: ${widget.trip.driver?.userId}');
    debugPrint('   Driver Name: ${widget.trip.driver?.fullName}');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    final driverUserId = widget.trip.driver?.userId;

    if (driverUserId == null || driverUserId.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'driver_not_available'.tr(),
            style: GoogleFonts.inter(),
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    try {
      final driverUserIdInt = int.parse(driverUserId);

      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint(' [TripTrackingPage] OUVERTURE DU CHAT');
      debugPrint('   User ID: $driverUserIdInt ← POUR MESSAGERIE');
      debugPrint('   Driver ID: ${widget.trip.driverId} ← RÉFÉRENCE');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      if (!mounted) return;

      final currentState = context.read<ConversationBloc>().state;
      ConversationModel? existingConversation;

      if (currentState is ConversationLoaded) {
        try {
          existingConversation = currentState.conversations.firstWhere(
            (conv) => conv.otherUserId == driverUserIdInt,
          );
          debugPrint(
            ' Conversation existante trouvée: ${existingConversation.id}',
          );
        } catch (e) {
          debugPrint(' Aucune conversation existante, création...');
        }
      }

      if (existingConversation != null) {
        if (!mounted) return;
        final nav = Navigator.of(context);
        await nav.push(
          MaterialPageRoute(
            builder: (ctx) => ChatPage(conversation: existingConversation!),
          ),
        );
      } else {
        if (!mounted) return;
        final dialogContext = context;
        showDialog(
          context: dialogContext,
          barrierDismissible: false,
          builder: (context) => Center(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppColors.success),
                    const SizedBox(height: 16),
                    Text('loading'.tr(), style: GoogleFonts.inter()),
                  ],
                ),
              ),
            ),
          ),
        );

        if (!mounted) return;
        context.read<ConversationBloc>().add(
          CreateDirectConversationEvent(otherUserId: driverUserIdInt),
        );

        await Future.delayed(const Duration(milliseconds: 100));

        int attempts = 0;
        const maxAttempts = 30;

        while (attempts < maxAttempts) {
          await Future.delayed(const Duration(milliseconds: 100));

          if (!mounted) {
            if (dialogContext.mounted) {
              Navigator.of(dialogContext, rootNavigator: true).pop();
            }
            return;
          }

          final state = context.read<ConversationBloc>().state;

          if (state is ConversationCreated) {
            if (dialogContext.mounted) {
              Navigator.of(dialogContext, rootNavigator: true).pop();
            }

            if (mounted) {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ChatPage(conversation: state.conversation),
                ),
              );
            }
            return;
          } else if (state is ConversationLoaded) {
            try {
              final conversation = state.conversations.firstWhere(
                (conv) => conv.otherUserId == driverUserIdInt,
              );

              if (dialogContext.mounted) {
                Navigator.of(dialogContext, rootNavigator: true).pop();
              }

              if (!mounted) return;
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (ctx) => ChatPage(conversation: conversation),
                ),
              );
              return;
            } catch (e) {
              //
            }
          } else if (state is ConversationError) {
            if (dialogContext.mounted) {
              Navigator.of(dialogContext, rootNavigator: true).pop();
            }
            throw Exception(state.message);
          }

          attempts++;
        }

        if (dialogContext.mounted) {
          Navigator.of(dialogContext, rootNavigator: true).pop();
        }
        throw Exception('Timeout lors de la création de la conversation');
      }
    } catch (e) {
      debugPrint(' Erreur ouverture chat: $e');

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('chat_error'.tr(), style: GoogleFonts.inter()),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}
