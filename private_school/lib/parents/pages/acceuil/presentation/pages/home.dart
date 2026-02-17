import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:private_school/core/utils/app_colors.dart';
import 'package:private_school/core/utils/app_constants.dart';
import 'package:private_school/parents/pages/acceuil/domain/bloc/home_bloc.dart';
import 'package:private_school/parents/pages/acceuil/domain/bloc/home_state.dart';
import 'package:private_school/parents/pages/authentification/domain/bloc/auth_bloc.dart';
import 'package:private_school/parents/pages/authentification/domain/bloc/auth_event.dart';
import 'package:private_school/parents/pages/authentification/domain/bloc/auth_state.dart';
import 'package:private_school/parents/pages/profil/domain/bloc/profil_bloc.dart';
import 'package:private_school/parents/pages/profil/domain/bloc/profil_event.dart';
import 'package:private_school/parents/pages/profil/data/repositories/user_repository.dart';
import 'package:private_school/parents/pages/profil/presentation/pages/notifications_page.dart';
import 'package:private_school/parents/pages/profil/presentation/pages/personal_info_page.dart';
import 'package:private_school/parents/pages/reports/presentation/widgets/report_problem_modal.dart';
import 'package:private_school/parents/pages/trajets/data/models/trip_model.dart';
import 'package:private_school/parents/pages/trajets/presentation/widgets/trip_card_widget.dart';
import 'package:private_school/parents/pages/trajets/presentation/pages/trip_detail_page.dart';
import 'package:private_school/parents/pages/trajets/presentation/pages/trip_tracking_page.dart';
import 'package:private_school/parents/pages/acceuil/presentation/pages/discussion.dart';
import 'package:private_school/parents/widgets/main_layout.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  LatLng? _homeLocation;

  @override
  void initState() {
    super.initState();
    _loadHomeAddress();
  }

  void _loadHomeAddress() async {
    final authState = context.read<AuthBloc>().state;
    String? address;
    
    if (authState is AuthAuthenticated && authState.user != null) {
      address = authState.user!.address;
    } else if (authState is UserLoaded) {
      address = authState.user.address;
    }
    
    if (address != null && address.isNotEmpty) {
      // Géocoder l'adresse pour obtenir les coordonnées
      final coords = await _geocodeAddress(address);
      if (coords != null) {
        setState(() {
          _homeLocation = coords;
        });
      } else {
        setState(() {
          _homeLocation = const LatLng(14.6937, -17.4441); // Dakar par défaut
        });
      }
    } else {
      setState(() {
        _homeLocation = const LatLng(14.6937, -17.4441);
      });
    }
  }
  
  Future<LatLng?> _geocodeAddress(String address) async {
    try {
      final locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        return LatLng(locations.first.latitude, locations.first.longitude);
      }
    } catch (e) {
      debugPrint('❌ Erreur géocodage: $e');
    }
    return null;
  }

  @override
