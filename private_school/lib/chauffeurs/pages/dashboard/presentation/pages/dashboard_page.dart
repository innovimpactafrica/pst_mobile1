import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:private_school/chauffeurs/pages/dashboard/data/models/dashboard_model.dart';
import 'package:private_school/chauffeurs/pages/profil/data/models/driver_profile_model.dart';
import 'package:private_school/chauffeurs/pages/profil/data/services/driver_profile_service.dart';
import 'package:private_school/core/utils/app_colors.dart';
import 'package:private_school/core/utils/app_constants.dart';
import '../../domain/bloc/dashboard_bloc.dart';
import '../../domain/bloc/dashboard_event.dart';
import '../../domain/bloc/dashboard_state.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/stats_card.dart';
import '../widgets/recent_trips_section.dart';

/// Main dashboard page for drivers
/// Location: lib/features/dashboard/presentation/pages/dashboard_page.dart
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
          onRefresh: () async {
            await _loadData();
          },
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
                  margin: const EdgeInsets.only(top: AppConstants.spacingXL),
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(AppConstants.radiusXL),
                      topRight: Radius.circular(AppConstants.radiusXL),
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
      padding: EdgeInsets.all(AppConstants.spacingXXXL * 2),
      child: Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      ),
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
              size: AppConstants.iconSizeXXXL * 2,
              color: AppColors.error,
            ),
            const SizedBox(height: AppConstants.spacingXL),
            Text(
              message,
              style: const TextStyle(
                fontSize: AppConstants.fontSizeL,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacingXL),
            ElevatedButton(
              onPressed: () => _loadData(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacingXXL,
                  vertical: AppConstants.spacingM,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                ),
              ),
              child: const Text(
                AppConstants.labelRetry,
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
        const SizedBox(height: AppConstants.spacingXXL),
        _buildStatsGrid(state),
        const SizedBox(height: AppConstants.spacingXXL),
        _buildEarningsSection(state),
        const SizedBox(height: AppConstants.spacingXXL),
        if (state.dashboard.subscription != null)
          _buildSubscriptionCard(state.dashboard.subscription!),
        if (state.dashboard.subscription != null)
          const SizedBox(height: AppConstants.spacingXXL),
        RecentTripsSection(trips: state.dashboard.recentTrips),
        const SizedBox(height: AppConstants.spacingXXXL * 2),
      ],
    );
  }

  Widget _buildStatsGrid(DashboardLoaded state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingXL),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: AppConstants.spacingM,
        mainAxisSpacing: AppConstants.spacingM,
        childAspectRatio: 1.4,
        children: [
          StatsCard(
            title: AppConstants.labelTotalTrips,
            value: '${state.dashboard.totalTrips}',
            icon: Icons.directions_car,
            color: AppColors.info,
            backgroundColor: AppColors.infoBackground,
          ),
          StatsCard(
            title: AppConstants.labelCompletedTrips,
            value: '${state.dashboard.completedTrips}',
            icon: Icons.check_circle,
            color: AppColors.success,
            backgroundColor: AppColors.successBackground,
          ),
          StatsCard(
            title: AppConstants.labelUpcomingTripsShort,
            value: '${state.dashboard.upcomingTrips}',
            icon: Icons.schedule,
            color: AppColors.warning,
            backgroundColor: AppColors.warningBackground,
          ),
          StatsCard(
            title: AppConstants.labelActivePassengers,
            value: '${state.dashboard.activePassengers}',
            icon: Icons.people,
            color: AppColors.primary,
            backgroundColor: AppColors.infoBackground,
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsSection(DashboardLoaded state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingXL),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spacingXL),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary,
              AppColors.primaryLight,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppConstants.labelTotalEarnings,
                    style: TextStyle(
                      color: AppColors.white.withValues(alpha: 0.9),
                      fontSize: AppConstants.fontSizeM,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingXS),
                  Text(
                    '${state.dashboard.totalEarnings.toStringAsFixed(0)} FCFA',
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: AppConstants.fontSizeXXL,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingS),
                  Text(
                    '${AppConstants.labelMonthlyEarnings}: ${state.dashboard.monthlyEarnings.toStringAsFixed(0)} FCFA',
                    style: TextStyle(
                      color: AppColors.white.withValues(alpha: 0.8),
                      fontSize: AppConstants.fontSizeS,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(AppConstants.spacingM),
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
              ),
              child: const Icon(
                Icons.account_balance_wallet,
                color: AppColors.white,
                size: AppConstants.iconSizeXL,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionCard(SubscriptionStatus subscription) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spacingXL),
      padding: const EdgeInsets.all(AppConstants.spacingXL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: subscription.isActive
              ? [AppColors.success, AppColors.successDark]
              : [AppColors.error, Colors.red.shade700],
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppConstants.spacingM),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
            ),
            child: const Icon(
              Icons.card_membership,
              color: AppColors.white,
              size: AppConstants.iconSizeXL,
            ),
          ),
          const SizedBox(width: AppConstants.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppConstants.labelSubscription,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: AppConstants.fontSizeM,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: AppConstants.spacingXS),
                Text(
                  subscription.plan,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: AppConstants.fontSizeXL,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (subscription.isActive && subscription.daysRemaining > 0)
                  Text(
                    '${subscription.daysRemaining} ${AppConstants.labelDaysRemaining}',
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: AppConstants.fontSizeS,
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacingM,
              vertical: AppConstants.spacingXS,
            ),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppConstants.radiusXL),
            ),
            child: Text(
              subscription.isActive
                  ? AppConstants.labelSubscriptionActive
                  : AppConstants.labelSubscriptionExpired,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: AppConstants.fontSizeS,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingButton() {
    return FloatingActionButton.extended(
      onPressed: () {
        // Show report problem modal
        // showReportProblemModal(context);
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