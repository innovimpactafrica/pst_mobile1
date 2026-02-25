import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:private_school/chauffeurs/pages/dashboard/domain/bloc/unread_messages_bloc.dart';
import 'package:private_school/chauffeurs/pages/dashboard/domain/bloc/unread_notifications_bloc.dart';
import 'package:private_school/chauffeurs/pages/dashboard/presentation/pages/notifications_page.dart';
import 'package:private_school/chauffeurs/pages/profil/data/models/driver_profile_model.dart';
import 'package:private_school/core/utils/app_colors.dart';
import 'package:private_school/core/utils/image_url_helper.dart';
import '../pages/messagerie_page.dart';

class DashboardHeader extends StatelessWidget {
  final DriverProfileModel? profile;
  final bool isLoading;

  const DashboardHeader({super.key, this.profile, this.isLoading = false});

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
                  'hello'.tr(),
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
                        profile?.fullName ?? 'driver'.tr(),
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ],
            ),
          ),
          Row(
            children: [
              BlocBuilder<UnreadMessagesBloc, UnreadMessagesState>(
                builder: (context, state) {
                  final count = state is UnreadMessagesLoaded ? state.count : 0;
                  return _buildIconButtonWithBadge(
                    icon: Icons.chat_bubble_outline,
                    count: count,
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MessageriePage(),
                        ),
                      );
                      if (context.mounted) {
                        context.read<UnreadMessagesBloc>().add(
                          RefreshUnreadCountEvent(),
                        );
                      }
                    },
                  );
                },
              ),
              const SizedBox(width: 8),
              BlocBuilder<UnreadNotificationsBloc, UnreadNotificationsState>(
                builder: (context, state) {
                  final count = state is UnreadNotificationsLoaded
                      ? state.count
                      : 0;
                  return _buildIconButtonWithBadge(
                    icon: Icons.notifications_outlined,
                    count: count,
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NotificationsPage(),
                        ),
                      );
                      if (context.mounted) {
                        context.read<UnreadNotificationsBloc>().add(
                          RefreshUnreadNotificationsCountEvent(),
                        );
                      }
                    },
                  );
                },
              ),
            ],
          ),
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
                onError: (exception, stackTrace) {},
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

  Widget _buildIconButtonWithBadge({
    required IconData icon,
    required int count,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: Icon(icon, color: AppColors.white, size: 22)),
          ),
          if (count > 0)
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                child: Text(
                  count > 99 ? '99+' : count.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
