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
import 'package:private_school/parents/pages/acceuil/domain/bloc/home_event.dart';
import 'package:private_school/parents/pages/acceuil/domain/bloc/home_state.dart';
import 'package:private_school/parents/pages/acceuil/domain/bloc/unread_messages_bloc.dart';
import 'package:private_school/parents/pages/acceuil/data/repositories/messaging_repository.dart';
import 'package:private_school/parents/pages/profil/domain/bloc/unread_notifications_bloc.dart';
import 'package:private_school/parents/pages/profil/data/repositories/notifications_repository.dart';
import 'package:private_school/parents/pages/acceuil/data/services/unified_notification_service.dart';
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
import 'package:private_school/parents/pages/acceuil/presentation/widgets/trip_filter_modal.dart';
import 'package:private_school/parents/widgets/main_layout.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => UnreadMessagesBloc(repository: MessagingRepository())
            ..add(LoadUnreadCountEvent()),
        ),
        BlocProvider(
          create: (context) => UnreadNotificationsBloc(repository: NotificationRepository())
            ..add(LoadUnreadNotificationsCountEvent()),
        ),
      ],
      child: const _HomePageContent(),
    );
  }
}

class _HomePageContent extends StatefulWidget {
  const _HomePageContent();

  @override
  State<_HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<_HomePageContent> with WidgetsBindingObserver {
  int _selectedIndex = 0;
  LatLng? _homeLocation;
  final UnifiedNotificationService _notificationService = UnifiedNotificationService();
  final TextEditingController _searchController = TextEditingController();
  TripFilters? _currentFilters;

@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addObserver(this);
  _loadHomeAddress();
  
  // ✅ Charger immédiatement sans attendre
  WidgetsBinding.instance.addPostFrameCallback((_) {
    context.read<AuthBloc>().add(const LoadCurrentUserEvent());
    context.read<HomeBloc>().add(LoadDriversEvent()); // ← garde ici, c'est correct
    
    _notificationService.registerBlocs(
      messagesBloc: context.read<UnreadMessagesBloc>(),
      notificationsBloc: context.read<UnreadNotificationsBloc>(),
    );
    _notificationService.startPolling();
  });
}

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    _notificationService.dispose();
    super.dispose();
  }

  @override
