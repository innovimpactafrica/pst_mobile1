import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:private_school/chauffeurs/pages/profil/data/models/driver_profile_model.dart';
import 'package:private_school/chauffeurs/pages/profil/data/services/driver_profile_service.dart';
import 'package:private_school/chauffeurs/pages/reports/presentation/widgets/report_problem_modal.dart';
import 'package:private_school/chauffeurs/pages/trajets/domain/bloc/trip_bloc.dart';
import 'package:private_school/core/utils/app_colors.dart';
import 'package:private_school/core/utils/app_constants.dart';
import '../../domain/bloc/dashboard_bloc.dart';
import '../../domain/bloc/dashboard_event.dart';
import '../../domain/bloc/dashboard_state.dart';
import '../../domain/bloc/unread_messages_bloc.dart';
import '../../domain/bloc/unread_notifications_bloc.dart';
import '../../data/repositories/messaging_repository.dart';
import '../../data/repositories/notifications_repository.dart';
import '../../data/repositories/dashboard_repository.dart';
import '../../data/services/unified_notification_service.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/trip_filters_modal.dart';
import '../../../trajets/presentation/pages/trip_page.dart';
import '../../../trajets/presentation/widgets/trip_detail_modal.dart';
import '../../../trajets/data/models/trip_model.dart';
import '../../../trajets/presentation/widgets/trip_card_widget.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with WidgetsBindingObserver {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              UnreadMessagesBloc(repository: MessagingRepository())
                ..add(LoadUnreadCountEvent()),
        ),
        BlocProvider(
          create: (context) =>
              UnreadNotificationsBloc(repository: NotificationsRepository())
                ..add(LoadUnreadNotificationsCountEvent()),
        ),
        BlocProvider(
          create: (context) =>
              DashboardBloc(repository: DashboardRepository())
                ..add(LoadDashboardEvent()),
        ),
      ],
      child: const _DashboardPageContent(),
    );
  }
}

class _DashboardPageContent extends StatefulWidget {
  const _DashboardPageContent();

  @override
  State<_DashboardPageContent> createState() => _DashboardPageContentState();
}

