import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_constants.dart';
import '../../data/models/notification_model.dart';
import '../../data/repositories/notification_repository.dart';
import '../../domain/bloc/notification_bloc.dart';
import '../../domain/bloc/notification_event.dart';
import '../../domain/bloc/notification_state.dart';

/// Notifications page for drivers
/// Follows Innov & Impact Africa Flutter Coding Guidelines:
/// - Uses BLoC for state management
/// - No direct API calls in widgets
/// - Proper separation of concerns
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NotificationBloc(repository: NotificationRepository())
        ..add(const LoadNotificationsEvent()),
      child: const _NotificationsPageContent(),
    );
  }
}

class _NotificationsPageContent extends StatefulWidget {
  const _NotificationsPageContent();

  @override
  State<_NotificationsPageContent> createState() =>
      _NotificationsPageContentState();
}

class _NotificationsPageContentState extends State<_NotificationsPageContent> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  List<NotificationModel> _filterNotifications(
    List<NotificationModel> notifications,
  ) {
    if (_searchQuery.isEmpty) {
      return notifications;
    }
    return notifications.where((notification) {
      return notification.title.toLowerCase().contains(_searchQuery) ||
          notification.description.toLowerCase().contains(_searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppConstants.radiusXL),
                    topRight: Radius.circular(AppConstants.radiusXL),
                  ),
                ),
                child: BlocConsumer<NotificationBloc, NotificationState>(
                  listener: (context, state) {
                    if (state is NotificationActionSuccess) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.message),
                          backgroundColor: AppColors.success,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    if (state is NotificationLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      );
                    }

                    if (state is NotificationError) {
                      return _buildErrorState(context, state.message);
                    }

                    if (state is NotificationLoaded) {
                      final filteredNotifications =
                          _filterNotifications(state.notifications);
                      return _buildContent(context, filteredNotifications);
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
              size: AppConstants.iconSizeM,
            ),
          ),
          const Text(
            'Notifications',
            style: TextStyle(
              fontSize: AppConstants.fontSizeXL,
              fontWeight: FontWeight.w600,
              color: Colors.white,
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
            size: 80,
            color: AppColors.error,
          ),
          const SizedBox(height: AppConstants.spacingXXL),
          Text(
            message,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: AppConstants.fontSizeM,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.spacingXXL),
          ElevatedButton(
            onPressed: () {
              context
                  .read<NotificationBloc>()
                  .add(const LoadNotificationsEvent());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacingXXL,
                vertical: AppConstants.spacingM,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
              ),
            ),
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    List<NotificationModel> notifications,
  ) {
    if (notifications.isEmpty) {
      return _buildEmptyState();
    }

    // Group notifications by date
    final today = <NotificationModel>[];
    final yesterday = <NotificationModel>[];
    final older = <NotificationModel>[];

    final now = DateTime.now();
    for (final notification in notifications) {
      final diff = now.difference(notification.dateCreation);
      if (diff.inDays == 0) {
        today.add(notification);
      } else if (diff.inDays == 1) {
        yesterday.add(notification);
      } else {
        older.add(notification);
      }
    }

    return RefreshIndicator(
      onRefresh: () async {
        context
            .read<NotificationBloc>()
            .add(const RefreshNotificationsEvent());
      },
      color: AppColors.primary,
      child: ListView(
        padding: const EdgeInsets.all(AppConstants.spacingXXL),
        children: [
          _buildSearchBar(),
          const SizedBox(height: AppConstants.spacingXXL),
          if (today.isNotEmpty) ...[
            _buildSectionTitle("Aujourd'hui"),
            ...today.map((n) => _buildNotificationCard(context, n)),
            const SizedBox(height: AppConstants.spacingXXL),
          ],
          if (yesterday.isNotEmpty) ...[
            _buildSectionTitle('Hier'),
            ...yesterday.map((n) => _buildNotificationCard(context, n)),
            const SizedBox(height: AppConstants.spacingXXL),
          ],
          if (older.isNotEmpty) ...[
            _buildSectionTitle('Plus ancien'),
            ...older.map((n) => _buildNotificationCard(context, n)),
          ],
        ],
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
            size: 80,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppConstants.spacingXXL),
          Text(
            _searchQuery.isEmpty
                ? 'Aucune notification'
                : 'Aucun résultat trouvé',
            style: const TextStyle(
              fontSize: AppConstants.fontSizeL,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (_searchQuery.isNotEmpty) ...[
            const SizedBox(height: AppConstants.spacingL),
            Text(
              'Essayez une autre recherche',
              style: TextStyle(
                fontSize: AppConstants.fontSizeM,
                color: AppColors.textSecondary.withValues(alpha: 0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Rechercher',
        hintStyle: TextStyle(
          color: AppColors.textSecondary.withValues(alpha: 0.6),
          fontSize: AppConstants.fontSizeM,
        ),
        prefixIcon: Icon(
          Icons.search,
          color: AppColors.textSecondary.withValues(alpha: 0.6),
          size: AppConstants.iconSizeM,
        ),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                icon: Icon(
                  Icons.clear,
                  color: AppColors.textSecondary.withValues(alpha: 0.6),
                ),
                onPressed: () => _searchController.clear(),
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingM,
          vertical: AppConstants.spacingL,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingL),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: AppConstants.fontSizeM,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    NotificationModel notification,
  ) {
    final icon = _getIconForType(notification.type);
    final iconColor = _getColorForType(notification.type);
    final timeString = _formatTime(notification.dateCreation);

    return GestureDetector(
      onTap: () {
        if (!notification.isRead) {
          context
              .read<NotificationBloc>()
              .add(MarkNotificationAsReadEvent(notification.id));
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppConstants.spacingL),
        padding: const EdgeInsets.all(AppConstants.spacingM),
        decoration: BoxDecoration(
          color: notification.isRead
              ? Colors.white
              : const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
          border: Border.all(
            color: notification.isRead
                ? AppColors.borderLight
                : AppColors.primary.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: AppConstants.iconSizeM,
              ),
            ),
            const SizedBox(width: AppConstants.spacingL),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: const TextStyle(
                            fontSize: AppConstants.fontSizeL,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        timeString,
                        style: const TextStyle(
                          fontSize: AppConstants.fontSizeS,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacingXS),
                  Text(
                    notification.description,
                    style: const TextStyle(
                      fontSize: AppConstants.fontSizeM,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inDays == 0) {
      return "Aujourd'hui, ${DateFormat('HH:mm').format(dateTime)}";
    } else if (diff.inDays == 1) {
      return 'Hier, ${DateFormat('HH:mm').format(dateTime)}';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}j';
    } else {
      return DateFormat('dd/MM').format(dateTime);
    }
  }
}