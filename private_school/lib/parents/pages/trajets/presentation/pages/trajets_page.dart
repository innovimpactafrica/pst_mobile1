import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../domain/bloc/trip_bloc.dart';
import '../../domain/bloc/trip_event.dart';
import '../../domain/bloc/trip_state.dart';
import '../../data/repositories/trip_repository.dart';
import '../widgets/trip_card_widget.dart';
import '../../../../../core/utils/app_colors.dart';

import 'trip_detail_page.dart';
import 'trip_tracking_page.dart';

class TrajetsPage extends StatelessWidget {
  const TrajetsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          TripBloc(repository: TripRepository())
            ..add(LoadAvailableTripsEvent()),
      child: const TrajetsPageContent(),
    );
  }
}

class TrajetsPageContent extends StatelessWidget {
  const TrajetsPageContent({super.key});

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          _buildGreenHeader(),
          Expanded(
            child: Column(
              children: [
                const SizedBox(height: 16),

                // Tabs dans la zone blanche
                _buildTabsSection(),

                const SizedBox(height: 16),

                // Liste des trajets
                Expanded(child: _buildTripsList(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGreenHeader() {
    return Container(
      width: double.infinity,
      color: AppColors.success,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Text(
            'my_trips'.tr(),
            style: GoogleFonts.inter(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
              letterSpacing: -0.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabsSection() {
    return BlocBuilder<TripBloc, TripState>(
      builder: (context, state) {
        int selectedTab = 0;
        if (state is TripLoaded) {
          selectedTab = state.selectedTabIndex;
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(19),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                _buildTabButton(
                  context,
                  'available_trips'.tr(),
                  0,
                  selectedTab,
                ),
                _buildTabButton(
                  context,
                  'my_reservations'.tr(),
                  1,
                  selectedTab,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabButton(
    BuildContext context,
    String label,
    int tabIndex,
    int selectedTabIndex,
  ) {
    final isSelected = tabIndex == selectedTabIndex;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          context.read<TripBloc>().add(SelectTripTabEvent(tabIndex));
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),

            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,

              color: isSelected ? AppColors.primary : Colors.grey.shade600,
              letterSpacing: -0.2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTripsList(BuildContext context) {
    return BlocBuilder<TripBloc, TripState>(
      builder: (context, state) {
        if (state is TripLoading) {
          return Center(
            child: CircularProgressIndicator(
              color: AppColors.success,
              strokeWidth: 2.5,
            ),
          );
        }

        if (state is TripError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<TripBloc>().add(LoadAvailableTripsEvent());
                    },
                    icon: const Icon(Icons.refresh),
                    label: Text(
                      'retry'.tr(),
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is TripLoaded) {
          // Liste vide
          if (state.trips.isEmpty) {
            return _buildEmptyState(state.selectedTabIndex);
          }

          // Liste avec données
          return RefreshIndicator(
            color: AppColors.success,
            backgroundColor: Colors.white,
            strokeWidth: 2.5,
            onRefresh: () async {
              if (state.selectedTabIndex == 0) {
                context.read<TripBloc>().add(LoadAvailableTripsEvent());
              } else {
                context.read<TripBloc>().add(LoadMyReservationsEvent());
              }
            },
            child: ListView.builder(
              padding: EdgeInsets.fromLTRB(
                20,
                0,
                20,
                MediaQuery.of(context).padding.bottom + 80,
              ),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: state.trips.length,
              itemBuilder: (context, index) {
                final trip = state.trips[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TripCardWidget(
                    trip: trip,
                    onTap: () => _handleTripTap(
                      context: context,
                      trip: trip,
                      selectedTabIndex: state.selectedTabIndex,
                    ),
                  ),
                );
              },
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildEmptyState(int selectedTabIndex) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              selectedTabIndex == 0
                  ? Icons.directions_bus_outlined
                  : Icons.bookmark_border,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 20),
            Text(
              selectedTabIndex == 0
                  ? 'no_available_trips'.tr()
                  : 'no_reservations'.tr(),
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              selectedTabIndex == 0
                  ? 'available_trips_will_appear'.tr()
                  : 'reservations_will_appear'.tr(),
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _handleTripTap({
    required BuildContext context,
    required trip,
    required int selectedTabIndex,
  }) {
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('🔵 [TrajetsPage] TAP SUR CARD');
    debugPrint('   Trip ID: ${trip.id}');
    debugPrint('   Status: ${trip.status}');
    debugPrint('   Onglet actif: $selectedTabIndex');
    debugPrint(
      '   → ${selectedTabIndex == 1 ? "TripTrackingPage" : "TripDetailPage"}',
    );
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    if (selectedTabIndex == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => TripTrackingPage(trip: trip)),
      ).then((_) {
        // Recharger les réservations au retour
        context.read<TripBloc>().add(LoadMyReservationsEvent());
      });
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => TripDetailPage(trip: trip)),
      ).then((_) {
        context.read<TripBloc>().add(LoadAvailableTripsEvent());
      });
    }
  }
}
