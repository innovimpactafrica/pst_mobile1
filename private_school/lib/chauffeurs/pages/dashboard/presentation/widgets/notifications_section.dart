// Notifications section widget
// Path: lib/chauffeurs/pages/dashboard/presentation/widgets/notifications_section.dart

import 'package:flutter/material.dart';
import 'package:private_school/chauffeurs/pages/dashboard/data/models/dashboard_model.dart';
import 'package:private_school/core/utils/app_colors.dart';
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
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Notifications récentes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NotificationsPage()),
                  );
                },
                child: const Text(
                  'Voir tout',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: displayNotifications.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: notification.isRead
            ? AppColors.white
            : const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: notification.isRead
              ? const Color(0xFFE5E7EB)
              : AppColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
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
                  style: const TextStyle(
                    fontSize: 13,
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
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(left: 8, top: 4),
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
        return const Color(0xFF3B82F6);
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