import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


import 'package:private_school/core/utils/app_colors.dart';
import 'package:private_school/core/utils/app_constants.dart';

import '../../data/models/trip_model.dart';
import '../../domain/bloc/trip_bloc.dart';
import '../../domain/bloc/trip_event.dart';
import '../../domain/bloc/trip_state.dart';
import '../widgets/trip_card_widget.dart';
import '../widgets/trip_detail_modal.dart';

/// Main trips page with upcoming and history tabs
/// Location: lib/features/trajets/presentation/pages/trip_page.dart
class TripPage extends StatefulWidget {
 const TripPage({super.key});

  @override
  State<TripPage> createState() => _TripPageState();
}

class _TripPageState extends State<TripPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<TripBloc>().add(LoadTripsEvent());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(child: _buildTripsList()),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingButton(),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding:  EdgeInsets.all(AppConstants.spacingXL),
      child:  Text(
        AppConstants.labelMyTrips,
        style: TextStyle(
          color: AppColors.textWhite,
          fontSize: AppConstants.fontSizeXXXL,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin:  EdgeInsets.symmetric(horizontal: AppConstants.spacingXL),
      decoration: BoxDecoration(
       color: AppColors.whiteOpacity20,
        borderRadius: BorderRadius.circular(AppConstants.radiusXXL),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.textWhite,
          borderRadius: BorderRadius.circular(AppConstants.radiusXXL),
        ),
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textWhite,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        tabs:  [
          Tab(text: AppConstants.labelUpcoming),
          Tab(text: AppConstants.labelHistory),
        ],
      ),
    );
  }

  Widget _buildTripsList() {
    return Container(
      margin:  EdgeInsets.only(top: AppConstants.spacingXL),
      decoration:  BoxDecoration(
        color: AppColors.textWhite,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppConstants.radiusXXL),
          topRight: Radius.circular(AppConstants.radiusXXL),
        ),
      ),
      child: BlocBuilder<TripBloc, TripState>(
        builder: (context, state) {
          if (state is TripLoading) {
            return  Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state is TripError) {
            return _buildErrorState(state.message);
          }

          if (state is TripsLoaded) {
            return TabBarView(
              controller: _tabController,
              children: [
                _buildUpcomingTrips(state.trips),
                _buildHistoryTrips(state.trips),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildUpcomingTrips(List<TripModel> trips) {
    final upcomingTrips = trips
        .where(
          (trip) =>
              trip.status == AppConstants.statusPending ||
              trip.status == AppConstants.statusActive ||
              trip.status == AppConstants.statusStarted,
        )
        .toList();

    if (upcomingTrips.isEmpty) {
      return _buildEmptyState(AppConstants.labelNoUpcomingTrips);
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        context.read<TripBloc>().add(RefreshTripsEvent());
      },
      child: ListView.builder(
        padding:  EdgeInsets.all(AppConstants.spacingXL),
        itemCount: upcomingTrips.length,
        itemBuilder: (context, index) {
          return TripCardWidget(
            trip: upcomingTrips[index],
            onTap: () => _showTripDetails(upcomingTrips[index]),
          );
        },
      ),
    );
  }

  Widget _buildHistoryTrips(List<TripModel> trips) {
    final historyTrips = trips
        .where(
          (trip) =>
              trip.status == AppConstants.statusCompleted ||
              trip.status == AppConstants.statusCanceled,
        )
        .toList();

    if (historyTrips.isEmpty) {
      return _buildEmptyState(AppConstants.labelNoHistory);
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        context.read<TripBloc>().add(RefreshTripsEvent());
      },
      child: ListView.builder(
        padding:  EdgeInsets.all(AppConstants.spacingXL),
        itemCount: historyTrips.length,
        itemBuilder: (context, index) {
          return TripCardWidget(
            trip: historyTrips[index],
            onTap: () => _showTripDetails(historyTrips[index]),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: AppConstants.iconSizeXXXL + AppConstants.spacingL,
            color: AppColors.grey400,
          ),
          const SizedBox(height: AppConstants.spacingL),
          Text(
            message,
            style:  TextStyle(
              fontSize: AppConstants.fontSizeL,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
           Icon(
            Icons.error_outline,
            size: AppConstants.iconSizeXXXL,
            color: AppColors.error,
          ),
          SizedBox(height: AppConstants.spacingL),
          Text(
            message,
            style:  TextStyle(
              fontSize: AppConstants.fontSizeL,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
           SizedBox(height: AppConstants.spacingL),
          ElevatedButton(
            onPressed: () => context.read<TripBloc>().add(LoadTripsEvent()),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
              ),
            ),
            child:  Text(
              AppConstants.labelRetry,
              style: TextStyle(color: AppColors.textWhite),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingButton() {
    return FloatingActionButton(
      onPressed: () {
        // Navigate to create trip page
      },
      backgroundColor: AppColors.primary,
      child:  Icon(Icons.add, color: AppColors.textWhite),
    );
  }

  void _showTripDetails(TripModel trip) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TripDetailModal(trip: trip),
    );
  }
}
