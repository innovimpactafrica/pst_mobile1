// Dashboard page with real API data
// Path: lib/chauffeurs/pages/dashboard/presentation/pages/dashboard_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:private_school/chauffeurs/pages/profil/data/models/driver_profile_model.dart';
import 'package:private_school/chauffeurs/pages/profil/data/services/driver_profile_service.dart';
import 'package:private_school/core/utils/app_colors.dart';
import '../../domain/bloc/dashboard_bloc.dart';
import '../../domain/bloc/dashboard_event.dart';
import '../../domain/bloc/dashboard_state.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/stats_card.dart';
import '../widgets/notifications_section.dart';
import 'package:private_school/chauffeurs/widgets/report_problem_modal.dart';

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
          color: AppColors.white,
          backgroundColor: AppColors.primary,
          onRefresh: _loadData,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: DashboardHeader(
                  profile: _profile,
                  isLoading: _isLoadingProfile,
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.only(top: 24),
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
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
        const SizedBox(height: 24),
        _buildStatsGrid(state),
        const SizedBox(height: 24),
        // Notifications section with real data
        NotificationsSection(
          notifications: state.dashboard.notifications,
          unreadCount: state.dashboard.unreadNotificationsCount,
        ),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildStatsGrid(DashboardLoaded state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.3,
        children: [
          StatsCard(
            title: 'Trajets complétés',
            value: '${state.dashboard.stats.completedTrips}',
            icon: Icons.check_circle,
            color: AppColors.success,
            backgroundColor: AppColors.successBackground,
          ),
          StatsCard(
            title: 'Note moyenne',
            value: state.dashboard.stats.averageRating.toStringAsFixed(1),
            icon: Icons.star,
            color: const Color(0xFFF59E0B),
            backgroundColor: const Color(0xFFFEF3C7),
          ),
          StatsCard(
            title: 'Trajets ce mois',
            value: '${state.dashboard.stats.tripsThisMonth}',
            icon: Icons.calendar_today,
            color: const Color(0xFF3B82F6),
            backgroundColor: const Color(0xFFDEEBFF),
          ),
          StatsCard(
            title: 'Enfants transportés',
            value: '${state.dashboard.stats.totalChildrenTransported}',
            icon: Icons.people,
            color: AppColors.primary,
            backgroundColor: AppColors.primaryLight.withValues(alpha: 0.2),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingButton() {
    return FloatingActionButton.extended(
      onPressed: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => const ReportProblemModal(),
        );
      },
      backgroundColor: AppColors.primary,
      icon: const Icon(
        Icons.warning_amber_outlined,
        color: AppColors.white,
      ),
      label: const Text(
        'Signaler',
        style: TextStyle(
          color: AppColors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}