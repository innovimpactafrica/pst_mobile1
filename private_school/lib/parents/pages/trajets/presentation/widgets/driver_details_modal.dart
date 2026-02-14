import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:private_school/parents/pages/acceuil/data/services/messaging_service.dart';
import 'package:private_school/parents/pages/acceuil/presentation/pages/chat.dart';
import 'package:private_school/parents/pages/acceuil/domain/bloc/message_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:private_school/chauffeurs/pages/authentification/data/models/driver_model.dart';
import '../../../../../core/utils/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:easy_localization/easy_localization.dart';

class DriverDetailsModal extends StatelessWidget {
  final DriverModel driver;

  const DriverDetailsModal({super.key, required this.driver});

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
                  'driver_details'.tr(),
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
                        backgroundImage: driver.photo != null && driver.photo!.isNotEmpty
                            ? NetworkImage(driver.photo!)
                            : null,
                        onBackgroundImageError: driver.photo != null && driver.photo!.isNotEmpty
                            ? (_, __) {
                                debugPrint('! Erreur chargement photo chauffeur');
                              }
                            : null,
                        child: driver.photo == null || driver.photo!.isEmpty
                            ? Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.grey.shade600,
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.success,
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
                    driver.fullName,
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
                            AppColors.success,
                            BlendMode.srcIn,
                          ),
                        ),
                        value: driver.totalTrips.toString(),
                        label: 'successful_trips'.tr(),
                      ),

                      _buildStatColumn(
                        icon: Icon(
                          Icons.star,
                          color: AppColors.success,
                          size: 24,
                        ),
                        iconColor: AppColors.success,
                        value: driver.rating.toString(),
                        label: '${driver.totalReviews} ${'reviews'.tr()}',
                      ),

                      _buildStatColumn(
                        icon: Icon(
                          Icons.check_circle,
                          color: AppColors.success,
                          size: 24,
                        ),
                        iconColor: AppColors.success,
                        value: '${driver.successRate.toStringAsFixed(0)}%',
                        label: 'success_rate'.tr(),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // INFORMATIONS DU VÉHICULE
                  if (driver.vehicle != null) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'vehicle_info'.tr(),
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
                        child: driver.vehicle!.photo != null && driver.vehicle!.photo!.isNotEmpty
                            ? Image.network(
                                driver.vehicle!.photo!,
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
                              )
                            : Center(
                                child: Icon(
                                  Icons.directions_bus,
                                  size: 80,
                                  color: Colors.grey.shade400,
                                ),
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
                          _buildVehicleInfoRow('model'.tr(), driver.vehicle!.model),
                          const Divider(height: 24),
                          _buildVehicleInfoRow('plate'.tr(), driver.vehicle!.plate),
                          const Divider(height: 24),
                          _buildVehicleInfoRow(
                            'color'.tr(),
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
                          onPressed: () => _openChat(context),
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
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(color: AppColors.success),
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
            color: (iconColor ?? AppColors.success).withValues(alpha: 0.1),
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
          style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade600),
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
          style: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade600),
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

  void _openChat(BuildContext context) async {
    Navigator.pop(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final messagingService = MessagingService();
      final conversation = await messagingService.createOrGetDirectConversation(
        otherUserId: int.parse(driver.id),
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
          content: Text('Erreur lors de l\'ouverture du chat: $e', style: GoogleFonts.inter()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _callDriver(BuildContext context) async {
    final phone = driver.phone;
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Numéro de téléphone non disponible', style: GoogleFonts.inter()),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    Navigator.pop(context);
    
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Impossible d\'ouvrir l\'application téléphone', style: GoogleFonts.inter()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
