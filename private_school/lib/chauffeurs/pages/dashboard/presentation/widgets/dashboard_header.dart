import 'package:flutter/material.dart';
import 'package:private_school/chauffeurs/pages/profil/data/models/driver_profile_model.dart';
import 'package:private_school/core/utils/app_colors.dart';
import 'package:private_school/core/utils/app_constants.dart';


/// Dashboard header with driver profile info
/// Location: lib/features/dashboard/presentation/widgets/dashboard_header.dart
class DashboardHeader extends StatelessWidget {
  final DriverProfileModel? profile;
  final bool isLoading;

  const DashboardHeader({
    super.key,
    this.profile,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacingXL),
      child: Row(
        children: [
          // Profile Image
          _buildProfileImage(),
          const SizedBox(width: AppConstants.spacingM),
          // Greeting and Name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppConstants.labelGreeting,
                  style: TextStyle(
                    color: AppColors.white.withValues(alpha: 0.8),
                    fontSize: AppConstants.fontSizeM,
                  ),
                ),
                const SizedBox(height: 2),
                isLoading
                    ? Container(
                        width: 120,
                        height: 20,
                        decoration: BoxDecoration(
                          color: AppColors.whiteOpacity20,
                          borderRadius: BorderRadius.circular(AppConstants.radiusS),
                        ),
                      )
                    : Text(
                        profile?.fullName ?? 'Chauffeur',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: AppConstants.fontSizeXL,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ],
            ),
          ),
          // Notification and Message Icons
          _buildIconButton(
            icon: Icons.chat_bubble_outline,
            onTap: () {
              // Navigate to messages
            },
          ),
          const SizedBox(width: AppConstants.spacingS),
          _buildIconButton(
            icon: Icons.notifications_outlined,
            badge: true,
            onTap: () {
              // Navigate to notifications
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    if (isLoading) {
      return Container(
        width: AppConstants.avatarSizeL,
        height: AppConstants.avatarSizeL,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.whiteOpacity20,
        ),
      );
    }

    return Container(
      width: AppConstants.avatarSizeL,
      height: AppConstants.avatarSizeL,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.whiteOpacity20,
        image: profile?.photo != null
            ? DecorationImage(
                image: NetworkImage(profile!.photo!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: profile?.photo == null
          ? Center(
              child: Text(
                profile?.initials ?? 'CH',
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: AppConstants.fontSizeXL,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    bool badge = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.whiteOpacity20,
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
        ),
        child: Stack(
          children: [
            Center(
              child: Icon(
                icon,
                color: AppColors.white,
                size: AppConstants.iconSizeM,
              ),
            ),
            if (badge)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}