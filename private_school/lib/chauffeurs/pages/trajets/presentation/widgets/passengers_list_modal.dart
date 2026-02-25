import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:private_school/chauffeurs/pages/trajets/data/models/trip_model.dart';
import 'package:private_school/core/utils/app_constants.dart';
import 'package:private_school/core/utils/app_colors.dart';

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
    const Color avatarBgColor = Color(0xFFE8F5E9);
    const Color avatarTextColor = Color(0xFF4CAF50);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: avatarBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                passenger.initials,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: avatarTextColor,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

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
}
