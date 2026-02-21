import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart' as easy;

import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_constants.dart';
import '../../data/models/notification_model.dart';
import '../../data/repositories/notification_repository.dart';
import '../../domain/bloc/notification_bloc.dart';
import '../../domain/bloc/notification_event.dart';
import '../../domain/bloc/notification_state.dart';
import '../../domain/bloc/unread_notifications_bloc.dart';

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
  int _currentPage = 1;
  final int _itemsPerPage = 6;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<NotificationModel> _filterNotifications(List<NotificationModel> notifications) {
    if (_searchQuery.isEmpty) return notifications;
    return notifications.where((n) {
      return n.title.toLowerCase().contains(_searchQuery) ||
          n.description.toLowerCase().contains(_searchQuery);
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

                    // ✅ CLEF : synchroniser le badge du dashboard header
                    // chaque fois que le NotificationBloc se met à jour
                    if (state is NotificationLoaded) {
                      try {
                        context.read<UnreadNotificationsBloc>().add(
                              UpdateUnreadCountEvent(state.unreadCount),
                            );
                        debugPrint(
                          '🔔 [NotificationsPage] Badge synchro → ${state.unreadCount}',
                        );
                      } catch (_) {
                        // UnreadNotificationsBloc pas dans ce context, ignoré
                      }
                    }
                  },
                  builder: (context, state) {
                    if (state is NotificationLoading) {
                      return const Center(
                        child: CircularProgressIndicator(color: AppColors.primary),
                      );
                    }
                    if (state is NotificationError) {
                      return _buildErrorState(context, state.message);
                    }
                    if (state is NotificationLoaded) {
                      return _buildContent(
                        context,
                        _filterNotifications(state.notifications),
                      );
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
          Text(
            'notifications'.tr(),
            style: const TextStyle(
              fontSize: AppConstants.fontSizeXL,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<NotificationModel> notifications) {
    if (notifications.isEmpty) return _buildEmptyState();

    final totalPages = (notifications.length / _itemsPerPage).ceil();
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage).clamp(0, notifications.length);
    final pageNotifications = notifications.sublist(startIndex, endIndex);

    final today = <NotificationModel>[];
    final yesterday = <NotificationModel>[];
    final older = <NotificationModel>[];
    final now = DateTime.now();

    for (final n in pageNotifications) {
      final diff = now.difference(n.dateCreation);
      if (diff.inDays == 0) {
        today.add(n);
      } else if (diff.inDays == 1) {
        yesterday.add(n);
      } else {
        older.add(n);
      }
    }

    return Column(
      children: [
        // ✅ Pagination EN HAUT
        if (totalPages > 1) _buildPaginationBar(totalPages),

        // ✅ Liste des notifications
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              setState(() => _currentPage = 1);
              context.read<NotificationBloc>().add(const RefreshNotificationsEvent());
            },
            color: AppColors.primary,
            child: ListView(
              padding: const EdgeInsets.all(AppConstants.spacingXXL),
              children: [
                _buildSearchBar(),
                const SizedBox(height: AppConstants.spacingXXL),
                if (today.isNotEmpty) ...[
                  _buildSectionTitle('today_label'.tr()),
                  ...today.map((n) => _buildNotificationCard(context, n)),
                  const SizedBox(height: AppConstants.spacingXXL),
                ],
                if (yesterday.isNotEmpty) ...[
                  _buildSectionTitle('yesterday'.tr()),
                  ...yesterday.map((n) => _buildNotificationCard(context, n)),
                  const SizedBox(height: AppConstants.spacingXXL),
                ],
                if (older.isNotEmpty) ...[
                  _buildSectionTitle('older'.tr()),
                  ...older.map((n) => _buildNotificationCard(context, n)),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'search'.tr(),
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
                icon: Icon(Icons.clear, color: AppColors.textSecondary.withValues(alpha: 0.6)),
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

  Widget _buildNotificationCard(BuildContext context, NotificationModel notification) {
    final icon = _getIconForType(notification.type);
    final iconColor = _getColorForType(notification.type);

    return Dismissible(
      key: Key(notification.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppConstants.spacingXL),
        margin: const EdgeInsets.only(bottom: AppConstants.spacingL),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
        ),
        child: const Icon(Icons.delete, color: AppColors.white, size: 28),
      ),
      onDismissed: (direction) {
        context.read<NotificationBloc>().add(
              DeleteNotificationEvent(notification.id),
            );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('notification_deleted'.tr()),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: GestureDetector(
        onTap: () {
          if (!notification.isRead) {
            debugPrint('👆 [NotificationsPage] Tap notification ${notification.id}');

            // ✅ 1. Marquer dans NotificationBloc → API → rechargement
            context.read<NotificationBloc>().add(
                  MarkNotificationAsReadEvent(notification.id),
                );

            // ✅ 2. Décrémenter IMMÉDIATEMENT le badge dans le header dashboard
            try {
              context.read<UnreadNotificationsBloc>().add(
                    MarkNotificationAsReadLocalEvent(notification.id),
                  );
            } catch (_) {}
          }
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: AppConstants.spacingL),
          padding: const EdgeInsets.all(AppConstants.spacingM),
          decoration: BoxDecoration(
            color: notification.isRead ? Colors.white : const Color(0xFFEFF6FF),
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
              // Icone
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                ),
                child: Icon(icon, color: iconColor, size: AppConstants.iconSizeM),
              ),
              const SizedBox(width: AppConstants.spacingL),
              // Contenu
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
                            style: TextStyle(
                              fontSize: AppConstants.fontSizeL,
                              fontWeight: notification.isRead
                                  ? FontWeight.w500
                                  : FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            // ✅ Point bleu si non lue
                            if (!notification.isRead)
                              Container(
                                width: 8,
                                height: 8,
                                margin: const EdgeInsets.only(right: 6),
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            Text(
                              _formatTime(notification.dateCreation),
                              style: const TextStyle(
                                fontSize: AppConstants.fontSizeS,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
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
            _searchQuery.isEmpty ? 'no_notifications'.tr() : 'no_result_found'.tr(),
            style: const TextStyle(
              fontSize: AppConstants.fontSizeL,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
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
          const Icon(Icons.error_outline, size: 80, color: AppColors.error),
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
            onPressed: () => context
                .read<NotificationBloc>()
                .add(const LoadNotificationsEvent()),
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
            child: Text('retry'.tr()),
          ),
        ],
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'subscription_activated': return Icons.card_membership;
      case 'trip_started': return Icons.play_circle_outline;
      case 'trip_completed': return Icons.check_circle_outline;
      case 'weather_alert': return Icons.warning_amber;
      default: return Icons.notifications;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'subscription_activated': return const Color(0xFF3B82F6);
      case 'trip_started': return AppColors.primary;
      case 'trip_completed': return AppColors.success;
      case 'weather_alert': return AppColors.warning;
      default: return AppColors.textSecondary;
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    if (diff.inDays == 0) {
      return "${'today_label'.tr()}, ${DateFormat('HH:mm').format(dateTime)}";
    } else if (diff.inDays == 1) {
      return "${'yesterday'.tr()}, ${DateFormat('HH:mm').format(dateTime)}";
    } else if (diff.inDays < 7) {
      return '${diff.inDays}j';
    } else {
      return DateFormat('dd/MM').format(dateTime);
    }
  }

  // ✅ Pagination EN HAUT avec design propre
  Widget _buildPaginationBar(int totalPages) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Bouton précédent
          IconButton(
            onPressed: _currentPage > 1 ? () => setState(() => _currentPage--) : null,
            icon: Icon(
              Icons.arrow_back_ios,
              size: 18,
              color: _currentPage > 1 ? AppColors.primary : Colors.grey.shade300,
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
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : Colors.grey.shade300,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '$page',
                      style: TextStyle(
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
            onPressed: _currentPage < totalPages ? () => setState(() => _currentPage++) : null,
            icon: Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: _currentPage < totalPages ? AppColors.primary : Colors.grey.shade300,
            ),
          ),
        ],
      ),
    );
  }
}