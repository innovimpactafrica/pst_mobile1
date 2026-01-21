import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/bloc/trip_bloc.dart';
import '../../domain/bloc/trip_event.dart';
import '../../domain/bloc/trip_state.dart';
import '../../data/repositories/trip_repository.dart';
import '../widgets/trip_card_widget.dart';
import '../../../../utils/app_colors.dart';

import 'trip_detail_page.dart';

class TrajetsPage extends StatelessWidget {
  const TrajetsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TripBloc(repository: TripRepository())
        ..add(LoadAvailableTripsEvent()),
      child: const TrajetsPageContent(),
    );
  }
}

class TrajetsPageContent extends StatelessWidget {
  const TrajetsPageContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mes trajets',
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),

                ],
              ),
            ),

            const SizedBox(height: 16),

            // TABS
            BlocBuilder<TripBloc, TripState>(
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
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        _buildTabButton(
                          context,
                          'Trajets disponibles',
                          0,
                          selectedTab,
                        ),
                        _buildTabButton(
                          context,
                          'Mes réservations',
                          1,
                          selectedTab,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // CONTENT
            Expanded(
              child: BlocBuilder<TripBloc, TripState>(
                builder: (context, state) {
                  if (state is TripLoading) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryGreen,
                      ),
                    );
                  }

                  if (state is TripError) {
                    return Center(
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
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () {
                              context.read<TripBloc>().add(
                                LoadAvailableTripsEvent(),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryGreen,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Réessayer',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is TripLoaded) {
                    if (state.trips.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              state.selectedTabIndex == 0
                                  ? Icons.directions_bus_outlined
                                  : Icons.bookmark_border,
                              size: 80,
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              state.selectedTabIndex == 0
                                  ? 'Aucun trajet disponible'
                                  : 'Aucune réservation',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 40),
                              child: Text(
                                state.selectedTabIndex == 0
                                    ? 'Les trajets disponibles apparaîtront ici'
                                    : 'Vos réservations apparaîtront ici',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: Colors.grey.shade500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      color: AppColors.primaryGreen,
                      onRefresh: () async {
                        if (state.selectedTabIndex == 0) {
                          context.read<TripBloc>().add(LoadAvailableTripsEvent());
                        } else {
                          context.read<TripBloc>().add(LoadMyReservationsEvent());
                        }
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: state.trips.length,
                        itemBuilder: (context, index) {
                          final trip = state.trips[index];
                          return TripCardWidget(
                            trip: trip,
                            onTap: () {
                              // Navigation vers la page de détails
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TripDetailPage(trip: trip),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
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
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryGreen : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? Colors.white : Colors.grey.shade600,
            ),
          ),
        ),
      ),
    );
  }
}