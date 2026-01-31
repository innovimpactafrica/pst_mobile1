// Dashboard header with navigation
// Path: lib/chauffeurs/pages/dashboard/presentation/widgets/dashboard_header.dart
// Follows Innov & Impact Africa Flutter Coding Guidelines:
// - Uses BLoC for state management
// - No direct data passing via props
// - Proper separation of concerns

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:private_school/chauffeurs/pages/dashboard/domain/bloc/notification_bloc.dart';
import 'package:private_school/chauffeurs/pages/dashboard/domain/bloc/notification_state.dart';
import 'package:private_school/chauffeurs/pages/dashboard/presentation/pages/notifications_page.dart';
import 'package:private_school/chauffeurs/pages/profil/data/models/driver_profile_model.dart';
import 'package:private_school/core/utils/app_colors.dart';
import 'package:private_school/core/utils/image_url_helper.dart';
import '../pages/messagerie_page.dart';

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
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          _buildProfileImage(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bonjour,',
                  style: TextStyle(
                    color: AppColors.white.withValues(alpha: 0.8),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                isLoading
                    ? Container(
                        width: 120,
                        height: 20,
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      )
                    : Text(
                        profile?.fullName ?? 'Chauffeur',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ],
            ),
          ),
          _buildIconButton(
            icon: Icons.chat_bubble_outline,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MessageriePage()),
              );
            },
          ),
          const SizedBox(width: 8),
          _buildNotificationButton(context),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    if (isLoading) {
      return Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.white.withValues(alpha: 0.2),
        ),
      );
    }

    final imageUrl = profile?.photo != null && profile!.photo!.isNotEmpty
        ? ImageUrlHelper.getFullImageUrl(profile!.photo!)
        : null;

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.white.withValues(alpha: 0.2),
        image: imageUrl != null
            ? DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
                onError: (exception, stackTrace) {
                  // Silently handle error - will show initials
                },
              )
            : null,
      ),
      child: imageUrl == null
          ? Center(
              child: Text(
                profile?.initials ?? 'CH',
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Icon(
            icon,
            color: AppColors.white,
            size: 22,
          ),
        ),
      ),
    );
  }

  /// Notification button with BLoC integration
  /// Reads notification count from NotificationBloc state
  Widget _buildNotificationButton(BuildContext context) {
    return BlocBuilder<NotificationBloc, NotificationState>(
      builder: (context, state) {
        int unreadCount = 0;
        
        if (state is NotificationLoaded) {
          unreadCount = state.unreadCount;
        }

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const NotificationsPage(),
              ),
            );
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                const Center(
                  child: Icon(
                    Icons.notifications_outlined,
                    color: AppColors.white,
                    size: 22,
                  ),
                ),
                if (unreadCount > 0)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        unreadCount > 9 ? '9+' : '$unreadCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}