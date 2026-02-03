import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:private_school/chauffeurs/pages/profil/data/models/driver_profile_model.dart';
import 'package:private_school/chauffeurs/pages/profil/data/services/driver_profile_service.dart';
import 'package:private_school/chauffeurs/pages/reports/presentation/widgets/report_problem_modal.dart';
import 'package:private_school/core/utils/app_colors.dart';
import '../../domain/bloc/dashboard_bloc.dart';
import '../../domain/bloc/dashboard_event.dart';
import '../../domain/bloc/dashboard_state.dart';
import '../widgets/dashboard_header.dart';
import '../../../trajets/presentation/pages/trip_page.dart';


class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  DriverProfileModel? _profile;
  bool _isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    _loadData();
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
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _loadData,
          child: CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: DashboardHeader(
                  profile: _profile,
                  isLoading: _isLoadingProfile,
                ),
              ),
              // Barre de recherche
              SliverToBoxAdapter(
                child: _buildSearchBar(),
              ),
              // Contenu principal
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
      ),
      floatingActionButton: _buildFloatingButton(),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Rechercher un trajet',
                  hintStyle: TextStyle(
                    color: AppColors.textSecondary.withValues(alpha: 0.5),
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppColors.textSecondary.withValues(alpha: 0.5),
                    size: 20,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () {
                // Ouvrir les filtres
              },
              icon: const Icon(
                Icons.tune,
                color: AppColors.primary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Padding(
      padding: EdgeInsets.all(80),
      child: Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadData,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'Réessayer',
                style: TextStyle(color: AppColors.white),
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
        const SizedBox(height: 20),
        _buildUpcomingTripsSection(state),
        const SizedBox(height: 24),
        _buildNotificationsSection(state),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildUpcomingTripsSection(DashboardLoaded state) {
    final upcomingTripsList = state.dashboard.upcomingTripsList;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Mes trajet à venir',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TripPage(),
                    ),
                  );
                },
                child: const Text(
                  'Voir plus',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (upcomingTripsList.isEmpty)
          Padding(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 48,
                    color: AppColors.textSecondary.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Aucun trajet à venir',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          SizedBox(
            height: 220,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              // ✅ CORRECTION : Afficher TOUS les trajets au lieu de limiter à 3
              itemCount: upcomingTripsList.length,
              itemBuilder: (context, index) {
                return _buildTripCard(upcomingTripsList[index]);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildTripCard(dynamic trip) {
    String startPoint;
    String endPoint;
    int capacityMax;
    String status;
    DateTime departureTime;
    String childrenCount;

    if (trip is Map<String, dynamic>) {
      // C'est un Map (JSON brut)
      startPoint = trip['start_point'] ?? '';
      endPoint = trip['end_point'] ?? '';
      capacityMax = trip['capacity_max'] ?? 0;
      status = trip['status'] ?? 'pending';
      departureTime = DateTime.parse(trip['departure_time'] ?? DateTime.now().toIso8601String());
      childrenCount = trip['children_count']?.toString() ?? '0';
    } else {
      // C'est un objet RecentTrip
      final recentTrip = trip as dynamic;
      startPoint = recentTrip.destination ?? '';  // Le modèle utilise 'destination'
      endPoint = '';  // Pas disponible dans RecentTrip
      capacityMax = recentTrip.passengers ?? 0;
      status = recentTrip.status ?? 'pending';
      departureTime = recentTrip.date ?? DateTime.now();
      childrenCount = '0';
    }

    final now = DateTime.now();
    final isToday = departureTime.year == now.year &&
        departureTime.month == now.month &&
        departureTime.day == now.day;
    
    String formattedDate;
    if (isToday) {
      formattedDate = "Aujourd'hui";
    } else {
      formattedDate = DateFormat('EEEE d MMMM', 'fr_FR').format(departureTime);
      formattedDate = formattedDate[0].toUpperCase() + formattedDate.substring(1);
    }

    // Déterminer le statut pour le badge
    String statusLabel;
    Color statusColor;
    
    switch (status) {
      case 'pending':
        statusLabel = 'En attente';
        statusColor = const Color(0xFFF59E0B);
        break;
      case 'in_progress':
        statusLabel = 'En cours';
        statusColor = AppColors.primary;
        break;
      case 'completed':
        statusLabel = 'Terminé';
        statusColor = const Color(0xFF16A34A);
        break;
      default:
        statusLabel = 'En attente';
        statusColor = const Color(0xFFF59E0B);
    }

    // ✅ Récupérer le nombre d'écoles
    final schoolCount = int.tryParse(childrenCount.toString()) ?? 1;

    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE5E5E5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header avec date et badge
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Color(0xFF16A34A),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    formattedDate,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        statusLabel,
                        style: TextStyle(
                          fontSize: 11,
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Nombre de passagers
            Row(
              children: [
                const Icon(
                  Icons.people_outline,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  '$capacityMax passagers',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Point de départ
            Row(
              children: [
                const Icon(
                  Icons.radio_button_checked,
                  size: 14,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    startPoint.isEmpty ? 'Point de départ' : startPoint,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            // Ligne verticale
            Padding(
              padding: const EdgeInsets.only(left: 6),
              child: Container(
                width: 2,
                height: 16,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.primary.withValues(alpha: 0.5),
                      AppColors.primary.withValues(alpha: 0.2),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            // Point d'arrivée
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  size: 14,
                  color: AppColors.error,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    endPoint.isEmpty ? (startPoint.isEmpty ? 'Destination' : startPoint) : endPoint,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Spacer(),
            // Écoles desservies
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.school,
                    size: 14,
                    color: Color(0xFF16A34A),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$schoolCount ${schoolCount > 1 ? "écoles desservies" : "école desservie"}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF16A34A),
                      fontWeight: FontWeight.w500,
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

  Widget _buildNotificationsSection(DashboardLoaded state) {
    // Gestion sécurisée des notifications
    final notifications = state.dashboard.notifications;
    final List<dynamic> notificationsList = (notifications as List).take(2).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Notifications récentes',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (notificationsList.isEmpty)
          Padding(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Text(
                'Aucune notification',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary.withValues(alpha: 0.7),
                ),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: notificationsList.length,
            itemBuilder: (context, index) {
              return _buildNotificationItem(notificationsList[index]);
            },
          ),
      ],
    );
  }

  Widget _buildNotificationItem(dynamic notification) {
    // ✅ CORRECTION : Gérer les 2 cas (Map OU NotificationModel)
    String type;
    String title;
    String description;
    String dateCreation;

    if (notification is Map<String, dynamic>) {
      // C'est un Map (JSON brut)
      type = notification['type'] ?? '';
      title = notification['libelle'] ?? 'Notification';
      description = notification['description'] ?? '';
      dateCreation = notification['date_creation'] ?? '';
    } else {
      // C'est un objet NotificationModel
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
        iconColor = const Color(0xFF16A34A);
        backgroundColor = const Color(0xFFF0FDF4);
        break;
      case 'subscription_activated':
        icon = Icons.card_membership;
        iconColor = const Color(0xFF3B82F6);
        backgroundColor = const Color(0xFFDEEBFF);
        break;
      case 'booking_request':
        icon = Icons.person_add;
        iconColor = const Color(0xFFF59E0B);
        backgroundColor = const Color(0xFFFEF3C7);
        break;
      default:
        icon = Icons.notifications;
        iconColor = AppColors.primary;
        backgroundColor = AppColors.primary.withValues(alpha: 0.1);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE5E5E5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
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
            child: Icon(
              icon,
              size: 20,
              color: iconColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
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
              fontSize: 11,
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
        width: 28,
        height: 28,
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
        return "À l'instant";
      } else if (difference.inMinutes < 60) {
        return 'Il y a ${difference.inMinutes}m';
      } else if (difference.inHours < 24) {
        return 'Il y a ${difference.inHours}h';
      } else if (difference.inDays == 1) {
        return 'Hier';
      } else if (difference.inDays < 7) {
        return 'Il y a ${difference.inDays}j';
      } else {
        return DateFormat('dd/MM').format(date);
      }
    } catch (e) {
      return '';
    }
  }
}