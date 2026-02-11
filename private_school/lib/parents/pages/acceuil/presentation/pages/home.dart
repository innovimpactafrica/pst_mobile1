import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:private_school/chauffeurs/pages/reports/presentation/widgets/report_problem_modal.dart';
import 'package:private_school/core/utils/app_colors.dart';
import 'package:private_school/core/utils/app_constants.dart';
import 'package:private_school/parents/pages/acceuil/domain/bloc/home_bloc.dart';
import 'package:private_school/parents/pages/acceuil/domain/bloc/home_event.dart';
import 'package:private_school/parents/pages/acceuil/domain/bloc/home_state.dart';
import 'package:private_school/parents/pages/authentification/domain/bloc/auth_bloc.dart';
import 'package:private_school/parents/pages/authentification/domain/bloc/auth_event.dart';
import 'package:private_school/parents/pages/authentification/domain/bloc/auth_state.dart';
import 'package:private_school/parents/pages/trajets/data/models/trip_model.dart';
import 'package:private_school/parents/pages/trajets/data/repositories/trip_repository.dart';
import 'package:private_school/parents/pages/trajets/presentation/widgets/trip_card_widget.dart';
import 'package:private_school/parents/pages/trajets/presentation/pages/trip_detail_page.dart';
import 'package:private_school/parents/pages/trajets/presentation/pages/trip_tracking_page.dart'; // ✅ AJOUTÉ
import 'package:private_school/parents/widgets/main_layout.dart';
//import 'discussion.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              HomeBloc(repository: TripRepository())..add(LoadDriversEvent()),
        ),
        BlocProvider(
          create: (context) => AuthBloc()..add(const LoadCurrentUserEvent()),
        ),
      ],
      child: const HomePageContent(),
    );
  }
}

class HomePageContent extends StatefulWidget {
  const HomePageContent({super.key});

  @override
  State<HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  int _selectedIndex = 0;

  /*void _openDiscussions(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const DiscussionsPage()),
    );
  }*/

