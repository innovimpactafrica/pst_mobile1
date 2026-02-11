import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:private_school/chauffeurs/pages/dashboard/presentation/pages/notifications_page.dart';
import 'package:private_school/chauffeurs/pages/logout/presentation/widgets/logout_bottom_sheet.dart';
import 'package:private_school/chauffeurs/pages/reports/presentation/pages/reports_page.dart';
import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_constants.dart';
import '../../../../../core/utils/image_url_helper.dart';
import '../../domain/bloc/driver_profile_bloc.dart';
import '../../domain/bloc/driver_profile_event.dart';
import '../../domain/bloc/driver_profile_state.dart';
import 'personal_info_page.dart';
import 'vehicle_info_page.dart';
import 'documents_page.dart';
import 'payment_history_page.dart';
import '../../../dashboard/domain/bloc/notification_bloc.dart';
import '../../../dashboard/domain/bloc/notification_state.dart';
import '../widgets/language_bottom_sheet.dart'; // 🆕 Import du modal de langue

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
      backgroundColor: AppColors.primary,
    body: SafeArea(
  child: Stack(
    children: [
      // 1️⃣ FOND VIOLET (en haut)
      Column(
        children: [
          Container(
            height: 140, // Hauteur de la partie violette
            color: AppColors.primary,
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacingXL + 4,
              vertical: AppConstants.spacingXL,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'my_account'.tr(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textWhite,
                ),
              ),
            ),
          ),

          // 2️⃣ FOND BLANC (en bas)
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
                            'loading_error'.tr(),
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
                            child: Text('retry'.tr()),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is DriverProfileLoaded) {
                    final profile = state.profile;

                    return SingleChildScrollView(
                      padding: const EdgeInsets.only(
                        top: 80, 
                        left: AppConstants.spacingXL + 4,
                        right: AppConstants.spacingXL + 4,
                        bottom: AppConstants.spacingXL + 4,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: AppConstants.spacingXXL),

                          // "Général" section title
                          Text(
                            'general'.tr(),
                            style: GoogleFonts.inter(
                              fontSize: AppConstants.fontSizeM,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),

                          const SizedBox(height: AppConstants.spacingL),

                          // Menu items (reste du code inchangé)
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
                                  title: 'personal_info'.tr(),
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
                                  title: 'vehicle_info'.tr(),
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
                                  title: 'documents'.tr(),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            DocumentsPage(profile: profile),
                                      ),
                                    );
                                  },
                                ),
                                _buildDivider(),
                                _buildNotificationMenuItem(),
                                _buildDivider(),
                                _buildMenuItem(
                                  icon: Icons.payment_outlined,
                                  title: 'payment_history'.tr(),
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
                                  title: 'my_reports'.tr(),
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
                                  title: 'language'.tr(),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        context.locale.languageCode == 'fr'
                                            ? 'language_french'.tr()
                                            : 'language_english'.tr(),
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
                                    showLanguageBottomSheet(context);
                                  },
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: AppConstants.spacingXXL),

                          // Logout button
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(
                                AppConstants.radiusXL - 8,
                              ),
                            ),
                            child: _buildMenuItem(
                              icon: Icons.logout,
                              title: 'logout'.tr(),
                              iconColor: AppColors.error,
                              showChevron: false,
                              onTap: () {
                                showLogoutBottomSheet(context);
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

      // 3️⃣ ✨ CARD BLANC FLOTTANT (superposé)
      Positioned(
        top: 100, // Position depuis le haut
        left: AppConstants.spacingXL + 4,
        right: AppConstants.spacingXL + 4,
        child: BlocBuilder<DriverProfileBloc, DriverProfileState>(
          builder: (context, state) {
            if (state is DriverProfileLoaded) {
              final profile = state.profile;

              return Container(
                padding: const EdgeInsets.all(AppConstants.spacingXL),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(
                    AppConstants.radiusXL - 8,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Driver profile photo
                    CircleAvatar(
                      radius: 32,
                      backgroundColor:
                          AppColors.primary.withValues(alpha: 0.1),
                      backgroundImage: profile.photo != null &&
                              profile.photo!.isNotEmpty
                          ? NetworkImage(
                              ImageUrlHelper.getFullImageUrl(
                                profile.photo!,
                              ),
                            )
                          : null,
                      child: profile.photo == null || profile.photo!.isEmpty
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile.fullName,
                            style: GoogleFonts.inter(
                              fontSize: AppConstants.fontSizeXL,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: AppConstants.spacingXS),
                          Text(
                            'role_driver'.tr(),
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
                              value: context.read<DriverProfileBloc>(),
                              child: PersonalInfoPage(profile: profile),
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
              );
            }

            return const SizedBox();
          },
        ),
      ),
    ],
  ),
),
    );
  }

  // Bouton Notifications avec badge
  Widget _buildNotificationMenuItem() {
    return BlocBuilder<NotificationBloc, NotificationState>(
      builder: (context, state) {
        int unreadCount = 0;

        if (state is NotificationLoaded) {
          unreadCount = state.unreadCount;
        }

        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const NotificationsPage(),
              ),
            );
          },
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
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.notifications_outlined,
                    color: AppColors.success,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppConstants.spacingL),

                // Title
                Expanded(
                  child: Text(
                    'notifications'.tr(), // 🆕 Traduction
                    style: GoogleFonts.inter(
                      fontSize: AppConstants.fontSizeL,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),

                // Badge + Chevron
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Badge rouge si notifications non lues
                    if (unreadCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(
                            AppConstants.radiusL,
                          ),
                        ),
                        child: Text(
                          unreadCount > 9 ? '9+' : '$unreadCount',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: AppConstants.fontSizeS,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.chevron_right,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
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

  
}