import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:private_school/parents/pages/profil/data/repositories/notifications_repository.dart';
import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_constants.dart';
import '../../domain/bloc/notification_bloc.dart';
import '../../domain/bloc/notification_event.dart';
import '../../domain/bloc/notification_state.dart';
import '../../domain/bloc/unread_notifications_bloc.dart';
import '../../data/models/notification_model.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ParentNotificationBloc(
            repository: NotificationRepository(),
          )..add(const LoadNotificationsEvent()),
        ),
        BlocProvider(
          create: (context) => UnreadNotificationsBloc(
            repository: NotificationRepository(),
          ),
        ),
      ],
      child: const NotificationsPageContent(),
    );
  }
}

class NotificationsPageContent extends StatefulWidget {
  const NotificationsPageContent({super.key});

  @override
  State<NotificationsPageContent> createState() => _NotificationsPageContentState();
}

class _NotificationsPageContentState extends State<NotificationsPageContent> {
  // ✅ Pagination
  int _currentPage = 1;
  final int _itemsPerPage = 6;

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

              // ✅ Calcul pagination
              final totalPages = (state.notifications.length / _itemsPerPage).ceil();
              final startIndex = (_currentPage - 1) * _itemsPerPage;
              final endIndex = (startIndex + _itemsPerPage).clamp(0, state.notifications.length);
              final pageNotifications = state.notifications.sublist(startIndex, endIndex);

              return Column(
                children: [
                  // ✅ Liste des notifications de la page courante
                  Expanded(
                    child: RefreshIndicator(
                      color: AppColors.success,
                      onRefresh: () async {
                        setState(() => _currentPage = 1);
                        context.read<ParentNotificationBloc>()
                            .add(const RefreshNotificationsEvent());
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.all(AppConstants.spacingXL),
                        itemCount: pageNotifications.length,
                        itemBuilder: (context, index) {
                          return _buildNotificationCard(
                            context,
                            pageNotifications[index],
                          );
                        },
                      ),
                    ),
                  ),

                  // ✅ Barre de pagination
                  if (totalPages > 1)
                    _buildPaginationBar(totalPages),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  // ✅ Barre de pagination
  Widget _buildPaginationBar(int totalPages) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Bouton précédent
          IconButton(
            onPressed: _currentPage > 1
                ? () => setState(() => _currentPage--)
                : null,
            icon: Icon(
              Icons.arrow_back_ios,
              size: 18,
              color: _currentPage > 1 ? AppColors.success : Colors.grey.shade300,
            ),
          ),

          // Numéros de pages
          Row(
            children: List.generate(totalPages, (index) {
              final page = index + 1;
              final isSelected = page == _currentPage;
              return GestureDetector(
                onTap: () => setState(() => _currentPage = page),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.success : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? AppColors.success : Colors.grey.shade300,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '$page',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? AppColors.white : Colors.grey.shade600,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),

          // Bouton suivant
          IconButton(
            onPressed: _currentPage < totalPages
                ? () => setState(() => _currentPage++)
                : null,
            icon: Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: _currentPage < totalPages
                  ? AppColors.success
                  : Colors.grey.shade300,
            ),
          ),
        ],
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
        context.read<ParentNotificationBloc>()
            .add(DeleteNotificationEvent(notification.id));
      },
      child: GestureDetector(
        onTap: () {
          if (!notification.isRead) {
            // ✅ Marquer comme lue dans les 2 blocs
            context.read<ParentNotificationBloc>()
                .add(MarkAsReadEvent(notification.id));
            context.read<UnreadNotificationsBloc>()
                .add(MarkNotificationAsReadEvent(notification.id));
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
          Icon(Icons.notifications_none, size: 64, color: AppColors.grey400),
          const SizedBox(height: AppConstants.spacingL),
          Text(
            'Aucune notification',
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeL,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
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
          const Icon(Icons.error_outline, size: 64, color: AppColors.error),
          const SizedBox(height: AppConstants.spacingL),
          Text('Erreur de chargement',
              style: GoogleFonts.inter(
                fontSize: AppConstants.fontSizeL,
                fontWeight: FontWeight.w600,
              )),
          const SizedBox(height: AppConstants.spacingS),
          Text(message,
              style: GoogleFonts.inter(
                fontSize: AppConstants.fontSizeM,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center),
          const SizedBox(height: AppConstants.spacingXL),
          ElevatedButton(
            onPressed: () => context
                .read<ParentNotificationBloc>()
                .add(const LoadNotificationsEvent()),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
            ),
            child: Text('Réessayer',
                style: GoogleFonts.inter(color: AppColors.white)),
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