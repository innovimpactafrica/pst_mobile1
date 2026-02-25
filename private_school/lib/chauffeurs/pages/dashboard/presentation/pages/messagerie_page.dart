import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:private_school/core/utils/app_colors.dart';
import 'package:private_school/core/utils/app_constants.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/services/messaging_service.dart';
import '../../data/models/conversation_model.dart' as driver_model;
import '../../../../../parents/pages/acceuil/data/models/conversation_model.dart'
    as parent_model;
import 'chat_page.dart';
import '../../../../../parents/pages/acceuil/domain/bloc/message_bloc.dart';
import '../../domain/bloc/unread_messages_bloc.dart';

class MessageriePage extends StatefulWidget {
  const MessageriePage({super.key});

  @override
  State<MessageriePage> createState() => _MessageriePageState();
}

class _MessageriePageState extends State<MessageriePage> {
  final MessagingService _messagingService = MessagingService();
  List<driver_model.ConversationModel> _conversations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    try {
      final conversations = await _messagingService.getConversations();
      setState(() {
        _conversations = conversations;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading conversations: $e');
      setState(() => _isLoading = false);
    }
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
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _conversations.isEmpty
                    ? Center(
                        child: Text(
                          'no_conversation'.tr(),
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadConversations,
                        child: ListView(
                          padding: const EdgeInsets.all(AppConstants.spacingM),
                          children: [
                            _buildSearchBar(),
                            const SizedBox(height: AppConstants.spacingM),
                            ..._conversations.map(
                              (conv) => _buildConversationCard(conv),
                            ),
                          ],
                        ),
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
              color: AppColors.white,
              size: AppConstants.iconSizeM,
            ),
          ),
          Text(
            'discussions'.tr(),
            style: const TextStyle(
              fontSize: AppConstants.fontSizeXL,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'search'.tr(),
        hintStyle: TextStyle(
          color: AppColors.textSecondary.withValues(alpha: 0.6),
          fontSize: AppConstants.fontSizeM,
        ),
        prefixIcon: Icon(
          Icons.search,
          color: AppColors.textSecondary.withValues(alpha: 0.6),
        ),
        filled: true,
        fillColor: AppColors.white,
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
      ),
    );
  }

  Widget _buildConversationCard(driver_model.ConversationModel conversation) {
    final parentConversation = parent_model.ConversationModel(
      id: int.tryParse(conversation.id) ?? 0,
      type: 'direct',
      createdAt: conversation.lastMessageTime ?? DateTime.now(),
      updatedAt: conversation.lastMessageTime ?? DateTime.now(),
      lastMessageContent: conversation.lastMessagePreview,
      lastMessageTime: conversation.lastMessageTime,
      unreadCount: conversation.unreadCount,
      isArchived: false,
      isMuted: false,
      otherUserId: int.tryParse(conversation.participantId) ?? 0,
      otherUserName: conversation.displayName,
      otherUserAvatar: conversation.displayAvatar,
      otherUserRole: conversation.participantType,
    );

    return GestureDetector(
      onTap: () async {
        setState(() {
          final index = _conversations.indexOf(conversation);
          if (index != -1) {
            _conversations[index] = driver_model.ConversationModel(
              id: conversation.id,
              displayName: conversation.displayName,
              displayAvatar: conversation.displayAvatar,
              lastMessagePreview: conversation.lastMessagePreview,
              timeAgo: conversation.timeAgo,
              unreadCount: 0,
              lastMessageTime: conversation.lastMessageTime,
              participantId: conversation.participantId,
              participantType: conversation.participantType,
            );
          }
        });

        UnreadMessagesBloc.instance?.add(RefreshUnreadCountEvent());

        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider(
              create: (_) => MessageBloc(),
              child: DriverChatPage(conversation: parentConversation),
            ),
          ),
        );

        if (mounted) {
          _loadConversations();
          UnreadMessagesBloc.instance?.add(RefreshUnreadCountEvent());
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppConstants.spacingL),
        padding: const EdgeInsets.all(AppConstants.spacingL),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
          border: Border.all(
            color: conversation.unreadCount > 0
                ? AppColors.primary.withValues(alpha: 0.3)
                : AppColors.borderLight,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: AppConstants.avatarSizeM,
              backgroundColor: AppColors.primary.withValues(alpha: 0.2),
              backgroundImage: conversation.displayAvatar != null
                  ? NetworkImage(conversation.displayAvatar!)
                  : null,
              child: conversation.displayAvatar == null
                  ? Text(
                      conversation.displayName.isNotEmpty
                          ? conversation.displayName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        fontSize: AppConstants.fontSizeXL,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    )
                  : null,
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
                          conversation.displayName,
                          style: const TextStyle(
                            fontSize: AppConstants.fontSizeL,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        conversation.timeAgo,
                        style: const TextStyle(
                          fontSize: AppConstants.fontSizeS,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacingXS),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.lastMessagePreview,
                          style: TextStyle(
                            fontSize: AppConstants.fontSizeM,
                            color: conversation.unreadCount > 0
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                            fontWeight: conversation.unreadCount > 0
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      if (conversation.unreadCount > 0)
                        Container(
                          margin: const EdgeInsets.only(
                            left: AppConstants.paddingS,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(
                              AppConstants.radiusL,
                            ),
                          ),
                          child: Text(
                            conversation.unreadCount > 99
                                ? '99+'
                                : conversation.unreadCount.toString(),
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: AppConstants.fontSizeXS,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
