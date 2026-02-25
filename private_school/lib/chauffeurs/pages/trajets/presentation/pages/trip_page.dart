import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart' as easy;
import 'package:private_school/chauffeurs/pages/trajets/presentation/widgets/create_trip_modal.dart';

import 'package:private_school/core/utils/app_colors.dart';
import 'package:private_school/core/utils/app_constants.dart';

import '../../data/models/trip_model.dart';

import '../../domain/bloc/trip_bloc.dart';
import '../../domain/bloc/trip_event.dart';
import '../../domain/bloc/trip_state.dart';
import '../widgets/trip_card_widget.dart';
import '../widgets/trip_detail_modal.dart';


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
    
    // Charger les trajets
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TripBloc>().add(LoadTripsEvent());
    });
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
            const SizedBox(height: AppConstants.spacingXXL),
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
      padding: const EdgeInsets.all(AppConstants.spacingXXL),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              AppConstants.labelMyTrips,
              style: TextStyle(
                color: AppColors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spacingXXL),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(25),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
        ),
        labelColor: AppColors.primary,
        unselectedLabelColor: Colors.white,
        labelStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        tabs: [
          Tab(text: 'upcoming'.tr()),
          Tab(text: 'history'.tr()),
        ],
      ),
    );
  }

  Widget _buildTripsList() {
    return Container(
      margin: const EdgeInsets.only(top: AppConstants.spacingXXL),
      decoration: const BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppConstants.radiusXL),
          topRight: Radius.circular(AppConstants.radiusXL),
        ),
      ),
      child: BlocBuilder<TripBloc, TripState>(
        builder: (context, state) {
         

          if (state is TripLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state is TripError) {
           
            return _buildErrorState(state.message);
          }

          if (state is TripsLoaded) {
           
            
            //  Afficher tous les statuts
            for (var trip in state.trips) {
              
            }
            
            return _buildTabBarViewContent(state.trips);
          }

          // État initial
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        },
      ),
    );
  }

  Widget _buildTabBarViewContent(List<TripModel> trips) {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildUpcomingTrips(trips),
        _buildHistoryTrips(trips),
      ],
    );
  }

  Widget _buildUpcomingTrips(List<TripModel> trips) {
    final upcomingTrips = trips
        .where((trip) {
         
          if (trip.status == 'canceled') return false;
          
          
          if (trip.tripType == 'aller' && trip.status == 'completed') return false;
          
         
          if (trip.tripType == 'retour' && trip.status == 'completed') return false;
          
        
          if (trip.tripType == 'aller_retour' && trip.status == 'completed' && trip.returnStatus == 'completed') return false;
          
         
          return true;
        })
        .toList();

    if (upcomingTrips.isEmpty) {
      return _buildEmptyState('no_upcoming_trips'.tr());
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        context.read<TripBloc>().add(RefreshTripsEvent());
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(AppConstants.spacingXXL),
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
        .where((trip) {
      
          if (trip.status == 'canceled') return true;
          
       
          if (trip.tripType == 'aller' && trip.status == 'completed') return true;
          
          
          if (trip.tripType == 'retour' && trip.status == 'completed') return true;
          
          
          if (trip.tripType == 'aller_retour' && trip.status == 'completed' && trip.returnStatus == 'completed') return true;
          
          
          return false;
        })
        .toList();
    if (historyTrips.isEmpty) {
      return _buildEmptyState('no_history'.tr());
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        context.read<TripBloc>().add(RefreshTripsEvent());
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(AppConstants.spacingXXL),
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
            size: 64,
            color: AppColors.grey400,
          ),
          const SizedBox(height: AppConstants.spacingM),
          Text(
            message,
            style: const TextStyle(
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
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingXXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: AppConstants.spacingM),
            Text(
              'error_loading_trips'.tr(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppConstants.spacingS),
            Text(
              message,
              style: const TextStyle(
                fontSize: AppConstants.fontSizeM,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacingXXL),
            ElevatedButton(
              onPressed: () {
                context.read<TripBloc>().add(LoadTripsEvent());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusL),
                ),
              ),
              child: const Text(
                AppConstants.labelRetry,
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
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
          builder: (context) => BlocProvider.value(
            value: context.read<TripBloc>(),
            child: const CreateTripModal(),
          ),
        );
      },
      backgroundColor: AppColors.primary,
      child: const Icon(
        Icons.route,
        color: AppColors.white,
        size: 28,
      ),
    );
  }

  void _showTripDetails(TripModel trip) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocProvider.value(
        value: context.read<TripBloc>(),
        child: TripDetailModal(trip: trip),
      ),
    );
  }
}