@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.white, // ← FOND BLANC
    body: SafeArea(
      child: Stack(
        children: [
          Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: Container(
                  color: AppColors.white, 
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
                                      color: AppColors.success,
                                    ),
                                  ),
                                );
                              } else if (state is HomeLoaded) {
                                return _buildTripCardsSection(
                                  context,
                                  state.trips,
                                );
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
    if (_homeLocation == null) {
      return Container(
        decoration: BoxDecoration(color: Colors.grey.shade200),
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: _homeLocation!,
        zoom: 14,
      ),
      onMapCreated: (controller) {
        // Controller stocké mais non utilisé pour l'instant
      },
      markers: {
        Marker(
          markerId: const MarkerId('home'),
          position: _homeLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueViolet,
          ),
          infoWindow: const InfoWindow(
            title: 'Mon domicile',
          ),
        ),
      },
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
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
            child: Icon(Icons.tune, color: Colors.grey.shade600, size: 22),
          ),
        ],
      ),
    );
  }

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

          if (authState is UserLoaded) {
            userName = authState.user.fullName;
            userPhoto = authState.user.photo;
          } else if (authState is AuthAuthenticated) {
            userName = authState.user?.fullName ?? "user".tr();
            userPhoto = authState.user?.photo;
          }

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _buildProfileAvatar(userPhoto),
                  const SizedBox(width: AppConstants.spacingL),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppConstants.labelGreeting,
                        style: GoogleFonts.inter(
                          color: AppColors.white.withValues(alpha: 0.7),
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
                  _buildNotifIconSvg('assets/icons/notif.svg', 1, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const DiscussionsPage()),
                    );
                  }),
                  const SizedBox(width: AppConstants.spacingL),
                  _buildNotifIconSvg('assets/icons/Settings.svg', 0, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const NotificationsPage()),
                    );
                  }),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  // ✅ VOTRE CODE DE PHOTO QUI FONCTIONNE
  Widget _buildProfileAvatar(String? photoUrl) {
    debugPrint('🖼️ Photo URL affichée dans le Header: $photoUrl');

    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BlocProvider(
              create: (context) => ProfilBloc(
                repository: UserRepository(),
              )..add(LoadUserProfileEvent()),
              child: const PersonalInfoPage(),
            ),
          ),
        );

        if (!mounted) return;
        context.read<AuthBloc>().add(const LoadCurrentUserEvent());
      },
      child: CircleAvatar(
        radius: 28,
        backgroundColor: AppColors.white,
        child: ClipOval(
          child: (photoUrl == null || photoUrl.isEmpty)
              ? const Icon(
                  Icons.person,
                  size: 35,
                  color: AppColors.success,
                )
              : Image.network(
                  photoUrl,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    debugPrint('❌ Erreur affichage image: $error');
                    return const Icon(Icons.person,
                        size: 35, color: AppColors.success);
                  },
                ),
        ),
      ),
    );
  }

  Widget _buildNotifIconSvg(
      String svgPath, int notifCount, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Stack(
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
      ),
    );
  }

  Widget _buildTripCardsSection(BuildContext context, List<TripModel> trips) {
    if (trips.isEmpty) {
      return const SizedBox(
        height: 280,
        child: Center(
          child: Text(
            'Aucun trajet disponible',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    // ✅ LOG pour vérifier les données
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('📊 [HomePage] TRAJETS CHARGÉS: ${trips.length}');
    for (var trip in trips) {
      debugPrint('   Trajet ${trip.id}:');
      debugPrint('      Passagers: ${trip.passengers.length}');
      debugPrint('      Places totales: ${trip.totalSeats}');
      debugPrint('      Destination: ${trip.destination}');
    }
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingM),
        itemCount: trips.length,
        itemBuilder: (context, index) {
          final trip = trips[index];
          final homeBloc = context.read<HomeBloc>();
          final isReserved = homeBloc.isTripReserved(trip.id);

          return Padding(
            padding: EdgeInsets.only(
              right: index < trips.length - 1 ? AppConstants.spacingL : 0,
            ),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.85,
              child: TripCardWidget(
                trip: trip,
                isReserved: isReserved,
                onTap: () => _handleTripTap(context, trip, isReserved),
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleTripTap(BuildContext context, TripModel trip, bool isReserved) {
    if (isReserved) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => TripTrackingPage(trip: trip)),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => TripDetailPage(trip: trip)),
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
                index: 0),
            _buildNavItem(
                icon: Icons.people_rounded, label: 'children'.tr(), index: 1),
            _buildNavItem(
                icon: Icons.route_rounded, label: 'my_trips'.tr(), index: 2),
            _buildNavItem(
                icon: Icons.groups_rounded, label: 'groups'.tr(), index: 3),
            _buildNavItem(
                icon: Icons.person_rounded,
                label: AppConstants.labelProfile,
                index: 4),
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
        MaterialPageRoute(builder: (_) => const MainLayout(initialIndex: 1)),
      );
    }
  }

  Widget _buildNavItem(
      {required IconData icon, required String label, required int index}) {
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
          colorFilter:
              const ColorFilter.mode(AppColors.white, BlendMode.srcIn),
        ),
      ),
    );
  }

  void _openReportProblem(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ReportProblemModal(),
    );
  }
}