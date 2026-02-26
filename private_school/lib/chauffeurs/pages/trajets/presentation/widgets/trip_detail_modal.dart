import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart' as easy;
import 'package:private_school/core/utils/app_colors.dart';
import 'package:private_school/core/utils/app_constants.dart';
import 'package:private_school/shared/widgets/realtime_trip_map_widget.dart';
import '../../data/models/trip_model.dart';
import '../../domain/bloc/trip_bloc.dart';
import '../../domain/bloc/trip_event.dart';
import 'passengers_list_modal.dart';
import 'schools_list_modal.dart';
import 'location_tracking_button.dart';

/// Trip detail modal with passenger count validation
class TripDetailModal extends StatefulWidget {
  final TripModel trip;
  const TripDetailModal({super.key, required this.trip});

  @override
  State<TripDetailModal> createState() => _TripDetailModalState();
}

class _TripDetailModalState extends State<TripDetailModal> {
  int? _durationMinutes;

  @override
  void initState() {
    super.initState();
    _logTripPassengers();
  }

  void _logTripPassengers() {
    debugPrint('Nombre de passagers: ${widget.trip.passengers.length}');
  }

  @override
 @override
Widget build(BuildContext context) {
 return Scaffold(
  backgroundColor: Colors.white,
  body: Column(
        children: [
          _buildHeader(context),

          // ✅ CARTE SORTIE DU SCROLLVIEW — gestes complètement libres
          _buildMap(),

          // ✅ CONTENU SCROLLABLE EN DESSOUS — indépendant de la carte
          Expanded(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                children: [
                  _buildTripInfoCard(),
                  _buildPassengersSection(context),
                  _buildSchoolsSection(context),
                  const SizedBox(height: AppConstants.spacingXXXL),
                ],
              ),
            ),
          ),

          if (widget.trip.status == AppConstants.statusPending ||
              widget.trip.status == 'in_progress' ||
              widget.trip.status == 'started' ||
              widget.trip.status == 'partially_completed' ||
              widget.trip.returnStatus == 'in_progress' ||
              (widget.trip.status == 'completed' &&
                  widget.trip.returnStatus == 'pending'))
            _buildActionButtons(context),
       ],
  ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + AppConstants.spacingL,
        left: AppConstants.spacingL,
        right: AppConstants.spacingL,
        bottom: AppConstants.spacingL,
      ),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppConstants.radiusXXL),
          topRight: Radius.circular(AppConstants.radiusXXL),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.white),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: AppConstants.spacingM),
          Expanded(
            child: Text(
              '${widget.trip.startLocation ?? "Point de départ"} → ${widget.trip.destination}',
              style: const TextStyle(
                color: AppColors.white,
                fontSize: AppConstants.fontSizeL + 2,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

Widget _buildMap() {
  final isActive = widget.trip.status == 'in_progress' ||
      widget.trip.status == 'started' ||
      widget.trip.returnStatus == 'in_progress' ||
      widget.trip.isActive;

  debugPrint('=== MAP isActive: $isActive | status: ${widget.trip.status} | returnStatus: ${widget.trip.returnStatus}');

  return SizedBox(
    height: 300,
    width: double.infinity,
    child: RealtimeTripMapWidget(
      tripId: widget.trip.id,
      startLocation: widget.trip.startLocation ?? 'Dakar',
      destination: widget.trip.destination,
      stops: widget.trip.schools,
      enableRealtime: isActive,
      isDriver: true,
    ),
  );
}
  Widget _buildTripInfoCard() {
    final isAllerCompleted =
        widget.trip.status == 'completed' ||
        widget.trip.status == 'partially_completed';
    final isRetourPending = widget.trip.returnStatus == 'pending';
    final isRetourInProgress = widget.trip.returnStatus == 'in_progress';
    final showReturnInfo =
        (isAllerCompleted && isRetourPending) || isRetourInProgress;

    final startPoint = showReturnInfo
        ? widget.trip.destination
        : (widget.trip.startLocation ?? 'Non renseigné');
    final endPoint = showReturnInfo
        ? (widget.trip.startLocation ?? 'Non renseigné')
        : widget.trip.destination;
    final departureTime = showReturnInfo && widget.trip.returnTime != null
        ? widget.trip.returnTime!
        : widget.trip.time;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spacingXL),
      padding: const EdgeInsets.all(AppConstants.spacingXL),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(color: AppColors.grey200),
        boxShadow: [
          BoxShadow(
            color: AppColors.blackOpacity05,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppConstants.spacingS),
                decoration: BoxDecoration(
                  color: AppColors.successBackground,
                  borderRadius: BorderRadius.circular(AppConstants.radiusS),
                ),
                child: const Icon(
                  Icons.calendar_today,
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
                      _formatDate(widget.trip.date),
                      style: const TextStyle(
                        fontSize: AppConstants.fontSizeL,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${widget.trip.passengers.length}/${widget.trip.totalSeats} places réservées',
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
          ),
          const SizedBox(height: AppConstants.spacingXL),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.radio_button_checked,
                color: AppColors.success,
                size: AppConstants.iconSizeM,
              ),
              const SizedBox(width: AppConstants.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Point de départ',
                      style: TextStyle(
                        fontSize: AppConstants.fontSizeS,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      startPoint,
                      style: const TextStyle(
                        fontSize: AppConstants.fontSizeM,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                departureTime,
                style: const TextStyle(
                  fontSize: AppConstants.fontSizeM,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          Container(
            margin: const EdgeInsets.only(
              left: AppConstants.spacingS - 1,
              top: AppConstants.spacingS,
              bottom: AppConstants.spacingS,
            ),
            height: AppConstants.spacingXL + 4,
            width: 2,
            child: CustomPaint(
              painter: DottedLinePainter(color: AppColors.grey300),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.location_on,
                color: AppColors.error,
                size: AppConstants.iconSizeM,
              ),
              const SizedBox(width: AppConstants.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Destination',
                      style: TextStyle(
                        fontSize: AppConstants.fontSizeS,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      endPoint,
                      style: const TextStyle(
                        fontSize: AppConstants.fontSizeM,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                _calculateArrivalTime(),
                style: const TextStyle(
                  fontSize: AppConstants.fontSizeM,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPassengersSection(BuildContext context) {
    final passengerCount = widget.trip.passengers.length;

    return GestureDetector(
      onTap: passengerCount > 0 ? () => _showPassengersList(context) : null,
      child: Container(
        margin: const EdgeInsets.fromLTRB(
          AppConstants.spacingXL,
          AppConstants.spacingL,
          AppConstants.spacingXL,
          0,
        ),
        padding: const EdgeInsets.all(AppConstants.spacingL + 4),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
          border: Border.all(color: AppColors.grey200),
          boxShadow: [
            BoxShadow(
              color: AppColors.blackOpacity05,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            if (passengerCount > 0) ...[
              _buildPassengerAvatars(),
              const SizedBox(width: AppConstants.spacingM),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(AppConstants.spacingS),
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(AppConstants.radiusS),
                ),
                child: const Icon(
                  Icons.people_outline,
                  color: AppColors.textSecondary,
                  size: AppConstants.iconSizeL,
                ),
              ),
              const SizedBox(width: AppConstants.spacingM),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    passengerCount > 0
                        ? 'Passagers inscrits'
                        : 'Aucun passager',
                    style: const TextStyle(
                      fontSize: AppConstants.fontSizeL,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '$passengerCount/${widget.trip.totalSeats}',
                    style: const TextStyle(
                      fontSize: AppConstants.fontSizeS,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (passengerCount > 0)
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
    final displayPassengers = widget.trip.passengers.take(3).toList();
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
                color: const Color(0xFFE8F5E9),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.white, width: 2),
              ),
              child: Center(
                child: Text(
                  passenger.initials,
                  style: const TextStyle(
                    color: Color(0xFF4CAF50),
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
    final schoolCount = widget.trip.schools.length;

    return GestureDetector(
      onTap: schoolCount > 0 ? () => _showSchoolsList(context) : null,
      child: Container(
        margin: const EdgeInsets.fromLTRB(
          AppConstants.spacingXL,
          AppConstants.spacingL,
          AppConstants.spacingXL,
          AppConstants.spacingL,
        ),
        padding: const EdgeInsets.all(AppConstants.spacingL + 4),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
          border: Border.all(color: AppColors.grey200),
          boxShadow: [
            BoxShadow(
              color: AppColors.blackOpacity05,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
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
                    'Écoles desservies',
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeL,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '$schoolCount ${schoolCount > 1 ? "écoles" : "école"}',
                    style: const TextStyle(
                      fontSize: AppConstants.fontSizeS,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (schoolCount > 0)
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

 Widget _buildActionButtons(BuildContext context) {
  final hasPassengers = widget.trip.passengers.isNotEmpty;
  final isAllerCompleted =
      widget.trip.status == 'completed' ||
      widget.trip.status == 'partially_completed';
  final isRetourPending = widget.trip.returnStatus == 'pending';
  final isRetourInProgress = widget.trip.returnStatus == 'in_progress';
  final showReturnButton = isAllerCompleted && isRetourPending;
  final showCompleteReturnButton = isRetourInProgress;

  return Container(
    padding: EdgeInsets.only(
      left: AppConstants.spacingXL,
      right: AppConstants.spacingXL,
      top: AppConstants.spacingXL,
      bottom: AppConstants.spacingXL + MediaQuery.of(context).padding.bottom,
    ),
    decoration: BoxDecoration(
      color: AppColors.white,
      boxShadow: [
        BoxShadow(
          color: AppColors.blackOpacity05,
          blurRadius: 10,
          offset: const Offset(0, -4),
        ),
      ],
    ),
    child: Column(
      children: [
        if (!hasPassengers &&
            widget.trip.status == AppConstants.statusActive) ...[
          Container(
            margin: const EdgeInsets.only(bottom: AppConstants.spacingM),
            padding: const EdgeInsets.all(AppConstants.spacingM),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
              border: Border.all(color: const Color(0xFFF59E0B)),
            ),
            child: const Row(
              children: [
                Icon(Icons.warning_amber, color: Color(0xFFF59E0B), size: 20),
                SizedBox(width: AppConstants.spacingM),
                Expanded(
                  child: Text(
                    'Vous devez avoir au moins 1 passager pour démarrer',
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeS,
                      color: Color(0xFFF59E0B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        Row(
          children: [
            if (widget.trip.status == AppConstants.statusPending) ...[
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showCancelDialog(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppConstants.spacingL + 2,
                    ),
                    side: const BorderSide(
                      color: AppColors.error,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppConstants.radiusL,
                      ),
                    ),
                  ),
                  child: const Text(
                    'Rejeter',
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
                  onPressed: hasPassengers
                      ? () => _acceptTrip(context)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.grey300,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppConstants.spacingL + 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppConstants.radiusL,
                      ),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Démarrer le trajet',
                        style: TextStyle(
                          color: hasPassengers
                              ? AppColors.white
                              : AppColors.grey600,
                          fontSize: AppConstants.fontSizeL,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: AppConstants.spacingS),
                      Icon(
                        Icons.arrow_forward,
                        color: hasPassengers
                            ? AppColors.white
                            : AppColors.grey600,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ] else if (widget.trip.status == 'in_progress' ||
                widget.trip.status == 'started') ...[
              // ✅ GPS + Terminer côte à côte correctement
              Expanded(
                child: LocationTrackingButton(tripId: widget.trip.id),
              ),
              const SizedBox(width: AppConstants.spacingM),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _completeTrip(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppConstants.spacingL + 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppConstants.radiusL,
                      ),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Terminer le trajet',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: AppConstants.fontSizeL,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: AppConstants.spacingS),
                      Icon(
                        Icons.check_circle,
                        color: AppColors.white,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ] else if (showReturnButton) ...[
              Expanded(
                child: ElevatedButton(
                  onPressed: hasPassengers
                      ? () => _startReturnTrip(context)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.grey300,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppConstants.spacingL + 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppConstants.radiusL,
                      ),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Démarrer le retour',
                        style: TextStyle(
                          color: hasPassengers
                              ? AppColors.white
                              : AppColors.grey600,
                          fontSize: AppConstants.fontSizeL,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: AppConstants.spacingS),
                      Icon(
                        Icons.arrow_forward,
                        color: hasPassengers
                            ? AppColors.white
                            : AppColors.grey600,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ] else if (showCompleteReturnButton) ...[
              // ✅ GPS + Terminer retour côte à côte correctement
              Expanded(
                child: LocationTrackingButton(tripId: widget.trip.id),
              ),
              const SizedBox(width: AppConstants.spacingM),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _completeReturnTrip(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppConstants.spacingL + 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppConstants.radiusL,
                      ),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Terminer le retour',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: AppConstants.fontSizeL,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: AppConstants.spacingS),
                      Icon(
                        Icons.check_circle,
                        color: AppColors.white,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
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
        borderRadius: BorderRadius.circular(AppConstants.radiusXXL),
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
    if ((widget.trip.status == 'completed' ||
            widget.trip.status == 'partially_completed') &&
        widget.trip.returnStatus == 'pending') {
      return {
        'bgColor': const Color(0xFFFEF3C7),
        'textColor': const Color(0xFFF59E0B),
        'label': 'Partiellement terminé',
      };
    }

    if (widget.trip.returnStatus == 'in_progress') {
      return {
        'bgColor': const Color(0xFFDCFCE7),
        'textColor': const Color(0xFF16A34A),
        'label': 'En cours (retour)',
      };
    }

    switch (widget.trip.status) {
      case AppConstants.statusPending:
        return {
          'bgColor': const Color(0xFFFEF3C7),
          'textColor': const Color(0xFFF59E0B),
          'label': 'En attente',
        };
      case AppConstants.statusActive:
        return {
          'bgColor': AppColors.primary.withValues(alpha: 0.1),
          'textColor': AppColors.primary,
          'label': 'Accepté',
        };
      case 'in_progress':
      case 'started':
        return {
          'bgColor': const Color(0xFFDCFCE7),
          'textColor': const Color(0xFF16A34A),
          'label': 'En cours',
        };
      case AppConstants.statusCompleted:
        return {
          'bgColor': AppColors.successBackground,
          'textColor': AppColors.success,
          'label': 'Terminé',
        };
      default:
        return {
          'bgColor': AppColors.grey200,
          'textColor': AppColors.grey700,
          'label': widget.trip.status,
        };
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;

    if (difference == 0) {
      return "Aujourd'hui";
    } else if (difference == 1) {
      return 'Demain';
    } else {
      final formatted = DateFormat('EEEE d MMMM', 'fr_FR').format(date);
      return formatted[0].toUpperCase() + formatted.substring(1);
    }
  }

  String _calculateArrivalTime() {
    if (_durationMinutes == null) return '--:--';

    try {
      final parts = widget.trip.time.split(':');
      if (parts.length == 2) {
        final hours = int.parse(parts[0]);
        final minutes = int.parse(parts[1]);
        final totalMinutes = hours * 60 + minutes + _durationMinutes!;
        final arrivalHour = (totalMinutes ~/ 60) % 24;
        final arrivalMinute = totalMinutes % 60;
        return '${arrivalHour.toString().padLeft(2, '0')}:${arrivalMinute.toString().padLeft(2, '0')}';
      }
    } catch (e) {
      //
    }
    return '--:--';
  }

  void _showPassengersList(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          PassengersListModal(passengers: widget.trip.passengers),
    );
  }

  void _showSchoolsList(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SchoolsListModal(schools: widget.trip.schools),
    );
  }

  void _acceptTrip(BuildContext context) {
    if (widget.trip.passengers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('cannot_start_no_passengers'.tr()),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    context.read<TripBloc>().add(StartTripEvent(widget.trip.id));
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('trip_started_successfully'.tr()),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _completeTrip(BuildContext context) {
    context.read<TripBloc>().add(CompleteTripEvent(widget.trip.id));
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('trip_completed_successfully'.tr()),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _startReturnTrip(BuildContext context) {
    if (widget.trip.passengers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('cannot_start_no_passengers'.tr()),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    context.read<TripBloc>().add(
      StartTripEvent(widget.trip.id, direction: 'retour'),
    );
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('return_trip_started'.tr()),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _completeReturnTrip(BuildContext context) {
    context.read<TripBloc>().add(
      CompleteTripEvent(widget.trip.id, direction: 'retour'),
    );
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('return_trip_completed_successfully'.tr()),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(
          'Rejeter le trajet',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: const Text(
          'Êtes-vous sûr de vouloir rejeter ce trajet ?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'Annuler',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              context.read<TripBloc>().add(
                CancelTripEvent(
                  tripId: widget.trip.id,
                  reason: 'Rejeté par le chauffeur',
                ),
              );
              Navigator.pop(dialogContext);
              Navigator.pop(context);
            },
            child: const Text(
              'Rejeter',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DottedLinePainter extends CustomPainter {
  final Color color;

  DottedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    const dashHeight = 4.0;
    const dashSpace = 4.0;
    double startY = 0;

    while (startY < size.height) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashHeight), paint);
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