void didChangeAppLifecycleState(AppLifecycleState state) {
  super.didChangeAppLifecycleState(state);
  
  switch (state) {
    case AppLifecycleState.resumed:
      debugPrint('📱 [HomePage] App resumed');
      // ✅ Refresh uniquement les messages (pas les notifications via Dio)
      context.read<UnreadMessagesBloc>().add(RefreshUnreadCountEvent());
      break;
    case AppLifecycleState.paused:
    case AppLifecycleState.inactive:
      debugPrint('📱 [HomePage] App paused/inactive');
      break;
    case AppLifecycleState.detached:
      _notificationService.dispose();
      break;
    case AppLifecycleState.hidden:
      break;
  }
}

  void _loadHomeAddress() async {
  // ✅ Dakar par défaut IMMÉDIATEMENT
  setState(() {
    _homeLocation = const LatLng(14.6937, -17.4441);
  });

  try {
    final authState = context.read<AuthBloc>().state;
    String? address;

    if (authState is AuthAuthenticated && authState.user != null) {
      address = authState.user!.address;
    }

    debugPrint('📍 Adresse utilisateur: $address');

    if (address != null && address.isNotEmpty) {
      final coords = await _geocodeAddress(address);
      if (coords != null && mounted) {
        setState(() {
          _homeLocation = coords;
        });
        debugPrint('✅ Carte mise à jour: $coords');
      }
    }
  } catch (e) {
    debugPrint('⚠️ Erreur _loadHomeAddress: $e');
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top,
                  left: AppConstants.spacingXL,
                  right: AppConstants.spacingXL,
                  bottom: AppConstants.spacingXL,
                ),
                decoration: const BoxDecoration(color: AppColors.success),
                child: _buildHeaderContent(context),
              ),
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
    debugPrint('🏠 [HomePage] HomeBloc state: ${state.runtimeType}');
    
    if (state is HomeLoading) {
      return const SizedBox.shrink();
    } else if (state is HomeLoaded) {
      if (state.filteredTrips.isEmpty) {
        return SizedBox(
          height: 280,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  state.searchQuery.isEmpty 
                    ? Icons.directions_car_outlined
                    : Icons.search_off, 
                  size: 64, 
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 16),
                Text(
                  state.searchQuery.isEmpty
                    ? 'no_available_trips_home'.tr()
                    : '${'no_search_results'.tr()} "${state.searchQuery}"',
                  style: const TextStyle(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }
      return _buildTripCardsSection(context, state.filteredTrips);
    } else if (state is HomeError) {
      return SizedBox(
        height: 280,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              Text(
                state.message,
                style: const TextStyle(color: AppColors.error),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  context.read<HomeBloc>().add(LoadDriversEvent());
                },
                child: Text('retry_button'.tr()),
              ),
            ],
          ),
        ),
      );
    }
    
    return const SizedBox(
      height: 280,
      child: Center(
        child: CircularProgressIndicator(color: AppColors.success),
      ),
    );
  },
),
                         SizedBox(height: MediaQuery.of(context).padding.bottom + 90),
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
    );
  }

  Widget _buildMapBackground(BuildContext context) {
  final location = _homeLocation ?? const LatLng(14.6937, -17.4441);

  return GoogleMap(
    initialCameraPosition: CameraPosition(
      target: location,
      zoom: 14,
    ),
    onMapCreated: (controller) {},
    markers: {
      Marker(
        markerId: const MarkerId('home'),
        position: location,
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueViolet,
        ),
        infoWindow: InfoWindow(title: 'my_home'.tr()),
      ),
    },
    myLocationEnabled: true,
    myLocationButtonEnabled: false,
    zoomControlsEnabled: false,
    zoomGesturesEnabled: true,
    scrollGesturesEnabled: true,
    tiltGesturesEnabled: true,
    rotateGesturesEnabled: true,
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
                controller: _searchController,
                onChanged: (query) {
                  context.read<HomeBloc>().add(SearchTripsEvent(query));
                },
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
          GestureDetector(
            onTap: () => _showFilterModal(),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _currentFilters?.hasFilters == true
                    ? AppColors.success.withValues(alpha: 0.1)
                    : AppColors.white,
                borderRadius: BorderRadius.circular(AppConstants.radiusL),
                border: _currentFilters?.hasFilters == true
                    ? Border.all(color: AppColors.success, width: 2)
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.blackOpacity10,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      Icons.tune,
                      color: _currentFilters?.hasFilters == true
                          ? AppColors.success
                          : Colors.grey.shade600,
                      size: 22,
                    ),
                  ),
                  if (_currentFilters?.hasFilters == true)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderContent(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
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
                      'hello'.tr(),
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
                BlocBuilder<UnreadMessagesBloc, UnreadMessagesState>(
                  builder: (context, state) {
                    final count = state is UnreadMessagesLoaded ? state.count : 0;
                    debugPrint('💬 [HomePage] Compteur messages: $count');
                    return _buildNotifIconSvg('assets/icons/notif.svg', count, () async {
                      debugPrint('🔄 [HomePage] Ouverture page discussions');
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const DiscussionsPage()),
                      );
                      // Rafraîchir le compteur au retour
                      if (mounted) {
                        debugPrint('🔄 [HomePage] Retour de discussions, refresh compteur');
                        context.read<UnreadMessagesBloc>().add(RefreshUnreadCountEvent());
                        // Vérifier aussi avec le service
                        _notificationService.checkNow();
                      }
                    });
                  },
                ),
                const SizedBox(width: AppConstants.spacingL),
               BlocBuilder<UnreadNotificationsBloc, UnreadNotificationsState>(
  builder: (context, state) {
    final count = state is UnreadNotificationsLoaded ? state.count : 0;
    debugPrint('🔔 [HomePage] Compteur notifications: $count');
    return _buildNotifIconSvg('assets/icons/Settings.svg', count, () async {
      debugPrint('🔄 [HomePage] Ouverture page notifications');
      
      // ✅ Récupérer le bloc AVANT la navigation
      final unreadNotifBloc = context.read<UnreadNotificationsBloc>();
      
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: unreadNotifBloc, // ✅ Passer le bloc récupéré
            child: const NotificationsPage(),
          ),
        ),
      );
      
      // ✅ Refresh au retour
      if (mounted) {
        unreadNotifBloc.add(RefreshUnreadNotificationsCountEvent());
      }
    });
  },
),
              ],
            ),
          ],
        );
      },
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
    debugPrint('🔔 [HomePage] Badge notification: $notifCount');
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
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(
                  minWidth: 20,
                  minHeight: 20,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  notifCount > 99 ? '99+' : notifCount.toString(),
                  style: const TextStyle(
                    fontSize: AppConstants.fontSizeXS,
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTripCardsSection(BuildContext context, List<TripModel> trips) {
    if (trips.isEmpty) {
      return SizedBox(
        height: 280,
        child: Center(
          child: Text(
            'no_available_trips_home'.tr(),
            style: const TextStyle(color: AppColors.textSecondary),
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
  final bottomPadding = MediaQuery.of(context).padding.bottom;
  
  return Positioned(
    left: 0,
    right: 0,
    bottom: 0,
    child: Container(
      padding: EdgeInsets.only(bottom: bottomPadding),
      height: 70 + bottomPadding,
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
          _buildNavItem(icon: Icons.home_rounded, label: AppConstants.labelHome, index: 0),
          _buildNavItem(icon: Icons.people_rounded, label: 'children'.tr(), index: 1),
          _buildNavItem(icon: Icons.route_rounded, label: 'my_trips'.tr(), index: 2),
          _buildNavItem(icon: Icons.groups_rounded, label: 'groups'.tr(), index: 3),
          _buildNavItem(icon: Icons.person_rounded, label: AppConstants.labelProfile, index: 4),
        ],
      ),
    ),
  );
}

  void _onBottomNavTap(int index) {

  if (index == _selectedIndex) return; // Si déjà sur cette page, ne rien faire
  
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(
      builder: (_) => MainLayout(initialIndex: index),
    ),
    (route) => false,
  );
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
  final bottomPadding = MediaQuery.of(context).padding.bottom;
  
  return Positioned(
    right: AppConstants.spacingXL,
    // ✅ 70 (navbar) + padding système + 16 marge
    bottom: 70 + bottomPadding + 16,
    child: FloatingActionButton(
      onPressed: () => _openReportProblem(context),
      backgroundColor: AppColors.success,
      elevation: 4,
      child: SvgPicture.asset(
        'assets/icons/13.svg',
        width: 28,
        height: 28,
        colorFilter: const ColorFilter.mode(AppColors.white, BlendMode.srcIn),
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

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TripFilterModal(
        currentFilters: _currentFilters,
        onApplyFilters: (filters) {
          setState(() {
            _currentFilters = filters;
          });
          context.read<HomeBloc>().add(FilterTripsEvent(filters));
        },
      ),
    );
  }
}