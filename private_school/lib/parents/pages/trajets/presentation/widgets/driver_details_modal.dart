import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/driver_model.dart';
import '../../../../utils/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';


class DriverDetailsModal extends StatelessWidget {
  final DriverModel driver;

  const DriverDetailsModal({
    super.key,
    required this.driver,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // HEADER
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Détails chauffeur',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // PHOTO CHAUFFEUR avec badge vérifié
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: AssetImage('assets/images/${driver.photo}'),
                        onBackgroundImageError: (_, __) {},
                        /*child: Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.grey.shade600,
                        ),*/
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // NOM
                  Text(
                    driver.name,
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // MEMBRE DEPUIS
                  Text(
                    driver.memberSince,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // STATISTIQUES (3 colonnes)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatColumn(
                        icon: SvgPicture.asset(
                          'assets/icons/15.svg',
                          width: 24,
                          height: 24,
                          colorFilter: ColorFilter.mode(
                            AppColors.primaryGreen,
                            BlendMode.srcIn,
                          ),
                        ),
                        value: driver.totalTrips.toString(),
                        label: 'Trajets réussis',
                      ),


                      _buildStatColumn(
                        icon: Icon(
                          Icons.star,
                          color: AppColors.primaryGreen,
                          size: 24,
                        ),
                        iconColor: AppColors.primaryGreen,
                        value: driver.rating.toString(),
                        label: '${driver.totalReviews} avis',
                      ),

                      _buildStatColumn(
                        icon: Icon(
                          Icons.check_circle,
                          color: AppColors.primaryGreen,
                          size: 24,
                        ),
                        iconColor: AppColors.primaryGreen,
                        value: '${driver.successRate.toStringAsFixed(0)}%',
                        label: 'Taux de réussite',
                      ),

                    ],
                  ),

                  const SizedBox(height: 32),

                  // INFORMATIONS DU VÉHICULE
                  if (driver.vehicle != null) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Informations du véhicule',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // IMAGE DU BUS
                    Container(
                      width: double.infinity,
                      height: 180,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          'assets/images/${driver.vehicle!.photo}',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Icon(
                                Icons.directions_bus,
                                size: 80,
                                color: Colors.grey.shade400,
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // DÉTAILS VÉHICULE
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: [
                          _buildVehicleInfoRow(
                            'Modèle',
                            driver.vehicle!.model,
                          ),
                          const Divider(height: 24),
                          _buildVehicleInfoRow(
                            'Plaque',
                            driver.vehicle!.plate,
                          ),
                          const Divider(height: 24),
                          _buildVehicleInfoRow(
                            'Couleur',
                            driver.vehicle!.color,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],

                  // BOUTONS APPELER / MESSAGE
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Appeler le chauffeur
                            Navigator.pop(context);
                            // TODO: Lancer l'appel
                          },
                          icon: const Icon(Icons.phone, size: 18),
                          label: Text(
                            'Appeler',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGreen,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            // TODO: Ouvrir messagerie
                          },
                          icon: Icon(
                            Icons.chat_bubble_outline,
                            size: 18,
                            color: AppColors.primaryGreen,
                          ),
                          label: Text(
                            'Message',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(color: AppColors.primaryGreen),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn({
    required Widget icon,
    Color? iconColor,
    required String value,
    required String label,
  }) {

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: (iconColor ?? AppColors.primaryGreen).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: icon,
        ),

        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildVehicleInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}