import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/trip_model.dart';
import '../widgets/review_page.dart';
import '../widgets/passengers_list_modal.dart';
import '../widgets/schools_list_modal.dart';
import '../../../../utils/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TripTrackingPage extends StatefulWidget {
  final TripModel trip;

  const TripTrackingPage({
    super.key,
    required this.trip,
  });

  @override
  State<TripTrackingPage> createState() => _TripTrackingPageState();
}

class _TripTrackingPageState extends State<TripTrackingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER VERT
            Container(
              color: AppColors.primaryGreen,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      'Dakar → ${widget.trip.arrival}',
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

            // CONTENU SCROLLABLE
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // CARTE COMPACTE EN HAUT
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        image: const DecorationImage(
                          image: NetworkImage(
                            'https://api.mapbox.com/styles/v1/mapbox/light-v10/static/pin-s+4CAF50(-17.4467,14.7167),pin-s+FF5252(-17.4677,14.6937)/auto/600x400?access_token=pk.eyJ1IjoibWFwYm94IiwiYSI6ImNpejY4NXVycTA2emYycXBndHRqcmZ3N3gifQ.rJcFIG214AriISLbB6B5aw',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Stack(
                        children: [
                          CustomPaint(
                            size: const Size(double.infinity, 200),
                            painter: RouteLinePainter(),
                          ),
                          // MARQUEURS
                          Positioned(
                            top: 60,
                            left: 40,
                            child: _buildMapMarker(Icons.circle, Colors.black, 'Départ'),
                          ),
                          Positioned(
                            bottom: 40,
                            right: 40,
                            child: _buildMapMarker(Icons.location_on, AppColors.primaryGreen, 'Arrivée'),
                          ),
                        ],
                      ),
                    ),

                    // CONTENU BLANC
                    Container(
                      color: Colors.white,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                // INFO CHAUFFEUR
                                if (widget.trip.driverName.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 10,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Stack(
                                          children: [
                                            CircleAvatar(
                                              radius: 24,
                                              backgroundColor: Colors.grey.shade200,
                                              backgroundImage: AssetImage('assets/images/${widget.trip.driverImg}'),
                                              onBackgroundImageError: (_, __) {},
                                              child: Icon(Icons.person, color: Colors.grey.shade600, size: 24),
                                            ),
                                            Positioned(
                                              right: 0,
                                              bottom: 0,
                                              child: CircleAvatar(
                                                radius: 8,
                                                backgroundColor: Colors.white,
                                                child: CircleAvatar(
                                                  radius: 6,
                                                  backgroundColor: AppColors.primaryGreen,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                widget.trip.driverName,
                                                style: GoogleFonts.inter(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Text(
                                                    widget.trip.plate,
                                                    style: GoogleFonts.inter(
                                                      fontSize: 13,
                                                      color: Colors.grey.shade600,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  const Icon(Icons.star, color: Colors.amber, size: 14),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    widget.trip.rating,
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
                                        const Icon(Icons.chevron_right, color: Colors.grey),
                                      ],
                                    ),
                                  ),

                                const SizedBox(height: 16),

                                // BOUTONS APPELER / MESSAGE
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () {},
                                        icon: const Icon(Icons.phone, size: 18),
                                        label: Text('Appeler', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primaryGreen,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () {},
                                        icon: Icon(Icons.chat_bubble_outline, size: 18, color: AppColors.primaryGreen),
                                        label: Text('Message', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppColors.primaryGreen)),
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          side: BorderSide(color: AppColors.primaryGreen),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 20),

                                // TRAJET
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey.shade200),
                                  ),
                                  child: Column(
                                    children: [
                                      _buildTripPoint(
                                        icon: Icons.circle_outlined,
                                        iconColor: AppColors.primaryGreen,
                                        title: 'Point de départ',
                                        location: widget.trip.departure,
                                        time: widget.trip.departureTime,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 8),
                                        child: SizedBox(
                                          width: 2,
                                          height: 20,
                                          child: CustomPaint(painter: DashedLinePainter()),
                                        ),
                                      ),
                                      _buildTripPoint(
                                        icon: Icons.location_on,
                                        iconColor: Colors.red,
                                        title: 'Destination',
                                        location: widget.trip.arrival,
                                        time: widget.trip.arrivalTime,
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // DATE + ESTIMATION
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      widget.trip.date,
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        color: AppColors.primaryGreen,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      'Estimation ${widget.trip.duration}',
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 20),

                                // PASSAGERS (CLIQUABLE)
                                GestureDetector(
                                  onTap: () {
                                    _showPassengersList();
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.grey.shade200),
                                    ),
                                    child: Row(
                                      children: [
                                        // AVATARS EMPILÉS
                                        SizedBox(
                                          width: 70,
                                          height: 30,
                                          child: Stack(
                                            children: [
                                              Positioned(
                                                left: 0,
                                                child: _buildAvatarCircle('MN', const Color(0xFF4CAF50)),
                                              ),
                                              Positioned(
                                                left: 20,
                                                child: _buildAvatarCircle('AD', const Color(0xFF2196F3)),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            '03 passagers',
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ),
                                        const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                                      ],
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // ÉCOLES DESSERVIES (CLIQUABLE)
                                GestureDetector(
                                  onTap: () {
                                    _showSchoolsList();
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.grey.shade200),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryGreen.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Center(
                                            child: SvgPicture.asset(
                                              'assets/icons/etablissement.svg',
                                              width: 22,
                                              height: 22,
                                              color: AppColors.primaryGreen, // optionnel si tu veux colorer le SVG
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Écoles désservies',
                                                style: GoogleFonts.inter(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                '2 écoles',
                                                style: GoogleFonts.inter(
                                                  fontSize: 12,
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                                      ],
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 24),

                                // SECTION AVIS
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // STATISTIQUES NOTES
                                    Row(
                                      children: [
                                        // GRAPHIQUE BARRES
                                        Expanded(
                                          child: Column(
                                            children: [
                                              _buildRatingBar(5, 0.8),
                                              const SizedBox(height: 4),
                                              _buildRatingBar(4, 0.6),
                                              const SizedBox(height: 4),
                                              _buildRatingBar(3, 0.3),
                                              const SizedBox(height: 4),
                                              _buildRatingBar(2, 0.1),
                                              const SizedBox(height: 4),
                                              _buildRatingBar(1, 0.05),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 20),
                                        // NOTE MOYENNE
                                        Column(
                                          children: [
                                            Text(
                                              '4.0',
                                              style: GoogleFonts.inter(
                                                fontSize: 40,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            Row(
                                              children: List.generate(5, (index) {
                                                return Icon(
                                                  index < 4 ? Icons.star : Icons.star_border,
                                                  color: Colors.amber,
                                                  size: 16,
                                                );
                                              }),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '52 avis',
                                              style: GoogleFonts.inter(
                                                fontSize: 12,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 24),

                                    // LISTE DES AVIS
                                    _buildReviewItem(
                                      name: 'Aïssatou Diop',
                                      rating: 5,
                                      time: 'il y a 2 minutes',
                                      comment: 'Parfait, je recommande vivement !',
                                      avatar: 'AD',
                                      avatarColor: const Color(0xFF2196F3),
                                    ),

                                    const SizedBox(height: 16),

                                    _buildReviewItem(
                                      name: 'Issa Ndiaye',
                                      rating: 4,
                                      time: 'il y a 2 minutes',
                                      comment: 'Consequat velit qui adipisicing sunt do rependerit ad laborum tempor ullamco.',
                                      avatar: 'IN',
                                      avatarColor: const Color(0xFFFF9800),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 100), // Espace pour le bouton fixe
                              ],
                            ),
                          ),
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
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2)),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReviewPage(trip: widget.trip),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5B4FC7),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: Text('Donner un avis', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ),
      ),
    );
  }

  Widget _buildMapMarker(IconData icon, Color color, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 8, spreadRadius: 2)],
          ),
          child: Icon(icon, color: Colors.white, size: 16),
        ),
      ],
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
        Icon(icon, color: iconColor, size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.inter(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Text(location, style: GoogleFonts.inter(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
        Text(time, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF2196F3))),
      ],
    );
  }

  Widget _buildAvatarCircle(String initials, Color color) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
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

  Widget _buildRatingBar(int stars, double percentage) {
    return Row(
      children: [
        Text(
          '$stars',
          style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade600),
        ),
        const SizedBox(width: 4),
        const Icon(Icons.star, color: Colors.amber, size: 12),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 6,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percentage,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF00897B),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewItem({
    required String name,
    required int rating,
    required String time,
    required String comment,
    required String avatar,
    required Color avatarColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: avatarColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    avatar,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: avatarColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          return Icon(
                            index < rating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 14,
                          );
                        }),
                        const SizedBox(width: 8),
                        Text(
                          time,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            comment,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.grey.shade700,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  void _showPassengersList() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => PassengersListModal(passengers: widget.trip.passengers),
    );
  }

  void _showSchoolsList() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => SchoolsListModal(schools: widget.trip.schools),
    );
  }
}

class RouteLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF5B4FC7)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(size.width * 0.2, size.height * 0.3);
    path.quadraticBezierTo(size.width * 0.5, size.height * 0.5, size.width * 0.8, size.height * 0.7);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
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
      canvas.drawLine(Offset(size.width / 2, startY), Offset(size.width / 2, startY + dashHeight), paint);
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}