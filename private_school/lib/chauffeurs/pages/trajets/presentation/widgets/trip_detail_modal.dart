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
import 'trip_map_widget.dart';
import '../../data/services/child_service.dart';
import '../../../../../parents/pages/enfants/data/models/child_model.dart';
import '../../../../../parents/pages/school/data/services/school_service.dart';

/// Trip detail modal - Full screen design with Google Maps and real-time calculations
class TripDetailModal extends StatefulWidget {
  final TripModel trip;
  const TripDetailModal({super.key, required this.trip});

  @override
  State<TripDetailModal> createState() => _TripDetailModalState();
}

class _TripDetailModalState extends State<TripDetailModal> {
  final ChildService _childService = ChildService();
  final SchoolService _schoolService = SchoolService();
  List<ChildModel> _children = [];
  bool _loadingChildren = false;
  
  // ✅ NOUVEAU : Variable pour calculer l'heure d'arrivée
  int? _durationMinutes;

  @override
  void initState() {
    super.initState();
    _enrichSchoolDataAndLoadChildren();
  }

  /// Enrichir les données d'école puis charger les enfants
  Future<void> _enrichSchoolDataAndLoadChildren() async {
    if (widget.trip.schools.isEmpty) {
      debugPrint('⚠️ [TripDetailModal] Aucune école associée au trajet');
      return;
    }

    setState(() => _loadingChildren = true);

    try {
      final allSchools = await _schoolService.fetchSchools();
      List<ChildModel> allChildren = [];

      for (int i = 0; i < widget.trip.schools.length; i++) {
        final tripSchool = widget.trip.schools[i];
        
        if (tripSchool.id == null) continue;

        try {
          final fullSchool = allSchools.firstWhere(
            (s) => s.id == tripSchool.id,
            orElse: () => tripSchool,
          );
          
          final children = await _childService.getChildrenBySchool(fullSchool.id!);
          allChildren.addAll(children);
        } catch (e) {
          debugPrint('❌ Erreur: $e');
        }
      }

      setState(() {
        _children = allChildren;
        _loadingChildren = false;
      });
    } catch (e) {
      setState(() => _loadingChildren = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors du chargement des passagers'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// ✅ NOUVEAU : Callback quand le trajet est calculé
  void _onRouteCalculated(double distance, int duration) {
    setState(() {
      _durationMinutes = duration;
    });
    debugPrint('✅ Distance: ${distance.toStringAsFixed(1)} km');
    debugPrint('✅ Durée: $duration minutes');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      decoration: const BoxDecoration(
        color: AppColors.white,
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
                  _buildTripInfoCard(),
                  _buildPassengersSection(context),
                  _buildSchoolsSection(context),
                  const SizedBox(height: AppConstants.spacingXXXL),
                ],
              ),
            ),
          ),
          if (widget.trip.status == AppConstants.statusPending ||
              widget.trip.status == AppConstants.statusActive)
            _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.only(
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
        horizontal: AppConstants.spacingL,
        vertical: AppConstants.spacingL,
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

  /// ✅ NOUVELLE CARTE GOOGLE MAPS
  Widget _buildMap() {
    return Container(
      margin: const EdgeInsets.all(AppConstants.spacingXL),
      child: TripMapWidget(
        startLocation: widget.trip.startLocation ?? 'Dakar',
        destination: widget.trip.destination,
        onRouteCalculated: _onRouteCalculated,
      ),
    );
  }

  Widget _buildTripInfoCard() {
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
                      '${widget.trip.schools.length} ${widget.trip.schools.length > 1 ? "écoles desservies" : "école desservie"}',
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
          
          // ✅ HEURE DE DÉPART RÉELLE
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
                      widget.trip.startLocation ?? 'Non renseigné',
                      style: const TextStyle(
                        fontSize: AppConstants.fontSizeM,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              // ✅ AFFICHER L'HEURE RÉELLE DU CHAUFFEUR
              Text(
                widget.trip.time,
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
          
          // ✅ HEURE D'ARRIVÉE CALCULÉE
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
                      widget.trip.destination,
                      style: const TextStyle(
                        fontSize: AppConstants.fontSizeM,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              // ✅ CALCULER L'HEURE D'ARRIVÉE BASÉE SUR LA DURÉE
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
    final passengerCount = _children.length;
    
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
        child: _loadingChildren
            ? const Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Chargement des passagers...',
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeM,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              )
            : Row(
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
                  Text(
                    '$passengerCount ${passengerCount > 1 ? "enfants" : "enfant"}',
                    style: const TextStyle(
                      fontSize: AppConstants.fontSizeL,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
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
    final displayChildren = _children.take(3).toList();
    return SizedBox(
      width: 80,
      height: AppConstants.avatarSizeM,
      child: Stack(
        children: List.generate(displayChildren.length, (index) {
          final child = displayChildren[index];
          return Positioned(
            left: index * 24.0,
            child: Container(
              width: AppConstants.avatarSizeM,
              height: AppConstants.avatarSizeM,
              decoration: BoxDecoration(
                color: _getAvatarColor(child.name),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.white, width: 2),
              ),
              child: Center(
                child: Text(
                  child.initials,
                  style: const TextStyle(
                    color: AppColors.white,
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
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingXL),
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
      child: Row(
        children: [
          if (widget.trip.status == AppConstants.statusPending) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: () => _showCancelDialog(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppConstants.spacingL + 2,
                  ),
                  side: const BorderSide(color: AppColors.error, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusL),
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
                onPressed: () => _acceptTrip(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppConstants.spacingL + 2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusL),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Accepter',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: AppConstants.fontSizeL,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ] else if (widget.trip.status == AppConstants.statusActive) ...[
            Expanded(
              child: ElevatedButton(
                onPressed: () => _startTrip(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppConstants.spacingL + 2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusL),
                  ),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Démarrer le trajet',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: AppConstants.fontSizeL,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: AppConstants.spacingS),
                    Icon(Icons.arrow_forward, color: AppColors.white, size: 20),
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
    switch (widget.trip.status) {
      case AppConstants.statusPending:
        return {
          'bgColor': const Color(0xFFFEF3C7),
          'textColor': const Color(0xFFF59E0B),
          'label': 'En attente',
        };
      case AppConstants.statusActive:
      case 'in_progress':
        return {
          'bgColor': AppColors.primary.withValues(alpha: 0.1),
          'textColor': AppColors.primary,
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

  /// ✅ NOUVEAU : Calculer l'heure d'arrivée basée sur la durée réelle
  String _calculateArrivalTime() {
    if (_durationMinutes == null) {
      return '--:--';
    }

    try {
      final parts = widget.trip.time.split(':');
      if (parts.length == 2) {
        final hours = int.parse(parts[0]);
        final minutes = int.parse(parts[1]);
        
        // Ajouter la durée du trajet
        final totalMinutes = hours * 60 + minutes + _durationMinutes!;
        final arrivalHour = (totalMinutes ~/ 60) % 24;
        final arrivalMinute = totalMinutes % 60;
        
        return '${arrivalHour.toString().padLeft(2, '0')}:${arrivalMinute.toString().padLeft(2, '0')}';
      }
    } catch (e) {
      debugPrint('Error calculating arrival time: $e');
    }
    return '--:--';
  }

  Color _getAvatarColor(String name) {
    final colors = [
      const Color(0xFF3B82F6),
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
      const Color(0xFFEF4444),
      const Color(0xFF8B5CF6),
    ];
    return colors[name.hashCode % colors.length];
  }

  void _showPassengersList(BuildContext context) {
    final passengers = _children.map((child) => Passenger(
      id: child.id ?? '',
      name: child.name,
      school: child.schoolName,
      isConfirmed: true,
    )).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PassengersListModal(passengers: passengers),
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
    context.read<TripBloc>().add(StartTripEvent(widget.trip.id));
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Trajet accepté avec succès'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _startTrip(BuildContext context) {
    context.read<TripBloc>().add(StartTripEvent(widget.trip.id));
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Trajet démarré'),
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