  void _openReportProblem(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ReportProblemModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.success,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: Stack(
                    children: [
                      _buildMapBackground(context),
                      Column(
                        children: [
                          _buildSearchBar(),
                          const Spacer(),
                          BlocBuilder<HomeBloc, HomeState>(
                            builder: (context, state) {
                              if (state is HomeLoading) {
                                return const SizedBox(
                                  height: 280,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: AppColors.white,
                                    ),
                                  ),
                                );
                              } else if (state is HomeLoaded) {
                                return _buildTripCardsSection(state.trips);
                              } else if (state is HomeError) {
                                return SizedBox(
                                  height: 280,
                                  child: Center(
                                    child: Text(
                                      state.message,
                                      style: const TextStyle(
                                        color: AppColors.error,
                                      ),
                                    ),
                                  ),
                                );
                              }
                              return const SizedBox(height: 280);
                            },
                          ),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            _buildBottomNavigationBar(),
            _buildFloatingActionButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildMapBackground(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.grey.shade200),
      child: Stack(
        children: [
          Center(
            child: Icon(
              Icons.map_outlined,
              size: AppConstants.iconSizeXXXL + 16,
              color: Colors.grey.shade300,
            ),
          ),
          Positioned(
            top: 150,
            left: MediaQuery.of(context).size.width * 0.4,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary,
                  width: 3,
                ),
              ),
              child: const Icon(
                Icons.location_on,
                color: AppColors.primary,
                size: AppConstants.iconSizeM,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.blackOpacity10,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "search_trip".tr(),
                  hintStyle: GoogleFonts.inter(
                    color: Colors.grey.shade400,
                    fontSize: AppConstants.fontSizeM,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey.shade500,
                    size: 22,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: AppConstants.fontSizeM,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppConstants.spacingL),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppConstants.radiusL),
              boxShadow: [
                BoxShadow(
                  color: AppColors.blackOpacity10,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.tune,
              color: Colors.grey.shade600,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ MODIFIÉ : Afficher la photo de profil depuis l'API
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingXL,
        vertical: AppConstants.spacingXL,
      ),
      decoration: const BoxDecoration(color: AppColors.success),
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          String userName = "user".tr();
          String? userPhoto;

          // ✅ RÉCUPÉRER LE NOM ET LA PHOTO
          if (authState is UserLoaded) {
            userName = authState.user.fullName;
            userPhoto = authState.user.photo;
          } else if (authState is AuthAuthenticated && authState.user != null) {
            userName = authState.user!.fullName;
            userPhoto = authState.user!.photo;
          } else if (authState is AuthLoading) {
            userName = "loading_text".tr();
          } else if (authState is AuthError) {
            userName = "error_text".tr();
          }

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  // ✅ PHOTO DE PROFIL DEPUIS L'API
                  _buildProfileAvatar(userPhoto),
                  
                  const SizedBox(width: AppConstants.spacingL),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppConstants.labelGreeting,
                        style: GoogleFonts.inter(
                          color: AppColors.whiteOpacity20.withValues(alpha: 0.9),
                          fontSize: AppConstants.fontSizeM,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        userName,
                        style: GoogleFonts.inter(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: AppConstants.fontSizeXL,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  GestureDetector(
                    //onTap: () => _openDiscussions(context),
                    child: _buildNotifIconSvg('assets/icons/notif.svg', 1),
                  ),
                  const SizedBox(width: AppConstants.spacingL),
                  _buildNotifIconSvg('assets/icons/Settings.svg', 0),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  /// ✅ NOUVEAU : Widget pour afficher la photo de profil
  Widget _buildProfileAvatar(String? photoUrl) {
    // Pas de photo → Avatar par défaut
    if (photoUrl == null || photoUrl.isEmpty) {
      return CircleAvatar(
        radius: 28,
        backgroundColor: AppColors.white,
        child: ClipOval(
          child: Image.asset(
            'assets/images/1.png',
            width: 56,
            height: 56,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.person,
                size: AppConstants.iconSizeXL,
                color: AppColors.success,
              );
            },
          ),
        ),
      );
    }

    // URL complète (commence par http:// ou https://)
    if (photoUrl.startsWith('http://') || photoUrl.startsWith('https://')) {
      return CircleAvatar(
        radius: 28,
        backgroundColor: AppColors.white,
        backgroundImage: NetworkImage(photoUrl),
        onBackgroundImageError: (exception, stackTrace) {
          debugPrint('⚠️ Erreur chargement photo: $exception');
        },
      );
    }

    // URL relative → Construire l'URL complète
    final fullUrl = 'http://86.106.181.31:3000$photoUrl';
    
    debugPrint('🖼️ [HomePage] Loading profile photo: $fullUrl');

    return CircleAvatar(
      radius: 28,
      backgroundColor: AppColors.white,
      backgroundImage: NetworkImage(fullUrl),
      onBackgroundImageError: (exception, stackTrace) {
        debugPrint('⚠️ Erreur chargement photo: $exception');
      },
      // Fallback si l'image ne charge pas
      child: const SizedBox.shrink(),
    );
  }

  Widget _buildNotifIconSvg(String svgPath, int notifCount) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        SizedBox(
          width: 44,
          height: 44,
          child: Center(
            child: SvgPicture.asset(
              svgPath,
              width: 30,
              height: 30,
              colorFilter: const ColorFilter.mode(
                AppColors.white,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
        if (notifCount > 0)
          Positioned(
            right: 2,
            top: 2,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
              ),
              child: Text(
                notifCount.toString(),
                style: const TextStyle(
                  fontSize: AppConstants.fontSizeXS,
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// ✅ MODIFIÉ : Navigation intelligente selon si le trajet est réservé
  Widget _buildTripCardsSection(List<TripModel> trips) {
    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingM),
        itemCount: trips.length,
        itemBuilder: (context, index) {
          final trip = trips[index];
          
          return Padding(
            padding: EdgeInsets.only(
              right: index < trips.length - 1 ? AppConstants.spacingL : 0,
            ),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.85,
              child: TripCardWidget(
                trip: trip,
                onTap: () => _handleTripTap(context, trip),
              ),
            ),
          );
        },
      ),
    );
  }

  /// ✅ NOUVEAU : Gestion intelligente de la navigation
  void _handleTripTap(BuildContext context, TripModel trip) {
    final homeBloc = context.read<HomeBloc>();
    final isReserved = homeBloc.isTripReserved(trip.id);

    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('🏠 [HomePage] TAP SUR CARD');
    debugPrint('   Trip ID: ${trip.id}');
    debugPrint('   Destination: ${trip.destination}');
    debugPrint('   Status: ${trip.status}');
    debugPrint('   Est réservé: $isReserved');
    debugPrint('   → ${isReserved ? "TripTrackingPage" : "TripDetailPage"}');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    if (isReserved) {
      // ✅ Trajet RÉSERVÉ → Aller au suivi
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TripTrackingPage(trip: trip),
        ),
      );
    } else {
      // ✅ Trajet DISPONIBLE → Aller aux détails/réservation
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TripDetailPage(trip: trip),
        ),
      );
    }
  }

  Widget _buildBottomNavigationBar() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.blackOpacity10,
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              icon: Icons.home_rounded,
              label: AppConstants.labelHome,
              index: 0,
            ),
            _buildNavItem(
              icon: Icons.people_rounded,
              label: 'children'.tr(),
              index: 1,
            ),
            _buildNavItem(
              icon: Icons.route_rounded,
              label: 'my_trips'.tr(),
              index: 2,
            ),
            _buildNavItem(
              icon: Icons.groups_rounded,
              label: 'groups'.tr(),
              index: 3,
            ),
            _buildNavItem(
              icon: Icons.person_rounded,
              label: AppConstants.labelProfile,
              index: 4,
            ),
          ],
        ),
      ),
    );
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const MainLayout(initialIndex: 1),
        ),
      );
    }
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onBottomNavTap(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingS),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.success : Colors.grey.shade500,
              size: 26,
            ),
            const SizedBox(height: AppConstants.spacingXS),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? AppColors.success : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return Positioned(
      right: AppConstants.spacingXL,
      bottom: 90,
      child: FloatingActionButton(
        onPressed: () => _openReportProblem(context),
        backgroundColor: AppColors.success,
        elevation: 4,
        child: SvgPicture.asset(
          'assets/icons/13.svg',
          width: 28,
          height: 28,
          colorFilter: const ColorFilter.mode(
            AppColors.white,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
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
      canvas.drawLine(
        Offset(size.width / 2, startY),
        Offset(size.width / 2, startY + dashHeight),
        paint,
      );
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}