import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../utils/app_colors.dart';
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

class ProfilPage extends StatelessWidget {
  const ProfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfilBloc(repository: UserRepository())
        ..add(LoadUserProfileEvent()),
      child: const ProfilPageContent(),
    );
  }
}

class ProfilPageContent extends StatelessWidget {
  const ProfilPageContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: BlocListener<ProfilBloc, ProfilState>(
          listener: (context, state) {
            if (state is LogoutSuccess) {
              // Navigation vers la page de connexion
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/login',
                    (route) => false,
              );
            }
          },
          child: Column(
            children: [
              // HEADER VERT
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Mon compte',
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // CARTE PROFIL
              BlocBuilder<ProfilBloc, ProfilState>(
                builder: (context, state) {
                  if (state is ProfilLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (state is ProfilLoaded) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        padding: const EdgeInsets.all(20),
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
                            // PHOTO DE PROFIL
                            Stack(
                              children: [
                                CircleAvatar(
                                  radius: 35,
                                  backgroundColor: Colors.grey.shade200,
                                  backgroundImage: AssetImage(
                                    'assets/images/${state.user.photo}',
                                  ),
                                  onBackgroundImageError: (_, __) {},
                                  child: Icon(
                                    Icons.person,
                                    size: 40,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                // ICÔNE ÉDITER
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
                                        color: AppColors.primaryBlue,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.edit,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 16),
                            // INFOS
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    state.user.fullName,
                                    style: GoogleFonts.inter(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    state.user.role,
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
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

              const SizedBox(height: 20),

              // SECTION GÉNÉRAL
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            'Général',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // MENU ITEMS
                        MenuItemWidget(
                          icon: Icons.person_outline,
                          title: 'Informations personnelles',
                          iconColor: AppColors.primaryGreen,
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
                          iconColor: AppColors.primaryGreen,
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
                          iconColor: AppColors.primaryGreen,
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
                          iconColor: AppColors.primaryGreen,
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
                          iconColor: AppColors.primaryGreen,
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
                          iconColor: AppColors.primaryGreen,
                          trailing: Text(
                            'Français',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          onTap: () {
                            // TODO: Ouvrir sélecteur de langue
                          },
                        ),

                        const SizedBox(height: 20),

                        // BOUTON DÉCONNEXION
                        MenuItemWidget(
                          icon: Icons.logout,
                          title: 'Se déconnecter',
                          iconColor: Colors.red,
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
              style: GoogleFonts.inter(color: Colors.grey.shade600),
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
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}