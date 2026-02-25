import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:private_school/shared/widgets/realtime_trip_map_widget.dart';
import '../../data/models/trip_model.dart';
import '../../../enfants/data/models/child_model.dart';
import '../widgets/driver_details_modal.dart';
import '../widgets/passengers_list_modal.dart';
import '../widgets/schools_list_modal.dart';
import '../widgets/select_children_modal.dart';
import '../pages/payment_page.dart';
import '../../../../../core/utils/app_colors.dart';
import '../../data/repositories/trip_repository.dart';
import '../../../enfants/domain/bloc/child_bloc.dart';
import '../../../acceuil/presentation/pages/chat.dart';
import '../../../acceuil/data/services/messaging_service.dart';
import '../../../acceuil/domain/bloc/message_bloc.dart';

class TripDetailPage extends StatefulWidget {
  final TripModel trip;
  const TripDetailPage({super.key, required this.trip});
  @override
  State<TripDetailPage> createState() => _TripDetailPageState();
}

class _TripDetailPageState extends State<TripDetailPage> {
  int? _durationMinutes;
  List<ChildModel> _selectedChildren = [];

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
    return BlocProvider.value(
      value: context.read<ChildBloc>(),
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: Column(
          children: [
            // HEADER
            Container(
              color: AppColors.success,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 12,
                left: 16,
                right: 16,
                bottom: 12,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      '${widget.trip.departure} → ${widget.trip.destination}',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      height: 250,
                      width: double.infinity,
                      margin: const EdgeInsets.all(16),
                      child: GestureDetector(
                        onVerticalDragUpdate: (_) {},
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: RealtimeTripMapWidget(
                            tripId: widget.trip.id,
                            startLocation: widget.trip.departure,
                            destination: widget.trip.arrival,
                            stops: widget.trip.schools,
                            enableRealtime: false,
                          ),
                        ),
                      ),
                    ),

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),

                          // INFO CHAUFFEUR
                          if (widget.trip.driver != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: GestureDetector(
                                onTap: _showDriverDetails,
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.05,
                                        ),
                                        blurRadius: 10,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 28,
                                        backgroundColor: Colors.grey.shade200,
                                        backgroundImage:
                                            widget.trip.hasDriverPhoto
                                            ? NetworkImage(
                                                widget.trip.driverPhotoUrl,
                                              )
                                            : null,
                                        onBackgroundImageError:
                                            widget.trip.hasDriverPhoto
                                            ? (_, __) {
                                                debugPrint(
                                                  '! Erreur chargement photo chauffeur',
                                                );
                                              }
                                            : null,
                                        child: !widget.trip.hasDriverPhoto
                                            ? Icon(
                                                Icons.person,
                                                color: Colors.grey.shade600,
                                                size: 28,
                                              )
                                            : null,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              widget.trip.driver!.fullName,
                                              style: GoogleFonts.inter(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Text(
                                                  widget
                                                          .trip
                                                          .driver!
                                                          .licenseNumber ??
                                                      '',
                                                  style: GoogleFonts.inter(
                                                    fontSize: 13,
                                                    color: Colors.grey.shade600,
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                const Icon(
                                                  Icons.star,
                                                  color: Colors.amber,
                                                  size: 16,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  widget.trip.driverRatingValue >
                                                          0
                                                      ? widget
                                                            .trip
                                                            .driverRatingValue
                                                            .toStringAsFixed(1)
                                                      : 'N/A',
                                                  style: GoogleFonts.inter(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(
                                        Icons.chevron_right,
                                        color: Colors.grey,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                          const SizedBox(height: 16),

                          // BOUTONS APPELER / MESSAGE
                          if (widget.trip.driver != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () => _callDriver(context),
                                      icon: const Icon(Icons.phone, size: 18),
                                      label: Text(
                                        'call'.tr(),
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.success,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () =>
                                          _openChatWithDriver(context),
                                      icon: Icon(
                                        Icons.chat_bubble_outline,
                                        size: 18,
                                        color: AppColors.success,
                                      ),
                                      label: Text(
                                        'message'.tr(),
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.success,
                                        ),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14,
                                        ),
                                        side: BorderSide(
                                          color: AppColors.success,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          const SizedBox(height: 20),

                          // DÉTAILS DU TRAJET
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  _buildTripPoint(
                                    icon: Icons.circle_outlined,
                                    iconColor: AppColors.success,
                                    title: 'departure_point'.tr(),
                                    location: widget.trip.departure,
                                    time: widget.trip.departureTime,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8),
                                    child: SizedBox(
                                      width: 2,
                                      height: 30,
                                      child: CustomPaint(
                                        painter: DashedLinePainter(),
                                      ),
                                    ),
                                  ),
                                  _buildTripPoint(
                                    icon: Icons.location_on,
                                    iconColor: Colors.red,
                                    title: 'destination'.tr(),
                                    location: widget.trip.arrival,
                                    time: _calculateArrivalTime(),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // DATE + ESTIMATION
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  widget.trip.formattedDate,
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: AppColors.success,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  'Estimation ${_formatDuration()}',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // ENFANTS SÉLECTIONNÉS
                          if (_selectedChildren.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.success.withValues(
                                    alpha: 0.05,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: AppColors.success.withValues(
                                      alpha: 0.2,
                                    ),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.check_circle,
                                          color: AppColors.success,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${_selectedChildren.length} ${'children_selected'.tr()}',
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.success,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    ..._selectedChildren.map(
                                      (child) => Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 8,
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 32,
                                              height: 32,
                                              decoration: BoxDecoration(
                                                color: AppColors.success
                                                    .withValues(alpha: 0.1),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Center(
                                                child: Text(
                                                  child.name[0].toUpperCase(),
                                                  style: GoogleFonts.inter(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppColors.success,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                child.name,
                                                style: GoogleFonts.inter(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                          const SizedBox(height: 16),

                          // PASSAGERS
                          if (widget.trip.passengers.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: GestureDetector(
                                onTap: _showPassengersList,
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.05,
                                        ),
                                        blurRadius: 10,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 80,
                                        height: 32,
                                        child: Stack(
                                          children: [
                                            if (widget
                                                .trip
                                                .passengers
                                                .isNotEmpty)
                                              Positioned(
                                                left: 0,
                                                child: _buildPassengerAvatar(
                                                  widget
                                                      .trip
                                                      .passengers[0]
                                                      .initials,
                                                  Color(
                                                    int.parse(
                                                      (widget
                                                                  .trip
                                                                  .passengers[0]
                                                                  .avatarColor ??
                                                              '#4CAF50')
                                                          .replaceFirst(
                                                            '#',
                                                            '0xFF',
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            if (widget.trip.passengers.length >
                                                1)
                                              Positioned(
                                                left: 24,
                                                child: _buildPassengerAvatar(
                                                  widget
                                                      .trip
                                                      .passengers[1]
                                                      .initials,
                                                  Color(
                                                    int.parse(
                                                      (widget
                                                                  .trip
                                                                  .passengers[1]
                                                                  .avatarColor ??
                                                              '#4CAF50')
                                                          .replaceFirst(
                                                            '#',
                                                            '0xFF',
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            if (widget.trip.passengers.length >
                                                2)
                                              Positioned(
                                                left: 48,
                                                child: _buildPassengerAvatar(
                                                  widget
                                                      .trip
                                                      .passengers[2]
                                                      .initials,
                                                  Color(
                                                    int.parse(
                                                      (widget
                                                                  .trip
                                                                  .passengers[2]
                                                                  .avatarColor ??
                                                              '#4CAF50')
                                                          .replaceFirst(
                                                            '#',
                                                            '0xFF',
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          '${widget.trip.passengers.length.toString().padLeft(2, '0')} ${'passengers'.tr()}',
                                          style: GoogleFonts.inter(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                      const Icon(
                                        Icons.chevron_right,
                                        color: Colors.grey,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                          const SizedBox(height: 16),

                          // ÉCOLES
                          if (widget.trip.schools.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: GestureDetector(
                                onTap: _showSchoolsList,
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.05,
                                        ),
                                        blurRadius: 10,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: AppColors.success.withValues(
                                            alpha: 0.1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Center(
                                          child: Image.asset(
                                            'assets/icons/etablissement.png',
                                            width: 22,
                                            height: 22,
                                            color: AppColors.success,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    Icon(
                                                      Icons.school,
                                                      color: AppColors.success,
                                                      size: 22,
                                                    ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'schools_served'.tr(),
                                              style: GoogleFonts.inter(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              '${widget.trip.schools.length} ${'schools_count'.tr()}',
                                              style: GoogleFonts.inter(
                                                fontSize: 13,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(
                                        Icons.chevron_right,
                                        color: Colors.grey,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: ElevatedButton(
              onPressed: _showChildrenSelectionModal,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                _selectedChildren.isEmpty
                    ? 'select_children'.tr()
                    : '${'confirm_reservation'.tr()} ${_selectedChildren.length} ${'children'.tr()}',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPassengerAvatar(String initials, Color color) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Center(
        child: Text(
          initials,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }

  Widget _buildTripPoint({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String location,
    required String time,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                location,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Text(
          time,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  void _showDriverDetails() {
    if (widget.trip.driver == null) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DriverDetailsModal(
        driver: widget.trip.driver!,
        vehiclePhotoUrl: widget.trip.vehiclePhotoUrl,
      ),
    );
  }

  void _showPassengersList() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) =>
          PassengersListModal(passengers: widget.trip.passengers),
    );
  }

  void _showSchoolsList() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => SchoolsListModal(schools: widget.trip.schools),
    );
  }

  void _callDriver(BuildContext context) async {
    final phone = widget.trip.driver?.phone ?? widget.trip.driverPhone;
    if (phone == null || phone.isEmpty) {
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
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'cannot_open_phone_app'.tr(),
            style: GoogleFonts.inter(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _openChatWithDriver(BuildContext context) async {
    // Vérifier si on a un driver_id
    final driverId = widget.trip.driverId;
    if (driverId == null || driverId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('chat_error'.tr(), style: GoogleFonts.inter()),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final messagingService = MessagingService();
      final conversation = await messagingService.createOrGetDirectConversation(
        otherUserId: int.parse(driverId),
      );

      if (!context.mounted) return;
      Navigator.pop(context);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => MessageBloc(),
            child: ChatPage(conversation: conversation),
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erreur lors de l\'ouverture du chat: $e',
            style: GoogleFonts.inter(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showChildrenSelectionModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: context.read<ChildBloc>(),
        child: SelectChildrenModal(
          onChildrenSelected: (selectedChildren) {
            setState(() {
              _selectedChildren = selectedChildren;
            });
            if (_selectedChildren.isNotEmpty) {
              _processReservation();
            }
          },
        ),
      ),
    );
  }

  Future<void> _processReservation() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF5B4FC7)),
      ),
    );

    try {
      final repository = TripRepository();
      final childIds = _selectedChildren
          .map((child) => child.id.toString())
          .toList();

      await repository.reserveTrip(tripId: widget.trip.id, childIds: childIds);

      if (!mounted) return;
      Navigator.of(context).pop();
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => PaymentPage(trip: widget.trip)));
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erreur lors de la réservation: $e',
            style: GoogleFonts.inter(fontWeight: FontWeight.w500),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}

class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade400
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
