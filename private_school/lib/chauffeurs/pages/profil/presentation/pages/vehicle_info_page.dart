import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_constants.dart';
import '../../data/models/driver_profile_model.dart';

/// Vehicle information page for drivers
/// Displays vehicle details (read-only from API)
class VehicleInfoPage extends StatelessWidget {
  final DriverProfileModel profile;

  const VehicleInfoPage({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final vehicle = profile.vehicle;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.textWhite,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Informations du véhicule',
          style: GoogleFonts.inter(
            fontSize: AppConstants.fontSizeXL,
            fontWeight: FontWeight.w600,
            color: AppColors.textWhite,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacingXL + 4),
        child: Column(
          children: [
            // Vehicle photo placeholder
            Center(
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(
                    AppConstants.radiusXL - 8,
                  ),
                ),
                child: vehicle?.photo != null && vehicle!.photo!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(
                          AppConstants.radiusXL - 8,
                        ),
                        child: Image.network(
                          vehicle.photo!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.directions_car,
                              size: 64,
                              color: AppColors.primary,
                            );
                          },
                        ),
                      )
                    : const Icon(
                        Icons.directions_car,
                        size: 64,
                        color: AppColors.primary,
                      ),
              ),
            ),

            const SizedBox(height: AppConstants.spacingXXXL),

            // Vehicle information message
            if (vehicle == null)
              Center(
                child: Column(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 64,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: AppConstants.spacingL),
                    Text(
                      'Aucun véhicule enregistré',
                      style: GoogleFonts.inter(
                        fontSize: AppConstants.fontSizeXL,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingS),
                    Text(
                      'Veuillez contacter l\'administration\npour enregistrer votre véhicule',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: AppConstants.fontSizeM,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              )
            else ...[
              // Vehicle brand
              _buildInfoField(
                'Marque du véhicule',
                vehicle.brand ?? 'Non renseigné',
                Icons.local_shipping_outlined,
              ),
              const SizedBox(height: AppConstants.spacingXL),

              // Vehicle color
              _buildInfoField(
                'Couleur du véhicule',
                vehicle.color ?? 'Non renseigné',
                Icons.color_lens_outlined,
              ),
              const SizedBox(height: AppConstants.spacingXL),

              // Vehicle plate
              _buildInfoField(
                'Immatriculation du véhicule',
                vehicle.plate ?? 'Non renseigné',
                Icons.credit_card_outlined,
              ),
              const SizedBox(height: AppConstants.spacingXL),

              // Vehicle capacity
              _buildInfoField(
                'Nombre de places',
                vehicle.capacity != null
                    ? '${vehicle.capacity} places'
                    : 'Non renseigné',
                Icons.event_seat_outlined,
              ),
              const SizedBox(height: AppConstants.spacingXL),

              // Vehicle type (if available)
              if (vehicle.type != null && vehicle.type!.isNotEmpty)
                _buildInfoField(
                  'Type de véhicule',
                  vehicle.type!,
                  Icons.category_outlined,
                ),
            ],

            const SizedBox(height: AppConstants.spacingXXXL),

            // Info message
            Container(
              padding: const EdgeInsets.all(AppConstants.spacingXL),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusL),
                border: Border.all(
                  color: AppColors.info.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: AppColors.info,
                    size: 24,
                  ),
                  const SizedBox(width: AppConstants.spacingL),
                  Expanded(
                    child: Text(
                      'Pour modifier les informations du véhicule, veuillez contacter l\'administration.',
                      style: GoogleFonts.inter(
                        fontSize: AppConstants.fontSizeS + 1,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoField(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: AppColors.primary,
            ),
            const SizedBox(width: AppConstants.spacingS),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: AppConstants.fontSizeS + 1,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spacingS),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingXL,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppConstants.radiusL),
            border: Border.all(color: AppColors.grey300),
          ),
          child: Text(
            value,
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeL - 1,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}