import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:private_school/chauffeurs/pages/profil/presentation/widgets/language_bottom_sheet.dart';
import 'package:private_school/parents/pages/reports/presentation/pages/reports_page.dart';
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
import 'invite_friends_page.dart';

/// Profile page for parent users
/// ✅ Design exact Figma: Carte profil AU-DESSUS du header vert
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
      body: BlocListener<ProfilBloc, ProfilState>(
        listener: (context, state) {
          if (state is LogoutSuccess) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/parent/connexion', // ✅ Correspond exactement à ton main.dart
              (route) => false,
            );
          } else if (state is ProfilError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: Stack(
          children: [
            // ✅ BACKGROUND VERT (sous la carte)
            Container(
              width: double.infinity,
              height: 180, // Hauteur du header vert
              decoration: const BoxDecoration(
                color: AppColors.success,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(AppConstants.radiusXXL - 6),
                  bottomRight: Radius.circular(AppConstants.radiusXXL - 6),
                ),
              ),
            ),

            // ✅ CONTENU SCROLLABLE
            SafeArea(
              child: Column(
                children: [
                  // Titre "Mon compte" dans le header vert
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppConstants.spacingXL + 4,
                    ),
                    child: Text(
                      'my_account'.tr(),
                      style: GoogleFonts.inter(
                        fontSize: AppConstants.fontSizeXXL,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textWhite,
                      ),
                    ),
                  ),

                  const SizedBox(height: AppConstants.spacingM),

                  // ✅ CARTE PROFIL (posée AU-DESSUS du header vert)
                  BlocBuilder<ProfilBloc, ProfilState>(
                    builder: (context, state) {
                      if (state is ProfilLoading) {
                        return _buildLoadingCard();
                      }

                      if (state is ProfilLoaded) {
                        return _buildProfileCard(context, state.user);
                      }

                      // État d'erreur ou initial
                      return _buildPlaceholderCard(context);
                    },
                  ),

                  const SizedBox(height: AppConstants.spacingXL),

                  // ✅ MENU SECTION (fond blanc)
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
                                'general'.tr(),
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
                              title: 'personal_info'.tr(),
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
                              title: 'notifications'.tr(),
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
                              title: 'payment_history'.tr(),
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
                              title: 'my_reports'.tr(),
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
                              title: 'invite_friends'.tr(),
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
                              title: 'language'.tr(),
                              iconColor: AppColors.success,
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

                            const SizedBox(height: AppConstants.spacingXL + 4),

                            // Logout button
                            MenuItemWidget(
                              icon: Icons.logout,
                              title: 'disconnect'.tr(),
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
          ],
        ),
      ),
    );
  }

  /// ✅ Carte de profil avec photo, nom et bouton edit
  Widget _buildProfileCard(BuildContext context, dynamic user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingXL + 4),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spacingXL + 4),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusXL),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha:0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Photo de profil
            _buildProfileAvatar(user.photo),
            const SizedBox(width: AppConstants.spacingXL),
            
            // Nom et rôle
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
                    'Parent',
                    style: GoogleFonts.inter(
                      fontSize: AppConstants.fontSizeM,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            
            // Bouton Edit
            GestureDetector(
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.success,
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.edit_outlined,
                  color: AppColors.success,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Carte de chargement
  Widget _buildLoadingCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingXL + 4),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spacingXL + 4),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusXL),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha:0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.success),
        ),
      ),
    );
  }

  /// Carte placeholder
  Widget _buildPlaceholderCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingXL + 4),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spacingXL + 4),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusXL),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha:0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.grey200,
              child: Icon(
                Icons.person,
                size: 40,
                color: AppColors.grey600,
              ),
            ),
            const SizedBox(width: AppConstants.spacingXL),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'user'.tr(),
                    style: GoogleFonts.inter(
                      fontSize: AppConstants.fontSizeXL,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingXS),
                  Text(
                    'Parent',
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

  /// ✅ Avatar de profil depuis l'URL de l'API
  Widget _buildProfileAvatar(String? photoUrl) {
    // Cas 1 : Pas de photo
    if (photoUrl == null || photoUrl.isEmpty) {
      return CircleAvatar(
        radius: 40,
        backgroundColor: AppColors.grey200,
        child: Icon(
          Icons.person,
          size: 45,
          color: AppColors.grey600,
        ),
      );
    }

    // Cas 2 : URL complète (http:// ou https://)
    if (photoUrl.startsWith('http://') || photoUrl.startsWith('https://')) {
      return CircleAvatar(
        radius: 40,
        backgroundColor: AppColors.grey200,
        backgroundImage: NetworkImage(photoUrl),
        onBackgroundImageError: (exception, stackTrace) {
          debugPrint('⚠️ [ProfilPage] Erreur chargement photo: $exception');
        },
      );
    }

    // Cas 3 : URL relative
    final fullUrl = 'http://86.106.181.31:3000$photoUrl';
    return CircleAvatar(
      radius: 40,
      backgroundColor: AppColors.grey200,
      backgroundImage: NetworkImage(fullUrl),
      onBackgroundImageError: (exception, stackTrace) {
        debugPrint('⚠️ [ProfilPage] Erreur chargement photo: $exception');
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text('logout_title'.tr(), style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
      content: Text('logout_confirm'.tr()),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext), // Ferme juste le dialogue
          child: Text('cancel'.tr(), style: GoogleFonts.inter(color: AppColors.textSecondary)),
        ),
        TextButton(
          onPressed: () {
            // 1. On ferme le dialogue
            Navigator.pop(dialogContext);
            
            // 2. On déclenche l'événement de déconnexion dans le BLoC
            // C'est ce qui va appeler UserService.logout()
            context.read<ProfilBloc>().add(LogoutEvent());
          },
          child: Text(
            'disconnect'.tr(),
            style: GoogleFonts.inter(color: AppColors.error, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
}
}