class _DashboardPageContentState extends State<_DashboardPageContent>
    with WidgetsBindingObserver {
  DriverProfileModel? _profile;
  bool _isLoadingProfile = true;
  final UnifiedNotificationService _notificationService =
      UnifiedNotificationService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Map<String, dynamic> _filters = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadData();

    // Initialisation du service de  notification
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notificationService.registerBlocs(
        messagesBloc: context.read<UnreadMessagesBloc>(),
        notificationsBloc: context.read<UnreadNotificationsBloc>(),
      );
    });

    _notificationService.startPolling();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _notificationService.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        _notificationService.startPolling();
        context.read<UnreadMessagesBloc>().add(RefreshUnreadCountEvent());
        context.read<UnreadNotificationsBloc>().add(
          RefreshUnreadNotificationsCountEvent(),
        );
        _notificationService.checkNow();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        _notificationService.stopPolling();
        break;
      case AppLifecycleState.detached:
        _notificationService.dispose();
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }

  Future<void> _loadData() async {
    context.read<DashboardBloc>().add(LoadDashboardEvent());
    await _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profileService = DriverProfileService();
      final profile = await profileService.fetchProfile();
      if (mounted) {
        setState(() {
          _profile = profile;
          _isLoadingProfile = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingProfile = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _loadData,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top,
                ),
                child: DashboardHeader(
                  profile: _profile,
                  isLoading: _isLoadingProfile,
                ),
              ),
            ),
            SliverToBoxAdapter(child: _buildSearchBar()),
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.only(top: 8),
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: BlocBuilder<DashboardBloc, DashboardState>(
                  builder: (context, state) {
                    if (state is DashboardLoading) {
                      return _buildLoadingState();
                    }

                    if (state is DashboardError) {
                      return _buildErrorState(state.message);
                    }

                    if (state is DashboardLoaded) {
                      return _buildDashboardContent(state);
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingButton(),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.paddingL,
        0,
        AppConstants.paddingL,
        AppConstants.spacingM,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppConstants.radiusL),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.blackOpacity05,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() => _searchQuery = value);
                },
                decoration: InputDecoration(
                  hintText: 'search_trip'.tr(),
                  hintStyle: TextStyle(
                    color: AppColors.textSecondary.withValues(alpha: 0.5),
                    fontSize: AppConstants.fontSizeM,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppColors.textSecondary.withValues(alpha: 0.5),
                    size: AppConstants.iconSizeM,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.close,
                            size: AppConstants.iconSizeM,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spacingM,
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
                  color: AppColors.blackOpacity05,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: _showFiltersModal,
              icon: const Icon(
                Icons.tune,
                color: AppColors.primary,
                size: AppConstants.iconSizeM,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFiltersModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TripFiltersModal(
        onApplyFilters: (filters) {
          setState(() => _filters = filters);
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Padding(
      padding: EdgeInsets.all(80),
      child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
    );
  }

  Widget _buildErrorState(String message) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacingXXL),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: AppConstants.iconSizeXXXL,
              color: AppColors.error,
            ),
            const SizedBox(height: AppConstants.spacingM),
            Text(
              message,
              style: const TextStyle(
                fontSize: AppConstants.fontSizeL,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacingXXL),
            ElevatedButton(
              onPressed: _loadData,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacingXXL,
                  vertical: AppConstants.paddingM,
                ),
              ),
              child: Text(
                'retry'.tr(),
                style: const TextStyle(color: AppColors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardContent(DashboardLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppConstants.paddingL),
        _buildUpcomingTripsSection(state),
        const SizedBox(height: AppConstants.spacingXXL),
        _buildNotificationsSection(state),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildUpcomingTripsSection(DashboardLoaded state) {
    final upcomingTripsList = state.dashboard.upcomingTripsList;
    final filteredTrips = upcomingTripsList.where((tripData) {
      try {
        final trip = tripData is TripModel
            ? tripData
            : TripModel.fromJson(tripData);

        // Recherche par texte
        if (_searchQuery.isNotEmpty) {
          final query = _searchQuery.toLowerCase();
          final matchesDestination = trip.destination.toLowerCase().contains(
            query,
          );
          final matchesStart = (trip.startLocation ?? '')
              .toLowerCase()
              .contains(query);
          final matchesSchool = trip.schools.any(
            (s) => s.name.toLowerCase().contains(query),
          );

          if (!matchesDestination && !matchesStart && !matchesSchool) {
            return false;
          }
        }

        // Filtre par date
        if (_filters['date'] != null) {
          final filterDate = _filters['date'] as DateTime;
          if (trip.date.year != filterDate.year ||
              trip.date.month != filterDate.month ||
              trip.date.day != filterDate.day) {
            return false;
          }
        }

        // Filtre par heure
        if (_filters['time'] != null) {
          final filterTime = _filters['time'] as TimeOfDay;
          final tripTime = trip.time.split(':');
          if (tripTime.length >= 2) {
            final tripHour = int.tryParse(tripTime[0]) ?? 0;
            if (tripHour != filterTime.hour) {
              return false;
            }
          }
        }

        // Filtre par école
        if (_filters['school'] != null &&
            (_filters['school'] as String).isNotEmpty) {
          final schoolQuery = (_filters['school'] as String).toLowerCase();
          if (!trip.schools.any(
            (s) => s.name.toLowerCase().contains(schoolQuery),
          )) {
            return false;
          }
        }

        // Filtre par statut
        if (_filters['status'] != null && _filters['status'] != 'Tous') {
          final statusFilter = _filters['status'] as String;
          final statusMap = {
            'En attente': 'pending',
            'En cours': 'in_progress',
            'Terminé': 'completed',
          };
          if (trip.status != statusMap[statusFilter]) {
            return false;
          }
        }

        if (trip.status == 'canceled') return false;

        // Trajet ALLER SIMPLE terminé = ne pas afficher
        if (trip.tripType == 'aller' && trip.status == 'completed')
          return false;

        // Trajet RETOUR SIMPLE terminé = ne pas afficher
        if (trip.tripType == 'retour' && trip.status == 'completed')
          return false;

        // Trajet ALLER-RETOUR complètement terminé = ne pas afficher
        if (trip.tripType == 'aller_retour' &&
            trip.status == 'completed' &&
            trip.returnStatus == 'completed')
          return false;

        // Tous les autres cas = afficher
        return true;
      } catch (e) {
        return false;
      }
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingL,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'upcoming_trips'.tr(),
                style: const TextStyle(
                  fontSize: AppConstants.fontSizeL,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TripPage()),
                  );
                },
                child: Text(
                  'view_all'.tr(),
                  style: const TextStyle(
                    fontSize: AppConstants.fontSizeM,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppConstants.spacingL),
        if (filteredTrips.isEmpty)
          Container(
            padding: const EdgeInsets.all(AppConstants.spacingXXL),
            child: Center(
              child: Text(
                _searchQuery.isNotEmpty || _filters.isNotEmpty
                    ? 'no_search_results'.tr()
                    : 'no_trips_today'.tr(),
                style: const TextStyle(
                  fontSize: AppConstants.fontSizeM,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingL,
            ),
            child: Column(
              children: filteredTrips.map((tripData) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppConstants.spacingL),
                  child: _buildTripCard(tripData),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildTripCard(dynamic tripData) {
    try {
      if (tripData is Map<String, dynamic>) {
        final enriched = Map<String, dynamic>.from(tripData);
        if ((enriched['school_name'] != null) &&
            enriched['school_id'] == null &&
            (enriched['stops'] == null ||
                (enriched['stops'] as List?)?.isEmpty == true)) {
          enriched['school_id'] = enriched['school_name'];
        }
        final trip = TripModel.fromJson(enriched);
        return TripCardWidget(trip: trip, onTap: () => _showTripDetail(trip));
      }

      if (tripData is TripModel) {
        return TripCardWidget(
          trip: tripData,
          onTap: () => _showTripDetail(tripData),
        );
      }

      return const SizedBox.shrink();
    } catch (e) {
      return const SizedBox.shrink();
    }
  }

  void _showTripDetail(TripModel trip) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<TripBloc>(),
        child: TripDetailModal(trip: trip),
      ),
    );
  }

  Widget _buildNotificationsSection(DashboardLoaded state) {
    final notifications = state.dashboard.notifications;
    final List<dynamic> notificationsList = (notifications as List)
        .take(2)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingL,
          ),
          child: Text(
            'recent_notifications'.tr(),
            style: const TextStyle(
              fontSize: AppConstants.fontSizeL,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: AppConstants.spacingL),
        if (notificationsList.isEmpty)
          Container(
            padding: const EdgeInsets.all(AppConstants.spacingXXL),
            child: Center(
              child: Text(
                'no_notifications'.tr(),
                style: const TextStyle(
                  fontSize: AppConstants.fontSizeM,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingL,
            ),
            itemCount: notificationsList.length,
            itemBuilder: (context, index) {
              return _buildNotificationItem(notificationsList[index]);
            },
          ),
      ],
    );
  }

  Widget _buildNotificationItem(dynamic notification) {
    String type;
    String title;
    String description;
    String dateCreation;

    if (notification is Map<String, dynamic>) {
      type = notification['type'] ?? '';
      title = notification['libelle'] ?? 'Notification';
      description = notification['description'] ?? '';
      dateCreation = notification['date_creation'] ?? '';
    } else {
      final notif = notification as dynamic;
      type = notif.type ?? '';
      title = notif.title ?? 'Notification';
      description = notif.description ?? '';
      dateCreation = notif.dateCreation?.toIso8601String() ?? '';
    }

    IconData icon;
    Color iconColor;
    Color backgroundColor;

    switch (type) {
      case 'trip_started':
        icon = Icons.directions_car;
        iconColor = AppColors.primary;
        backgroundColor = AppColors.primary.withValues(alpha: 0.1);
        break;
      case 'trip_completed':
        icon = Icons.check_circle;
        iconColor = AppColors.tripCompleted;
        backgroundColor = AppColors.tripCompletedBg;
        break;
      case 'subscription_activated':
        icon = Icons.card_membership;
        iconColor = AppColors.subscriptionActivated;
        backgroundColor = AppColors.subscriptionActivatedBg;
        break;
      case 'booking_request':
        icon = Icons.person_add;
        iconColor = AppColors.bookingRequest;
        backgroundColor = AppColors.bookingRequestBg;
        break;
      default:
        icon = Icons.notifications;
        iconColor = AppColors.primary;
        backgroundColor = AppColors.primary.withValues(alpha: 0.1);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingL),
      padding: const EdgeInsets.all(AppConstants.paddingM),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(color: AppColors.notificationBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.blackOpacity05,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: AppConstants.iconSizeM, color: iconColor),
          ),
          const SizedBox(width: AppConstants.spacingL),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: AppConstants.fontSizeM,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: AppConstants.fontSizeS,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            _formatNotificationTime(dateCreation),
            style: const TextStyle(
              fontSize: AppConstants.fontSizeXS,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingButton() {
    return FloatingActionButton(
      onPressed: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => const ReportProblemModal(),
        );
      },
      backgroundColor: AppColors.primary,
      child: SvgPicture.asset(
        'assets/icons/13.svg',
        colorFilter: const ColorFilter.mode(AppColors.white, BlendMode.srcIn),
        width: AppConstants.iconSizeL,
        height: AppConstants.iconSizeL,
      ),
    );
  }

  String _formatNotificationTime(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '';

    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inMinutes < 1) {
        return 'now'.tr();
      } else if (difference.inMinutes < 60) {
        return 'Il y a ${difference.inMinutes}m';
      } else if (difference.inHours < 24) {
        return 'Il y a ${difference.inHours}h';
      } else if (difference.inDays == 1) {
        return 'yesterday'.tr();
      } else if (difference.inDays < 7) {
        return 'days_ago'.tr().replaceAll('{0}', difference.inDays.toString());
      } else {
        return DateFormat('dd/MM').format(date);
      }
    } catch (e) {
      return '';
    }
  }
}
