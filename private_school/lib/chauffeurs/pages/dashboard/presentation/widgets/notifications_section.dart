import 'package:flutter/material.dart';
import 'package:private_school/chauffeurs/pages/dashboard/data/models/dashboard_model.dart';
import 'package:private_school/core/utils/app_colors.dart';
import 'package:private_school/core/utils/app_constants.dart';
import '../pages/notifications_page.dart';

class NotificationsSection extends StatelessWidget {
  final List<NotificationItem> notifications;
  final int unreadCount;

  const NotificationsSection({
    super.key,
    required this.notifications,
    this.unreadCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final displayNotifications = notifications.take(3).toList();

    if (displayNotifications.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingL,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                AppConstants.labelRecentNotifications,
                style: TextStyle(
                  fontSize: AppConstants.fontSizeXL,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NotificationsPage(),
                    ),
                  );
                },
                child: const Text(
                  AppConstants.labelViewAllNotifications,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppConstants.spacingL),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingL,
          ),
          itemCount: displayNotifications.length,
          separatorBuilder: (_, __) =>
              const SizedBox(height: AppConstants.spacingL),
          itemBuilder: (context, index) {
            return _buildNotificationCard(displayNotifications[index]);
          },
        ),
      ],
    );
  }

  Widget _buildNotificationCard(NotificationItem notification) {
    final icon = _getIconForType(notification.type);
    final color = _getColorForType(notification.type);

    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingM),
      decoration: BoxDecoration(
        color: notification.isRead
            ? AppColors.white
            : AppColors.notificationUnreadBg,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(
          color: notification.isRead
              ? AppColors.notificationBorder
              : AppColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppConstants.paddingS),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
            ),
            child: Icon(icon, color: color, size: AppConstants.iconSizeM),
          ),
          const SizedBox(width: AppConstants.spacingL),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: const TextStyle(
                    fontSize: AppConstants.fontSizeM,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppConstants.spacingXS),
                Text(
                  notification.description,
                  style: const TextStyle(
                    fontSize: AppConstants.fontSizeS,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (!notification.isRead)
            Container(
              width: AppConstants.notificationBadgeSize,
              height: AppConstants.notificationBadgeSize,
              margin: const EdgeInsets.only(
                left: AppConstants.paddingS,
                top: AppConstants.spacingXS,
              ),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'subscription_activated':
        return Icons.card_membership;
      case 'trip_started':
        return Icons.play_circle_outline;
      case 'trip_completed':
        return Icons.check_circle_outline;
      case 'weather_alert':
        return Icons.warning_amber;
      default:
        return Icons.notifications;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'subscription_activated':
        return AppColors.subscriptionActivated;
      case 'trip_started':
        return AppColors.primary;
      case 'trip_completed':
        return AppColors.success;
      case 'weather_alert':
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
  }
}
