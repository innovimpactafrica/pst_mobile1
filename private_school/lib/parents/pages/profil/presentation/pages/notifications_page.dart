import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:private_school/parents/pages/profil/data/repositories/notifications_repository.dart';
import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_constants.dart';
import '../../domain/bloc/notification_bloc.dart';
import '../../domain/bloc/notification_event.dart';
import '../../domain/bloc/notification_state.dart';
import '../../data/models/notification_model.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ParentNotificationBloc(
        repository: NotificationRepository(),
      )..add(const LoadNotificationsEvent()),
      child: const NotificationsPageContent(),
    );
  }
}

class NotificationsPageContent extends StatelessWidget {
  const NotificationsPageContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: GoogleFonts.inter(
            fontSize: AppConstants.fontSizeXL,
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
        ),
        backgroundColor: AppColors.success,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocListener<ParentNotificationBloc, NotificationState>(
        listener: (context, state) {
          if (state is NotificationDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Notification supprimée'),
                backgroundColor: AppColors.success,
              ),
            );
          } else if (state is NotificationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: BlocBuilder<ParentNotificationBloc, NotificationState>(
          builder: (context, state) {
            if (state is NotificationLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.success),
              );
            }

            if (state is NotificationError) {
              return _buildErrorState(context, state.message);
            }

            if (state is NotificationsLoaded) {
              if (state.notifications.isEmpty) {
                return _buildEmptyState();
              }

              return RefreshIndicator(
                color: AppColors.success,
                onRefresh: () async {
                  context
                      .read<ParentNotificationBloc>()
                      .add(const RefreshNotificationsEvent());
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(AppConstants.spacingXL),
                  itemCount: state.notifications.length,
                  itemBuilder: (context, index) {
                    final notification = state.notifications[index];
                    return _buildNotificationCard(context, notification);
                  },
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    NotificationModel notification,
  ) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppConstants.spacingXL),
        margin: const EdgeInsets.only(bottom: AppConstants.spacingM),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
        ),
        child: const Icon(Icons.delete, color: AppColors.white),
      ),
      onDismissed: (direction) {
        context
            .read<ParentNotificationBloc>()
            .add(DeleteNotificationEvent(notification.id));
      },
      child: GestureDetector(
        onTap: () {
          if (!notification.isRead) {
            context
                .read<ParentNotificationBloc>()
                .add(MarkAsReadEvent(notification.id));
          }
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: AppConstants.spacingM),
          padding: const EdgeInsets.all(AppConstants.spacingL),
          decoration: BoxDecoration(
            color: notification.isRead
                ? AppColors.white
                : AppColors.success.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(AppConstants.radiusL),
            border: Border.all(
              color: notification.isRead
                  ? AppColors.grey200
                  : AppColors.success.withValues(alpha: 0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icône
              Container(
                padding: const EdgeInsets.all(AppConstants.spacingS),
                decoration: BoxDecoration(
                  color: _getNotificationColor(notification.notificationType)
                      .withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getNotificationIcon(notification.notificationType),
                  color: _getNotificationColor(notification.notificationType),
                  size: 20,
                ),
              ),

              const SizedBox(width: AppConstants.spacingM),

              // Contenu
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: GoogleFonts.inter(
                              fontSize: AppConstants.fontSizeM,
                              fontWeight: notification.isRead
                                  ? FontWeight.w500
                                  : FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: AppConstants.spacingXS),

                    Text(
                      notification.message,
                      style: GoogleFonts.inter(
                        fontSize: AppConstants.fontSizeS,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: AppConstants.spacingXS),

                    Text(
                      notification.timeAgo,
                      style: GoogleFonts.inter(
                        fontSize: AppConstants.fontSizeXS,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 64,
            color: AppColors.grey400,
          ),
          const SizedBox(height: AppConstants.spacingL),
          Text(
            'Aucune notification',
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeL,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppConstants.spacingS),
          Text(
            'Vos notifications apparaîtront ici',
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeM,
              color: AppColors.textGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.error,
          ),
          const SizedBox(height: AppConstants.spacingL),
          Text(
            'Erreur de chargement',
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeL,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppConstants.spacingS),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingXXL),
            child: Text(
              message,
              style: GoogleFonts.inter(
                fontSize: AppConstants.fontSizeM,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppConstants.spacingXL),
          ElevatedButton(
            onPressed: () {
              context
                  .read<ParentNotificationBloc>()
                  .add(const LoadNotificationsEvent());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacingXXL,
                vertical: AppConstants.spacingM,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusL),
              ),
            ),
            child: Text(
              'Réessayer',
              style: GoogleFonts.inter(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.tripStarted:
        return Icons.directions_car;
      case NotificationType.tripCompleted:
        return Icons.check_circle_outline;
      case NotificationType.weatherAlert:
        return Icons.wb_cloudy_outlined;
      case NotificationType.subscription:
        return Icons.card_membership;
      case NotificationType.payment:
        return Icons.payment;
      case NotificationType.child:
        return Icons.child_care;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.tripStarted:
        return AppColors.primary;
      case NotificationType.tripCompleted:
        return AppColors.success;
      case NotificationType.weatherAlert:
        return AppColors.warning;
      case NotificationType.subscription:
        return AppColors.info;
      case NotificationType.payment:
        return AppColors.success;
      case NotificationType.child:
        return AppColors.secondary;
      default:
        return AppColors.grey600;
    }
  }
}