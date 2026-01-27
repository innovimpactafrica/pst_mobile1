import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_constants.dart';
import '../../domain/bloc/profil_bloc.dart';
import '../../domain/bloc/profil_event.dart';
import '../../domain/bloc/profil_state.dart';
import '../../data/repositories/user_repository.dart';
import '../widgets/menu_item_widget.dart';
import 'personal_info_page.dart';
import 'notifications_page.dart';
import 'payment_history_page.dart';
import 'reports_page.dart';
import 'invite_friends_page.dart';

/// Profile page for parent users
/// Displays user information and menu options
class ProfilPage extends StatelessWidget {
  const ProfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ProfilBloc(repository: UserRepository())..add(LoadUserProfileEvent()),
      child: const ProfilPageContent(),
    );
  }
}

class ProfilPageContent extends StatelessWidget {
  const ProfilPageContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocListener<ProfilBloc, ProfilState>(
          listener: (context, state) {
            if (state is LogoutSuccess) {
              // Navigate to login page
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/login',
                (route) => false,
              );
            }
          },
          child: Column(
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: AppConstants.spacingXL + 4,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(AppConstants.radiusXXL - 6),
                    bottomRight: Radius.circular(AppConstants.radiusXXL - 6),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Mon compte',
                      style: GoogleFonts.inter(
                        fontSize: AppConstants.fontSizeXXL,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textWhite,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppConstants.spacingXL + 4),

              // Profile card
              BlocBuilder<ProfilBloc, ProfilState>(
                builder: (context, state) {
                  if (state is ProfilLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  }

                  if (state is ProfilLoaded) {
                    final user = state.user;
                    
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.spacingXL + 4,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(AppConstants.spacingXL + 4),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(AppConstants.radiusXL - 8),
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
                            // Profile photo
                            Stack(
                              children: [
                                CircleAvatar(
                                  radius: 35,
                                  backgroundColor: AppColors.grey200,
                                  backgroundImage: user.photo != null && user.photo!.isNotEmpty
                                      ? AssetImage('assets/images/${user.photo}')
                                      : null,
                                  onBackgroundImageError: (_, __) {},
                                  child: user.photo == null || user.photo!.isEmpty
                                      ? Icon(
                                          Icons.person,
                                          size: 40,
                                          color: AppColors.grey600,
                                        )
                                      : null,
                                ),
                                // Edit icon
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => BlocProvider.value(
                                            value: context.read<ProfilBloc>(),
                                            child: const PersonalInfoPage(),
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppColors.white,
                                          width: 2,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.edit,
                                        color: AppColors.textWhite,
                                        size: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: AppConstants.spacingXL),
                            // User info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.fullName,
                                    style: GoogleFonts.inter(
                                      fontSize: AppConstants.fontSizeXL,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: AppConstants.spacingXS),
                                  Text(
                                    user.role ?? 'Parent',
                                    style: GoogleFonts.inter(
                                      fontSize: AppConstants.fontSizeM,
                                      color: AppColors.textSecondary,
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

                  return const SizedBox.shrink();
                },
              ),

              const SizedBox(height: AppConstants.spacingXL + 4),

              // General section
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(AppConstants.radiusXXL - 6),
                      topRight: Radius.circular(AppConstants.radiusXXL - 6),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: AppConstants.spacingXL + 4),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.spacingXL + 4,
                          ),
                          child: Text(
                            'Général',
                            style: GoogleFonts.inter(
                              fontSize: AppConstants.fontSizeL,
                              fontWeight: FontWeight.w600,
                              color: AppColors.grey700,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppConstants.spacingS),

                        // Menu items
                        MenuItemWidget(
                          icon: Icons.person_outline,
                          title: 'Informations personnelles',
                          iconColor: AppColors.success,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BlocProvider.value(
                                  value: context.read<ProfilBloc>(),
                                  child: const PersonalInfoPage(),
                                ),
                              ),
                            );
                          },
                        ),

                        MenuItemWidget(
                          icon: Icons.notifications_outlined,
                          title: 'Notifications',
                          iconColor: AppColors.success,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const NotificationsPage(),
                              ),
                            );
                          },
                        ),

                        MenuItemWidget(
                          icon: Icons.receipt_long_outlined,
                          title: 'Historiques des paiements',
                          iconColor: AppColors.success,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const PaymentHistoryPage(),
                              ),
                            );
                          },
                        ),

                        MenuItemWidget(
                          icon: Icons.flag_outlined,
                          title: 'Mes signalements',
                          iconColor: AppColors.success,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ReportsPage(),
                              ),
                            );
                          },
                        ),

                        MenuItemWidget(
                          icon: Icons.group_add_outlined,
                          title: 'Inviter des amis',
                          iconColor: AppColors.success,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const InviteFriendsPage(),
                              ),
                            );
                          },
                        ),

                        MenuItemWidget(
                          icon: Icons.language,
                          title: 'Langue',
                          iconColor: AppColors.success,
                          trailing: Text(
                            'Français',
                            style: GoogleFonts.inter(
                              fontSize: AppConstants.fontSizeM,
                              color: AppColors.textGrey,
                            ),
                          ),
                          onTap: () {
                            // Language selector to be implemented
                          },
                        ),

                        const SizedBox(height: AppConstants.spacingXL + 4),

                        // Logout button
                        MenuItemWidget(
                          icon: Icons.logout,
                          title: 'Se déconnecter',
                          iconColor: AppColors.error,
                          showChevron: false,
                          onTap: () {
                            _showLogoutDialog(context);
                          },
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
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
              context.read<ProfilBloc>().add(LogoutEvent());
              Navigator.pop(dialogContext);
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