import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ================= HEADER =================
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
                      'Dakar → ${widget.trip.arrival}',
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

            // ================= CONTENT =================
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // ================= MAP =================
                    Container(
                      height: AppConstants.mapHeight,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.grey200,
                        image: const DecorationImage(
                          image: NetworkImage(
                            'https://api.mapbox.com/styles/v1/mapbox/light-v10/static/pin-s+4CAF50(-17.4467,14.7167),pin-s+FF5252(-17.4677,14.6937)/auto/600x400',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Stack(
                        children: [
                          CustomPaint(
                            size: Size(double.infinity, AppConstants.mapHeight),
                            painter: RouteLinePainter(),
                          ),
                          Positioned(
                            top: 60,
                            left: 40,
                            child: _buildMapMarker(
                              Icons.circle,
                              AppColors.textPrimary,
                            ),
                          ),
                          Positioned(
                            bottom: 40,
                            right: 40,
                            child: _buildMapMarker(
                              Icons.location_on,
                              AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ================= WHITE CONTENT =================
                    Container(
                      color: AppColors.white,
                      padding: const EdgeInsets.all(AppConstants.spacingXL),
                      child: Column(
                        children: [
                          // ===== DRIVER CARD =====
                          if (widget.trip.driverName.isNotEmpty)
                            _driverCard(),

                          const SizedBox(height: AppConstants.spacingM),

                          // ===== CALL / MESSAGE =====
                          _actionButtons(),

                          const SizedBox(height: AppConstants.spacingXL),

                          // ===== TRIP DETAILS =====
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

      // ================= BOTTOM BUTTON =================
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
              padding: const EdgeInsets.symmetric(
                vertical: AppConstants.spacingM,
              ),
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

  // ================= COMPONENTS =================

  Widget _buildMapMarker(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingS),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Icon(icon, color: AppColors.white, size: 16),
    );
  }

  Widget _driverCard() {
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
          CircleAvatar(
            radius: AppConstants.avatarSizeM,
            backgroundColor: AppColors.grey200,
            backgroundImage: AssetImage(
              'assets/images/${widget.trip.driverImg}',
            ),
          ),
          const SizedBox(width: AppConstants.spacingM),
          Expanded(
            child: Text(
              widget.trip.driverName,
              style: GoogleFonts.inter(
                fontSize: AppConstants.fontSizeM,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textGrey),
        ],
      ),
    );
  }

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
            onPressed: () {},
            icon: Icon(Icons.chat, color: AppColors.success),
            label: Text(
              'Message',
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
            widget.trip.arrivalTime,
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
        Expanded(
          child: Text(location),
        ),
        Text(
          time,
          style: TextStyle(
            color: AppColors.info,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _dateEstimation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          widget.trip.date,
          style: TextStyle(color: AppColors.success),
        ),
        Text(
          'Estimation ${widget.trip.duration}',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _passengersTile() => GestureDetector(
        onTap: _showPassengersList,
        child: _simpleTile('03 passagers'),
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
      builder: (_) =>
          PassengersListModal(passengers: widget.trip.passengers),
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

// ================= PAINTERS =================

class RouteLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.secondary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(size.width * 0.2, size.height * 0.3)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.5,
        size.width * 0.8,
        size.height * 0.7,
      );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}
