import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:private_school/chauffeurs/pages/trajets/data/models/trip_model.dart';
import 'package:private_school/core/utils/app_constants.dart';
import 'package:private_school/core/utils/app_colors.dart';

/// Passengers list modal widget
/// Shows the complete list of passengers for a trip
class PassengersListModal extends StatelessWidget {
  final List<Passenger> passengers;

  const PassengersListModal({super.key, required this.passengers});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Header with handle
          Column(
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.grey300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppConstants.labelPassengers,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: AppColors.grey600),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Passengers list
          Expanded(
            child: passengers.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: AppColors.grey300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          AppConstants.labelNoPassengers,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: AppColors.grey600,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: passengers.length,
                    separatorBuilder: (context, index) =>
                        Divider(height: 1, color: AppColors.divider),
                    itemBuilder: (context, index) {
                      final passenger = passengers[index];
                      return _buildPassengerItem(passenger);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPassengerItem(Passenger passenger) {
    // Convert hex color to Color with fallback
    Color avatarColor = _parseColor(passenger.avatarColor ?? '#4CAF50');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          // Avatar with initials or photo
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: avatarColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: (passenger.photo?.isNotEmpty ?? false)
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/images/${passenger.photo}',
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildInitialsAvatar(
                            passenger.initials,
                            avatarColor,
                          );
                        },
                      ),
                    )
                  : _buildInitialsAvatar(passenger.initials, avatarColor),
            ),
          ),

          const SizedBox(width: 12),

          // Passenger info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  passenger.name,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  passenger.school ?? AppConstants.labelSchoolNotSpecified,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialsAvatar(String initials, Color color) {
    return Text(
      initials,
      style: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: color,
      ),
    );
  }

  Color _parseColor(String hexColor) {
    try {
      final hex = hexColor.replaceAll('#', '');
      if (hex.length == 6) {
        return Color(int.parse('FF$hex', radix: 16));
      }
      return AppColors.success;
    } catch (e) {
      return AppColors.success;
    }
  }
}