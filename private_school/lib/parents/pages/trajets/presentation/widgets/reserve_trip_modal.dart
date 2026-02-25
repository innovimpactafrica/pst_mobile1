import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_constants.dart';
import '../../../enfants/domain/bloc/child_bloc.dart';
import '../../../enfants/domain/bloc/child_state.dart';
import '../../../enfants/data/models/child_model.dart';
import '../../data/models/trip_model.dart';
import '../../domain/bloc/trip_bloc.dart';
import '../../domain/bloc/trip_event.dart';

/// Modal pour sélectionner les enfants et réserver un trajet
class ReserveTripModal extends StatefulWidget {
  final TripModel trip;

  const ReserveTripModal({super.key, required this.trip});

  @override
  State<ReserveTripModal> createState() => _ReserveTripModalState();
}

class _ReserveTripModalState extends State<ReserveTripModal> {
  final Set<String> _selectedChildIds = {};
  bool _isReserving = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppConstants.radiusXXL),
          topRight: Radius.circular(AppConstants.radiusXXL),
        ),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: AppConstants.spacingM),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.grey300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(AppConstants.spacingXL),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'select_children'.tr(),
                        style: GoogleFonts.inter(
                          fontSize: AppConstants.fontSizeXL,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'select_children_for_trip'.tr(),
                        style: GoogleFonts.inter(
                          fontSize: AppConstants.fontSizeS,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // ===== TRIP INFO =====
          Container(
            margin: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacingXL,
            ),
            padding: const EdgeInsets.all(AppConstants.spacingL),
            decoration: BoxDecoration(
              color: AppColors.successBackground,
              borderRadius: BorderRadius.circular(AppConstants.radiusL),
              border: Border.all(
                color: AppColors.success.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.route, color: AppColors.success, size: 24),
                const SizedBox(width: AppConstants.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.trip.startLocation} → ${widget.trip.destination}',
                        style: GoogleFonts.inter(
                          fontSize: AppConstants.fontSizeM,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${widget.trip.time} • ${widget.trip.formattedDate}',
                        style: GoogleFonts.inter(
                          fontSize: AppConstants.fontSizeS,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppConstants.spacingL),

          // ===== CHILDREN LIST =====
          Expanded(
            child: BlocBuilder<ChildBloc, ChildState>(
              builder: (context, state) {
                if (state is ChildLoadingState) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.success),
                  );
                }

                if (state is ChildErrorState) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: AppColors.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          state.error,
                          style: GoogleFonts.inter(color: AppColors.error),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                if (state is ChildLoadedState) {
                  if (state.children.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person_add_outlined,
                            size: 64,
                            color: AppColors.grey400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'no_children_registered'.tr(),
                            style: GoogleFonts.inter(
                              fontSize: AppConstants.fontSizeL,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'add_child_first'.tr(),
                            style: GoogleFonts.inter(
                              fontSize: AppConstants.fontSizeS,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spacingXL,
                    ),
                    itemCount: state.children.length,
                    itemBuilder: (context, index) {
                      final child = state.children[index];
                      final isSelected = _selectedChildIds.contains(
                        child.id.toString(),
                      );

                      return _buildChildTile(child, isSelected);
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),

          // ===== BOTTOM BUTTON =====
          Container(
            padding: const EdgeInsets.all(AppConstants.spacingXL),
            decoration: BoxDecoration(
              color: AppColors.white,
              boxShadow: [
                BoxShadow(
                  color: AppColors.blackOpacity05,
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Compteur de places
                  if (_selectedChildIds.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(
                        bottom: AppConstants.spacingM,
                      ),
                      padding: const EdgeInsets.all(AppConstants.spacingM),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(
                          AppConstants.radiusM,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${_selectedChildIds.length} ${'children_selected'.tr()}',
                            style: GoogleFonts.inter(
                              fontSize: AppConstants.fontSizeM,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Bouton de réservation
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _selectedChildIds.isEmpty || _isReserving
                          ? null
                          : _reserveTrip,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        disabledBackgroundColor: AppColors.grey300,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppConstants.spacingL,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppConstants.radiusL,
                          ),
                        ),
                        elevation: 0,
                      ),
                      child: _isReserving
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: AppColors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'confirm_reservation'.tr(),
                              style: GoogleFonts.inter(
                                fontSize: AppConstants.fontSizeL,
                                fontWeight: FontWeight.w600,
                                color: AppColors.white,
                              ),
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

  Widget _buildChildTile(ChildModel child, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedChildIds.remove(child.id.toString());
          } else {
            // Vérifier s'il reste de la place
            final remainingSeats =
                widget.trip.totalSeats - widget.trip.passengers.length;
            if (_selectedChildIds.length < remainingSeats) {
              _selectedChildIds.add(child.id.toString());
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('no_more_seats'.tr()),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppConstants.spacingM),
        padding: const EdgeInsets.all(AppConstants.spacingL),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.success.withValues(alpha: 0.1)
              : AppColors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
          border: Border.all(
            color: isSelected ? AppColors.success : AppColors.grey200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 24,
              backgroundColor: isSelected
                  ? AppColors.success
                  : AppColors.grey300,
              child: Text(
                child.initials,
                style: GoogleFonts.inter(
                  fontSize: AppConstants.fontSizeM,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? AppColors.white : AppColors.textSecondary,
                ),
              ),
            ),

            const SizedBox(width: AppConstants.spacingM),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    child.name,
                    style: GoogleFonts.inter(
                      fontSize: AppConstants.fontSizeM,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (child.schoolName != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      child.schoolName!,
                      style: GoogleFonts.inter(
                        fontSize: AppConstants.fontSizeS,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Checkbox
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.success : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppColors.success : AppColors.grey400,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 16, color: AppColors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  void _reserveTrip() async {
    setState(() => _isReserving = true);

    try {
      // Déclencher l'événement de réservation
      context.read<TripBloc>().add(
        ReserveTripEvent(
          tripId: widget.trip.id,
          childIds: _selectedChildIds.toList(),
        ),
      );

      // Attendre un peu pour que le BLoC traite
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        Navigator.pop(context, true); // Retourner true pour indiquer succès

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('reservation_successful'.tr()),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('reservation_failed'.tr()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isReserving = false);
      }
    }
  }
}
