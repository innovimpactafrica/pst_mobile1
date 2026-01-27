// Notifications section widget
// Path: lib/chauffeurs/pages/dashboard/presentation/widgets/notifications_section.dart

import 'package:flutter/material.dart';
import 'package:private_school/core/utils/app_colors.dart';
import '../../data/models/dashboard_model.dart';
import 'package:intl/intl.dart';

class NotificationsSection extends StatelessWidget {
  final List<NotificationItem> notifications;
  final int unreadCount;

  const NotificationsSection({
    super.key,
    required this.notifications,
    required this.unreadCount,
  });

  @override
  Widget build(BuildContext context) {
    if (notifications.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Notifications récentes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: notifications.length > 3 ? 3 : notifications.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _buildNotificationCard(notifications[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(NotificationItem notification) {
    IconData iconData;
    Color iconColor;
    
    switch (notification.type) {
      case 'subscription_activated':
        iconData = Icons.card_membership;
        iconColor = AppColors.success;
        break;
      case 'trip_started':
        iconData = Icons.directions_car;
        iconColor = AppColors.info;
        break;
      case 'trip_completed':
        iconData = Icons.check_circle;
        iconColor = AppColors.success;
        break;
      default:
        iconData = Icons.notifications;
        iconColor = AppColors.primary;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: notification.isRead 
            ? AppColors.background 
            : AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: notification.isRead
              ? AppColors.textSecondary.withValues(alpha: 0.1)
              : AppColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              iconData,
              color: iconColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  notification.description,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary.withValues(alpha: 0.8),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 12,
                      color: AppColors.textSecondary.withValues(alpha: 0.5),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getTimeAgo(notification.dateCreation),
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (!notification.isRead)
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'À l\'instant';
    } else if (difference.inMinutes < 60) {
      return 'Il y a ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Il y a ${difference.inHours} h';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays} j';
    } else {
      return DateFormat('dd/MM/yyyy').format(dateTime);
    }
  }
}