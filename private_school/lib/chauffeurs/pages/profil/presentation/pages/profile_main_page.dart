import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_constants.dart';
import '../../domain/bloc/driver_profile_bloc.dart';
import '../../domain/bloc/driver_profile_event.dart';
import '../../domain/bloc/driver_profile_state.dart';
import 'personal_info_page.dart';
import 'vehicle_info_page.dart';
import 'documents_page.dart';
import 'notifications_page.dart';
import 'payment_history_page.dart';
import 'reports_page.dart';

/// Driver profile main page
/// Displays driver information and menu options
/// Design matches Figma mockup
class ProfileMainPage extends StatefulWidget {
  const ProfileMainPage({super.key});

  @override
  State<ProfileMainPage> createState() => _ProfileMainPageState();
}

class _ProfileMainPageState extends State<ProfileMainPage> {
  @override
  void initState() {
    super.initState();
    context.read<DriverProfileBloc>().add(LoadDriverProfileEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary, // Purple header background
      body: SafeArea(
        child: Column(
          children: [
            // Purple header with "Mon compte"
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacingXL + 4,
                vertical: AppConstants.spacingXL,
              ),
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Mon compte',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textWhite,
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppConstants.spacingXL + 4),

            // White content area
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppConstants.radiusXXL - 6),
                    topRight: Radius.circular(AppConstants.radiusXXL - 6),
                  ),
                ),
                child: BlocBuilder<DriverProfileBloc, DriverProfileState>(
                  builder: (context, state) {
                    if (state is DriverProfileLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      );
                    }

                    if (state is DriverProfileError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: AppColors.error,
                              size: 64,
                            ),
                            const SizedBox(height: AppConstants.spacingL),
                            Text(
                              'Erreur de chargement',
                              style: GoogleFonts.inter(
                                fontSize: AppConstants.fontSizeXL,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: AppConstants.spacingS),
                            Text(
                              state.message,
                              style: GoogleFonts.inter(
                                color: AppColors.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppConstants.spacingXL),
                            ElevatedButton(
                              onPressed: () {
                                context
                                    .read<DriverProfileBloc>()
                                    .add(LoadDriverProfileEvent());
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                              ),
                              child: const Text('Réessayer'),
                            ),
                          ],
                        ),
                      );
                    }

                    if (state is DriverProfileLoaded) {
                      final profile = state.profile;

                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(
                          AppConstants.spacingXL + 4,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Profile card with driver photo and edit button
                            Container(
                              padding: const EdgeInsets.all(
                                AppConstants.spacingXL,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(
                                  AppConstants.radiusXL - 8,
                                ),
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
                                  // Driver profile photo
                                  CircleAvatar(
                                    radius: 32,
                                    backgroundColor: AppColors.primary
                                        .withValues(alpha: 0.1),
                                    backgroundImage: profile.photo != null &&
                                            profile.photo!.isNotEmpty
                                        ? NetworkImage(profile.photo!)
                                        : null,
                                    child: profile.photo == null ||
                                            profile.photo!.isEmpty
                                        ? Text(
                                            profile.initials,
                                            style: GoogleFonts.inter(
                                              fontSize: 24,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.primary,
                                            ),
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: AppConstants.spacingXL),

                                  // Driver name and role
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          profile.fullName,
                                          style: GoogleFonts.inter(
                                            fontSize: AppConstants.fontSizeXL,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: AppConstants.spacingXS,
                                        ),
                                        Text(
                                          'Chauffeur',
                                          style: GoogleFonts.inter(
                                            fontSize: AppConstants.fontSizeM,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Edit button
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => BlocProvider.value(
                                            value: context
                                                .read<DriverProfileBloc>(),
                                            child: PersonalInfoPage(
                                              profile: profile,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppColors.backgroundLight,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.edit_outlined,
                                        color: AppColors.textSecondary,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: AppConstants.spacingXXL),

                            // "Général" section title
                            Text(
                              'Général',
                              style: GoogleFonts.inter(
                                fontSize: AppConstants.fontSizeM,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),

                            const SizedBox(height: AppConstants.spacingL),

                            // Menu items in white container
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(
                                  AppConstants.radiusXL - 8,
                                ),
                              ),
                              child: Column(
                                children: [
                                  _buildMenuItem(
                                    icon: Icons.person_outline,
                                    title: 'Informations personnelles',
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => BlocProvider.value(
                                            value: context
                                                .read<DriverProfileBloc>(),
                                            child: PersonalInfoPage(
                                              profile: profile,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  _buildDivider(),
                                  _buildMenuItem(
                                    icon: Icons.directions_car_outlined,
                                    title: 'Informations du véhicule',
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => VehicleInfoPage(
                                            profile: profile,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  _buildDivider(),
                                  _buildMenuItem(
                                    icon: Icons.folder_outlined,
                                    title: 'Documents',
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const DocumentsPage(),
                                        ),
                                      );
                                    },
                                  ),
                                  _buildDivider(),
                                  _buildMenuItem(
                                    icon: Icons.notifications_outlined,
                                    title: 'Notifications',
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const NotificationsPage(),
                                        ),
                                      );
                                    },
                                  ),
                                  _buildDivider(),
                                  _buildMenuItem(
                                    icon: Icons.payment_outlined,
                                    title: 'Historiques des paiements',
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const PaymentHistoryPage(),
                                        ),
                                      );
                                    },
                                  ),
                                  _buildDivider(),
                                  _buildMenuItem(
                                    icon: Icons.warning_amber_outlined,
                                    title: 'Mes signalements',
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const ReportsPage(),
                                        ),
                                      );
                                    },
                                  ),
                                  _buildDivider(),
                                  _buildMenuItem(
                                    icon: Icons.language,
                                    title: 'Langue',
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Français',
                                          style: GoogleFonts.inter(
                                            fontSize: AppConstants.fontSizeM,
                                            color: AppColors.textGrey,
                                          ),
                                        ),
                                        const SizedBox(
                                          width: AppConstants.spacingXS,
                                        ),
                                        const Icon(
                                          Icons.chevron_right,
                                          color: AppColors.textSecondary,
                                          size: 20,
                                        ),
                                      ],
                                    ),
                                    onTap: () {
                                      // Language selector to be implemented
                                    },
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: AppConstants.spacingXXL),

                            // Logout button (separate container)
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(
                                  AppConstants.radiusXL - 8,
                                ),
                              ),
                              child: _buildMenuItem(
                                icon: Icons.logout,
                                title: 'Se déconnecter',
                                iconColor: AppColors.error,
                                showChevron: false,
                                onTap: () {
                                  _showLogoutDialog(context);
                                },
                              ),
                            ),

                            const SizedBox(height: AppConstants.spacingXXL),
                          ],
                        ),
                      );
                    }

                    return const SizedBox();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    Color? iconColor,
    Widget? trailing,
    bool showChevron = true,
    required VoidCallback onTap,
  }) {
    final effectiveIconColor = iconColor ?? AppColors.success;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.radiusL),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingXL,
          vertical: AppConstants.spacingL,
        ),
        child: Row(
          children: [
            // Icon with colored background
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: effectiveIconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: effectiveIconColor,
                size: 20,
              ),
            ),
            const SizedBox(width: AppConstants.spacingL),

            // Title
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: AppConstants.fontSizeL,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),

            // Trailing (chevron or custom)
            if (showChevron)
              trailing ??
                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 68),
      child: Divider(
        height: 1,
        thickness: 1,
        color: AppColors.grey200,
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'Déconnexion',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Êtes-vous sûr de vouloir vous déconnecter ?',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Annuler',
              style: GoogleFonts.inter(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              // TODO: Implement logout logic
            },
            child: Text(
              'Déconnexion',
              style: GoogleFonts.inter(
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